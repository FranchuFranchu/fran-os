BITS 32
fs_offset dw 1
fs_start dw 0 ; In sectors

%define INODE_COUNT             [superblock_buffer+0]
%define BLOCK_COUNT             [superblock_buffer+4]
%define SUPERBLOCK_BLOCK        [superblock_buffer+20]
%define BLOCK_SIZE_LOG          [superblock_buffer+24]
%define BLOCKS_PER_GROUP        [superblock_buffer+32]
%define INODES_PER_GROUP        [superblock_buffer+40]
%define EXT2_SIGNATURE          [superblock_buffer+56]
%define INODE_SIZE              [superblock_buffer+88]

BLOCK_SIZE dw 0
BLOCK_SECTORS db 0
GROUP_COUNT dd 0

; IN = EAX: LBA, CL: Sector count, EBX: Buffer pointer
read_sectors:
    pusha
    mov edi, ebx
    and ecx, 0xFF
    mov esi, eax



.loopy:
    mov eax, ecx
    mov ecx, 1
    call kernel_ata_pio_read
    mov ecx, eax
    jc kernel_exception_fault

.busy:
    cmp dword [kernel_ata_pio_pointer_to_buffer], 0 ; Driver busy?
    jne .busy


    add edi, 512
    inc esi
    dec ecx
    cmp ecx, 0
    jne .loopy


    ; Poll until ready

    popa
    ret

kernel_fs_setup:
    pusha
    
    mov eax, 1
    mov edx, 0


.retry:
    ; Superblock is in LBA 2 if we don't have a MBR. 
    ; It can be LBA 3 if we do though, 
    ; or in any other if the disk is partitioned. 
    ; We will test for 2, 3, and 4 

    cmp edx, 4
    je .error_wrongfs


    


    mov cl, 2 ; Its size is 1024B
    mov ebx, superblock_buffer

    call read_sectors

    inc eax
    inc edx

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
    mov ecx, 0
    mov cx, SECTOR_SIZE
    div cx
    mov byte [BLOCK_SECTORS], al
    ; Calculate group count
    ; GROUP_COUNT = ceil(BLOCK_COUNT / BLOCKS_PER_GROUP)
    ; GROUP_COUNT = ceil(INODE_COUNT / INODES_PER_GROUP)
    ; It's a good idea to check both and compare them

    

    mov eax, BLOCK_COUNT
    mov ebx, BLOCKS_PER_GROUP
    mov edx, 0 
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
    mov word [fs_start], 1


    ; Now that the superblock is loaded,

    
    mov esi, .yessuperblock_msg
    call kernel_terminal_write_string


    popa
    ret



.error_wrongfs:
    mov esi, .nosuperblock_msg
    call kernel_terminal_write_string

    jmp kernel_halt
.error_unmatching_groupcount:
    mov esi, .unmatching_groupcount_msg
    call kernel_terminal_write_string

    jmp kernel_halt

.nosuperblock_msg db "Error: Ext2 Superblock not found. Make sure you have an unpartitioned ext2 hard disk mounted in hdb.",  0xa, 0
.yessuperblock_msg db "Ext2: Superblock loaded", 0xa, 0
.rootdir_success_msg db "Ext2: Root directory loaded", 0xa, 0
.unmatching_groupcount_msg db "Error: BLOCK_COUNT / BLOCKS_PER_GROUP != INODE_COUNT / INODES_PER_GROUP", 0xa, 0

; IN =  EAX: Inode number
; OUT = EAX: Group number
kernel_fs_get_inode_group:
    push edx
    push ebx

    ;  block group = (inode – 1) / INODES_PER_GROUP
    mov edx, 0 ; Clear garbage
    mov dword ebx, INODES_PER_GROUP ; Inodes per block group
    sub eax, 1
    div ebx 

    pop ebx
    pop edx
    ret

; IN =  EAX: Inode number
; OUT = EAX: Index inside block
kernel_fs_get_inode_index:
    push edx
    push ebx


    ; index = (inode – 1) % INODES_PER_GROUP
    mov edx, 0 ; Clean garbage

    mov dword ebx, INODES_PER_GROUP ; Inodes per block group
    sub eax, 1
    div ebx

    mov eax, edx


    pop ebx
    pop edx
    ret

; IN =  EAX: Inode number
; OUT = EAX: Block number
kernel_fs_get_inode_block:
    push edx
    push ebx

    mov edx, 0 ; Clean garbage
    
    ; containing block = (index * INODE_SIZE) / BLOCK_SIZE
    mov word bx, INODE_SIZE
    mul bx

    mov edx, 0 ; Clear garbage
    mov ebx, 0
    mov word bx, [BLOCK_SIZE]
    div ebx

    mov eax, ebx

    pop ebx
    pop edx
    ret

SECTOR_SIZE equ 512


; IN =  EAX: Block number. EDI: Sector offset (not usually needed)
; OUT = EAX: LBA address
kernel_fs_get_block_lba:
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


; IN =  EAX: Block group number, EBX: Buffer
; OUT = EBX contents and value changed to point to the start of the entry
kernel_fs_read_bgdt:
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
        call kernel_fs_get_block_lba
        jmp .load_table
    .block2:
        mov eax, 2
        call kernel_fs_get_block_lba
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

; IN =  EAX: Group number, EBX: Buffer
; OUT = EAX: Block address of start of inode table
kernel_fs_get_inode_table_block:
    push ebx
    call kernel_fs_read_bgdt
    mov eax, [ebx + 8]
    pop ebx
    ret
    
; IN =  EAX: Inode number, EBX: Buffer
; OUT = EBX points to the inode
kernel_fs_load_inode:
    push eax
    push ecx
    push edx
    push edi

    push eax ; Inode number
    call kernel_fs_get_inode_index

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


    call kernel_fs_get_inode_group
    call kernel_fs_get_inode_table_block

    add eax, ecx


    
    mov ebx, disk_buffer
    mov edi, 0
    call kernel_fs_load_block
    mov ebx, disk_buffer



    pop edx ; Byte offset

    mov eax, edx
    mov eax, disk_buffer
    add ebx, edx
    mov eax, ebx


    pop edi
    pop edx
    pop ecx
    pop eax


    ret

; Gets the location for the EAXth block that contains a file
; IN =  EAX: Block index, EBX: Buffer with the inode
; OUT = EAX: Block number
kernel_fs_get_file_block:
    push ebx
    push ecx
    push edx


    push eax
    ;inc eax ; To round up to closest multiple of [BLOCK_SIZE]
    mov ecx, 0
    mov edx, 0
    mov cx, [BLOCK_SIZE]

    mul ecx
    cmp [ebx+108], edx 
    jl .index_error; Requested block is larger than file
    cmp [ebx+4], eax 
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

    jmp kernel_halt


.direct_inode:
    shl eax, 1 ; multiply by two


    add ebx, eax
    mov eax, [ebx+40+eax]

    jmp .done
.indirect1_inode:
    push edx

    mov eax, [ebx + 88] ; Singly indirect block
    mov edi, 0
    add eax, 1
    ;mov eax, 0x17800 / 1024+1
    call kernel_fs_load_block
    mov ebx, disk_buffer

    mov eax, [ebx]

    pop edx

    sub edx, 12
    shl edx, 2

    add ebx, edx

    mov eax, [ebx]

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
kernel_fs_load_block:
        
    pusha

    call kernel_fs_get_block_lba
    mov ebx, disk_buffer 
    mov ecx, 0
    mov cl, [BLOCK_SECTORS]
    call read_sectors

    popa
    ret

; IN = EAX:  Parent directory inode number, ESI: Filename
; OUT = EAX: Subfile inode number
kernel_fs_get_subfile_inode:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov ebx, disk_buffer
    call kernel_fs_load_inode
    mov ecx, [ebx+4] ; File size
    mov eax, 0 ; Get data block index number 0 

.load_blocks:
    call kernel_fs_get_file_block
    mov edi, 0
    call kernel_fs_load_block
    mov ebx, disk_buffer



    mov ecx, 0x100
    push eax
    add ebx, 0xc
    .look_for_filename:
        push ecx ; look_for_filename counter

        mov eax, ebx

        mov edi, ebx
        add edi, 8

        mov ecx, 0
        mov cl, [ebx+6] ; Name length

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
        mov edi, ebx
        add edi, 8
        jmp .found_name

        .notequal:


        pop ecx
        pop esi

        mov eax, 0
        mov ax, [ebx+4]
        add ebx, eax

        pop ecx ; look_for_filename counter
        sub cx, ax ; Substract

        jnc .look_for_filename ; If no underflow, continue

    pop eax
    ; Filename not found yet?
    inc eax
    jmp .load_blocks
.found_name:
    pop eax
    mov eax, [ebx]
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
; OUT = EBX points to inode
kernel_fs_load_file_inode:
    push eax
    ; Fetch the root directory, and find the sub-file's inode.
    ; It's in inode 2
    mov eax, 2 
    mov ebx, disk_buffer
    call kernel_fs_get_subfile_inode


    ; Load the inode
    mov ebx, disk_buffer
    call kernel_fs_load_inode
    clc
    pop eax
    ret

; IN = EBX: points to the inode, EAX: Block number, EDI: Offset
; OUT = EBX points to the block, carry set if file size exceeded
kernel_fs_load_inode_block:
    push edi

    call kernel_fs_get_file_block
    jc .fail

    mov ebx, disk_buffer
    pop edi

    call kernel_fs_load_block
    mov ebx, disk_buffer

    jmp .ok
.fail:
    pop edi
    stc
    jmp .done
.ok:
    clc
.done:
    ret

kernel_fs_get_path_inode:
    push esi
    push ebx
    push edx

    mov ebx, esi
    mov edx, 2
    .find_slash:

        mov al, [ebx]

        cmp al, "/"
        je .is_slash
        cmp al, 0
        je .end
        jmp .next

        .is_slash:
            mov eax, edx
            call kernel_fs_get_subfile_inode
            mov edx, eax

            mov esi, ebx
            inc esi

            mov byte [ebx], "/"
        .next:
            inc ebx
            jmp .find_slash

.end:
    mov eax, edx
    call kernel_fs_get_subfile_inode

    pop edx
    pop ebx
    pop esi
    ret



superblock_buffer:
times 1024 db 0