BITS 32

%define MULTIBOOT_SIZE 16
%define BASE_OF_SECTION 0;0x100000 + MULTIBOOT_SIZE

%include "features/terminal.asm"
%include "features/keyboard.asm"
%include "features/string.asm"
%include "features/gdt.asm"
%include "features/idt.asm"
%include "features/eventqueue.asm"
%include "features/exception_handler.asm"
%include "features/font.asm"

global kernel_main
kernel_main:

    call os_idt_setup
    call os_keyboard_setup
    call os_eventqueue_setup
    call os_font_setup
    call os_terminal_setup
    call os_exception_handler_setup

    mov dh, VGA_COLOR_LIGHT_GREY
    mov dl, VGA_COLOR_BLACK
    call os_terminal_set_color
    mov al, "A"
    mov dh, 1
    mov dl, 2
    call os_terminal_putentryat



os_sleep:
    sti
.sleep:
    hlt
    jmp .sleep

os_halt:
    cli
.halt:
    hlt
    jmp .halt

    ret
    
; Ignored interrupt
os_unhandled_interrupt:
    push eax
    mov al,20h
    out 20h,al  ; acknowledge the interrupt to the PIC
    pop eax     ; restore state
    iret


    
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
