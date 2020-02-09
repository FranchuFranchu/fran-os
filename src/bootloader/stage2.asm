bits 16
[org 0x7E00]
abs_start:
jmp start

%include "modules/a20.asm"
%include "modules/unrealmode.asm"
;%include "modules/fat.asm"
%include "modules/protectedmode.asm"
BITS 16
drive_number db 0

kernel_size db 32 ; In sectors

start:
    mov [drive_number], dl
    mov si, bootloader_success
    call print_string
        
    call enable_a20

    jmp unreal_start ; It will jump back to us
in_unreal:
    mov si, unreal_success
    call print_string
.readsectors:
    mov dl, [drive_number]
    mov ah, 0
    int 13h
  
    inc byte [retry_count]

    mov ax, 0
    mov es, ax
    mov bx, disk_buffer


    mov ah, 02h
    mov al, [kernel_size]
    mov dl, [drive_number]
    mov ch, 0
    mov cl, 17 ;Sector 17 is LBA 16
    mov dh, 0

    int 13h


    jc .readsectors

load_kernel:

    mov si, kernel_success
    call print_string


    jmp pm_start

%include "stage3.asm"

BITS 16

bootloader_success db "Bootloader: Loaded correctly", 0xa, 0xd, 0
unreal_success db "Unreal Mode: Switched correctly", 0xa, 0xd, 0
kernel_success db "Kernel: Loaded correctly", 0xa, 0xd, 0

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

;times (($-abs_start) % 512 - 4) db 21
disk_buffer:
times 64*512 db 0