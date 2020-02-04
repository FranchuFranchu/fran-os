BITS 32

%define MULTIBOOT_SIZE 16
%define BASE_OF_SECTION 0;0x100000 + MULTIBOOT_SIZE

%include "features/terminal.asm"
%include "features/keyboard.asm"
%include "features/string.asm"
%include "features/gdt.asm"
%include "features/idt.asm"

global kernel_main
kernel_main:


    call os_idt_setup

    call os_keyboard_setup

    mov eax, os_unhandled_interrupt
    mov ebx, 20h
    call os_define_interrupt

    mov dh, VGA_COLOR_LIGHT_GREY
    mov dl, VGA_COLOR_BLACK
    call os_terminal_set_color

    mov cx, 0

    mov byte [0xB8400], "s "

    ;jmp .halt

    .printkeys:
    call os_terminal_putchar
    inc cx
    mov al, cl
    call os_string_convert_1hex
    call os_terminal_putchar
    cmp cx, 64
    jne .printkeys
    
    sti
    .halt:
    hlt
    jmp .halt
    
; Ignored interrupt
os_unhandled_interrupt:
    push eax
    mov al,20h
    out 20h,al  ; acknowledge the interrupt to the PIC
    pop eax     ; restore state
    iret



    
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
