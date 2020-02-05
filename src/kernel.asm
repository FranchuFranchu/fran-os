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
%include "features/halt_for_key.asm"

global kernel_main
kernel_main:

    call os_idt_setup
    call os_exception_handler_setup

    call os_keyboard_setup
    call os_eventqueue_setup
    call os_font_setup
    call os_terminal_setup


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

os_void_idt:
    dq 0

os_restart:
    ; Purposefully triple fault CPU
    lidt [os_void_idt]
    ; Debug info for confused people trying to figure out why did it triple fault
    mov eax, 0x000A5C11
    mov ebx, "Rebo"
    mov ecx, "otin"
    mov edx, "g by"
    mov esi, "trip"
    mov edi, "le f"
    mov ebp, "ault"
    mov esp, "    "

    int 0xFF ; anything will work


os_shutdown:
    ; This just works on QEMU and BOCHS, won't work on real computers
    mov dx, 0xB004
    mov ax, 0x0020
    out dx, al
    shr ax, 8
    out dx, al
    ; Else, try this
    mov dx, 0x604
    mov ax, 0x0020
    out dx, al
    shr ax, 8
    out dx, al

    mov byte [os_terminal_color], 0x0C
    mov byte [os_terminal_column], 0
    mov byte [os_terminal_row], 1
    mov esi, .errstr
    call os_terminal_write_string
    jmp os_halt

    .errstr db "Unimplemented. Use the hardware power button.", 0


; Ignored interrupt
os_unhandled_interrupt:
    push eax
    mov al,20h
    out 20h,al  ; acknowledge the interrupt to the PIC
    pop eax     ; restore state
    iret


    
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
