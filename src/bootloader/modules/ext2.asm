%include "modules/lba.asm"

%macro print_ch 1

    push ax
    mov ah, 0eh
    mov al, %1
    int 10h
    pop ax 

%endmacro
%macro dump_all_regs 0
    pusha
    
    print_ch "a"
    mov eax, eax
    call os_print_eax

    print_ch "b"
    mov eax, ebx
    call os_print_eax

    print_ch "c"
    mov eax, ecx
    call os_print_eax

    print_ch "d"
    mov eax, edx
    call os_print_eax

    print_ch "e"
    mov eax, esi
    call os_print_eax

    print_ch "f"
    mov eax, edi
    call os_print_eax


    popa
%endmacro
fs_offset dw 1
fs_start dw 0 ; In sectors

%define INODE_COUNT				[superblock_buffer+0]
%define BLOCK_COUNT				[superblock_buffer+4]
%define SUPERBLOCK_BLOCK        [superblock_buffer+20]
%define BLOCK_SIZE_LOG			[superblock_buffer+24]
%define BLOCKS_PER_GROUP		[superblock_buffer+32]
%define INODES_PER_GROUP		[superblock_buffer+40]
%define EXT2_SIGNATURE			[superblock_buffer+56]
%define INODE_SIZE				[superblock_buffer+88]

BLOCK_SIZE dw 0
BLOCK_SECTORS db 0
GROUP_COUNT dd 0

; IN = EAX: LBA, CL: Sector count, ES:BX Buffer pointer
read_sectors:
    pusha

.try:
    popa
    pusha
    mov esi, eax
    mov al, cl
    call os_lba_to_int13h
    int 13h

    push eax
    xor eax, eax ; it just works
    ; only god knows why
    pop eax


    jnc .done

    inc byte [retry_count]    
    cmp byte [retry_count], 0x10
    je halt

    mov ecx, eax

    mov dl, 0x81
    mov ah, 0
    int 13h

    mov eax, ecx

    jmp .try

.done:
    popa
    and ebx, 0x0000FFFF
    ret

os_ext2_setup:
    pusha
    
    mov ax, 0
    mov es, ax
    mov dx, 0


.retry:
    ; Superblock is in LBA 1 if we don't have a MBR. 
    ; It can be LBA 2 if we do though, 
    ; or in any other if the disk is partition. 
    ; We will test for 1, 2, and 3

    cmp dx, 3
    je .error_wrongfs


    inc ax
    inc dx

    mov cl, 2 ; Its size is 1024B
    mov bx, superblock_buffer
    call read_sectors

    cmp word EXT2_SIGNATURE, 0xef53 ; check for ext2 signature
    
    jne .retry

.found_superblock:
    mov [fs_offset], ax

    ; Calculate block size
    ; BLOCK_SIZE = log2 (BLOCK_SIZE_LOG) - 10. (In other words, the number to shift 1,024 to the left by to obtain the block size) 
    mov ecx, BLOCK_SIZE_LOG
    cmp ecx, 0
    mov ax, 1024
    je .dont_shift
.shift_block_size:
    shl ax, 1
    loop .shift_block_size
.dont_shift:
    mov [BLOCK_SIZE], ax

    mov edx, 0
    mov cx, SECTOR_SIZE
    div cx
    mov byte [BLOCK_SECTORS], al
    ; Calculate group count
    ; GROUP_COUNT = ceil(BLOCK_COUNT / BLOCKS_PER_GROUP)
    ; GROUP_COUNT = ceil(INODE_COUNT / INODES_PER_GROUP)
    ; It's a good idea to check both and compare them

    mov edx, 0 
    mov eax, BLOCK_COUNT
    mov ebx, BLOCKS_PER_GROUP
    div ebx

    ; Round up
    cmp edx, 0
    je .zero

    inc eax

    .zero:

    mov ecx, eax


    mov edx, 0 
    mov eax, INODE_COUNT
    mov ebx, INODES_PER_GROUP
    div ebx

    ; Round up
    cmp edx, 0
    je .zero2

    inc eax

    .zero2:

    cmp ecx, eax ; Make sure they are equal

    jne .error_unmatching_groupcount

    mov eax, SUPERBLOCK_BLOCK
    add eax, [fs_offset]
    mov word [fs_start], 1;eax


    ; Now that the superblock is loaded,

    
    mov si, .yessuperblock_msg
    call print_string


    popa
    ret



.error_wrongfs:
    mov si, .nosuperblock_msg
    call print_string

    jmp halt
.error_unmatching_groupcount:
    mov si, .unmatching_groupcount_msg
    call print_string

    jmp halt

.nosuperblock_msg db "Error: Ext2 Superblock not found. Make sure you have an unpartitioned ext2 hard disk mounted in hdb.", 0xd, 0xa, 0
.yessuperblock_msg db "Ext2: Superblock loaded", 0xd, 0xa, 0
.rootdir_success_msg db "Ext2: Root directory loaded", 0xd, 0xa, 0
.unmatching_groupcount_msg db "Error: BLOCK_COUNT / BLOCKS_PER_GROUP != INODE_COUNT / INODES_PER_GROUP", 0xd, 0xa, 0

; IN =  EAX: Inode number
; OUT = EAX: Group number
os_ext2_get_inode_group:
    push edx
    push ebx

    ;  block group = (inode – 1) / INODES_PER_GROUP
    mov edx,0 ; Clear garbage
    mov dword ebx, INODES_PER_GROUP ; Inodes per block group
    sub eax, 1
    div ebx 

    pop ebx
    pop edx
    ret

; IN =  EAX: Inode number
; OUT = EAX: Index inside block
os_ext2_get_inode_index:
    push edx
    push ebx

    mov edx, 0 ; Clean garbage

    ; index = (inode – 1) % INODES_PER_GROUP
    mov dword ebx, INODES_PER_GROUP ; Inodes per block group
    sub eax, 1
    div ebx

    mov eax, edx


    pop ebx
    pop edx
    ret

; IN =  EAX: Inode number
; OUT = EAX: Block number
os_ext2_get_inode_block:
    push edx
    push ebx

    mov edx, 0 ; Clean garbage
    
    ; containing block = (index * INODE_SIZE) / BLOCK_SIZE
    mov word bx, INODE_SIZE
    mul bx

    mov edx, 0 ; Clear garbage
    mov ebx, 0
    mov word bx, BLOCK_SIZE
    div ebx

    mov eax, ebx

    pop ebx
    pop edx
    ret

SECTOR_SIZE equ 512


; IN =  EAX: Block number. EDI: Sector offset (not usually needed)
; OUT = EAX: LBA address
os_ext2_get_block_lba:
    ; Sector = Block number * BLOCK_SIZE / SECTOR_SIZE - filesystem_start
    push edx
    push ebx
    mov ebx, 0
    mov bx, [BLOCK_SIZE]

    mul ebx


    mov edx, 0 ; Clear garbage
    mov ebx, SECTOR_SIZE
    div ebx

    add eax, edi

    pop ebx
    pop edx
    ret


; IN =  EAX: Block group number, ES:BX: Buffer
; OUT = ES:BX contents and value changed to point to the start of the entry
os_ext2_read_bgdt:
    ; Push everything except BX
    push eax
    push ecx
    push edx
    push edi


    push ebx ; Buffer
    push eax ; Requested block group number
    cmp word [BLOCK_SIZE], 1024 ; if this is the case then it begins at block 2
    clc
    mov edi, 0
    jne .block1
    je .block2
    .block1: 
        mov eax, 4
        call os_ext2_get_block_lba
        jmp .load_table
    .block2:
        mov eax, 2
        call os_ext2_get_block_lba
        jmp .load_table

.load_table:
    pop edx ; Requested block group number
    push eax ; start of BGDT 
    ; Convert entry number to byte
    mov eax, 32
    mul edx

    ; Calculate the sector offset
    mov edx, 0 
    mov ecx, SECTOR_SIZE
    div ecx
    ; Now in-sector offset is in EDX and sector is in EAX

    mov ebx, eax

    pop eax ; start of BGDT 

    add eax, ebx ; Actual sector number
    mov cl, 1
    pop ebx ; Buffer
    call read_sectors

    add ebx, edx ; Get position of BGDT entry

    ; Pop everything except BX
    pop edi
    pop edx
    pop ecx
    pop eax
    ret

; IN =  EAX: Group number, ES:BX: Buffer
; OUT = EAX: Block address of start of inode table
os_ext2_get_inode_table_block:
    push ebx
    call os_ext2_read_bgdt
    mov eax, [ebx + 8]
    pop ebx
    ret
    
; IN =  EAX: Inode number, ES:BX: Buffer
; OUT = ES:BX points to the inode
os_ext2_load_inode:
    push eax
    push ecx
    push edx
    push edi

    push eax ; Inode number
    call os_ext2_get_inode_index
 

    mov ecx, INODE_SIZE
    mul ecx

    ; Now divide by block size
    mov edx, 0 ; Clear garbage
    mov ecx, 0
    mov cx, [BLOCK_SIZE]
    div ecx


    ; Block offset is in eax
    ; Byte offset is in edx


    mov ecx, eax ; Block offset

    pop eax ; Inode number
    push edx ; Byte offset


    call os_ext2_get_inode_group


    call os_ext2_get_inode_table_block
    add eax, ecx


    mov bx, disk_buffer
    mov edi, 0
    clc
    call os_ext2_load_block



    pop edx ; Byte offset

    add ebx, edx


    pop edi
    pop edx
    pop ecx
    pop eax
    ret

; Gets the location for the EAXth block that contains a file
; IN =  EAX: Block index, ES:BX: Buffer with the inode
; OUT = EAX: Block number
os_ext2_get_file_block:
    push ebx
    push ecx
    push edx


    push eax
    ;inc eax ; To round up to closest multiple of [BLOCK_SIZE]

    mov ecx, 0
    mov edx, 0
    mov cx, [BLOCK_SIZE]

    mul ecx
    cmp [bx+108], edx 
    jl .index_error; Requested block is larger than file
    cmp [bx+4], eax 
    jng .index_error; Requested block is larger than file

    pop eax


    mov edx, eax


    cmp edx, 12
    jl .direct_inode

    mov eax, BLOCK_SIZE
    shr eax, 2 ; EAX: Block addresses that fit in a blcock
    add eax, 10
    cmp edx, eax
    jl .indirect1_inode

    mov ah, 0eh
    mov al, "!"; TODO implement
    int 10h
    jmp $
    jmp halt


.direct_inode:
    shl eax, 1 ; multiply by two

    add ebx, eax
    mov eax, [ebx+40+eax]

    jmp .done
.indirect1_inode:
    push edx

    mov eax, [bx + 88] ; Singly indirect block
    mov ecx, 10
    add eax, 8
    call os_print_eax  
    ;mov eax, 0x17800 / 1024+1
    mov bx, disk_buffer
    call os_ext2_load_block
    mov bx, disk_buffer
    mov eax, [bx]
    call os_print_eax   


    pop edx
    

    sub edx, 12
    shl edx, 2  

    add bx, dx

    mov eax, [bx]
    call os_print_eax   

    jmp .done



.index_error:
    pop eax
    stc
.done:
    
    pop edx
    pop ecx
    pop ebx

    ret

; IN =  EAX: Block number
; OUT = disk_buffer filled with block
os_ext2_load_block:
    
    call os_ext2_get_block_lba
    mov bx, disk_buffer 
    mov cl, [BLOCK_SECTORS]
    call read_sectors
    ret

; IN = EAX:  Parent directory inode number, ESI: Filename
; OUT = EAX: Subfile inode number
os_ext2_get_subfile_inode:
    push ebx
    push ecx
    push edx
    push esi
    push edi


    mov bx, disk_buffer
    call os_ext2_load_inode
    mov ecx, [bx+4] ; File size
    mov eax, 0 ; Get data block index number 0 

.load_blocks:
    call os_ext2_get_file_block
    mov edi, 0
    call os_ext2_load_block

    mov ecx, 0x100
    push eax
    add bx, 0xc
    .look_for_filename:
        push ecx ; look_for_filename counter

        mov ax, bx

        mov di, bx
        add di, 8

        mov ecx, 0
        mov cl, [bx+6] ; Name length
        mov eax, 0
        mov al, cl

        mov ah, 0eh
        push esi
        push ecx

        .loopy:
            mov al, [esi]
            cmp al, [edi]
            jne .notequal

            dec cl
            inc edi
            inc esi
            cmp cl, 0
            jne .loopy

        ; Equal!
        pop ecx
        pop esi
        pop ecx ; look_for_filename counter
        mov di, bx
        add di, 8
        jmp .found_name

        .notequal:


        pop ecx
        pop esi

        mov ax, [bx+4]
        add bx, ax

        pop ecx ; look_for_filename counter
        sub cx, ax ; Substract

        jnc .look_for_filename ; If no underflow, continue

    pop eax
    ; Filename not found yet?
    inc eax
    jmp .load_blocks
.found_name:
    pop eax
    mov eax, [bx]
    clc
    jmp .done

.notfound:
    stc
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; IN = ESI: filename
; OUT = ES:BX points to inode
os_ext2_load_file_inode:
    push eax
    ; Fetch the root directory, and find the sub-file's inode.
    ; It's in inode 2
    mov eax, 2 
    mov bx, disk_buffer
    call os_ext2_get_subfile_inode


    ; Load the inode
    mov bx, disk_buffer
    call os_ext2_load_inode
    clc
    pop eax
    ret

; IN = ES:BX: points to the inode, EAX: Block number, EDI: Offset
; OUT = ES:BX points to the block, carry set if file size exceeded
os_ext2_load_inode_block:
    push edi
    call os_ext2_get_file_block
    jc .fail
    mov bx, disk_buffer
    pop edi
    call os_print_eax
    call os_ext2_load_block
    mov eax, [disk_buffer]
    call os_print_eax

    push ax
    mov ax, 0x0e0d
    int 10h
    mov ax, 0x0e0a
    int 010h
    pop ax

    jmp .ok
.fail:
    pop edi
    stc
    jmp .done
.ok:
    clc
.done:
    ret