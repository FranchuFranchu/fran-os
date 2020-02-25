BITS 16
[org 0x7e00]

abs_start:
jmp start
db "Stage 2: Loaded", 0

%include "modules/a20.asm"
%include "modules/unrealmode.asm"
%include "modules/ext2.asm"
%include "modules/misc.asm"
%include "modules/protectedmode.asm"

BITS 32
%include "stage3.asm"

BITS 16

drive_number db 0
KERNEL_SIZE dd 0 ; In blocks


start:
    mov [drive_number], dl
    mov si, bootloader_success
    call print_string
        
    call enable_a20

    jmp unreal_start ; It will jump back to us
in_unreal:
    mov si, unreal_success
    call print_string
    call os_ext2_setup


    mov eax, 0
    push eax
    jmp .postadd
.read_sectors:
    pop eax
    inc eax
    push eax

.postadd:
    mov si, filename
    mov bx, disk_buffer

    call os_ext2_load_file_inode

    mov edi, 1
    call os_ext2_load_inode_block
    jc .done


    ; Copy to kernel_buffer
    mov ecx, 0
    mov cx, [BLOCK_SIZE]
    mov esi, disk_buffer
    mov edi, kernel_buffer
    pop eax
    push eax
    push eax

    mul ecx

    add edi, eax
    pop eax

.copy:
    mov al, [esi]
    mov [edi], al
    dec ecx
    inc esi
    inc edi
    cmp ecx, 0
    jne .copy

.done_copy:
    jmp .read_sectors

.done:
    pop eax

    mov [KERNEL_SIZE], eax

    mov si, kernel_success
    call print_string


load_kernel:

    mov si, kernel_success
    call print_string


    jmp pm_start

filename db "kernel.bin", 0


print_string:     ; Routine: output string in SI to screen
  mov ah, 0Eh   ; int 10h 'print char' function

.repeat:
  lodsb     ; Get character from string
  cmp al, 0
  je .done    ; If char is zero, end of string
  int 10h     ; Otherwise, print it
  jmp .repeat

.done:
  ret
retry_count db 0

halt:
  cli 
.halt:
  hlt
  jmp .halt

;times (($-abs_start) % 512 - 4) db 21

where_to_load equ disk_buffer
bootloader_success db "Bootloader: Loaded correctly", 0xa, 0xd, 0
unreal_success db "Unreal Mode: Switched correctly", 0xa, 0xd, 0
kernel_success db "Kernel: Loaded correctly", 0xa, 0xd, 0

superblock_buffer:
times 1024 db 0
disk_buffer:
times 512*8 db 0
kernel_size dd 0 ; in bytes
kernel_buffer: ; Stores the kernel until stage3.asm copies it
times 200*1024 db 0