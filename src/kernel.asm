; Memory map for FranOS
; - 0x00000000 to 0xC0000000 :
;   - userspace programs



section .text

BITS 32

%define MULTIBOOT_SIZE 16
%define BASE_OF_SECTION 0;0x100000 + MULTIBOOT_SIZE

%include "features/idt.asm"

%include "features/cpuid.asm"
%include "features/debugging.asm"
%include "features/eventqueue.asm"
%include "features/exception_handler.asm"
%include "features/filesystem/ext2.asm"
%include "features/font.asm"
%include "features/gdt.asm"
%include "features/halt_for_key.asm"
%include "features/keyboard.asm"
%include "features/paging.asm"
%include "features/storage/ata_pio.asm"
%include "features/string.asm"
%include "features/terminal.asm"
%include "features/userspace.asm"
%include "features/sysenter.asm"

extern kernel_multiboot_info_pointer
extern gdt_desc
global kernel_main
kernel_main:
    lgdt [kernel_gdt_desc]

    call kernel_terminal_setup
    call kernel_terminal_clear_screen

    mov dh, VGA_COLOR_LIGHT_GREY
    mov dl, VGA_COLOR_BLACK
    call kernel_terminal_set_color

    call kernel_idt_setup
    call kernel_exception_handler_setup
    call kernel_keyboard_setup
    call kernel_paging_setup
    ;call kernel_font_setup
    call kernel_ata_pio_setup
    call kernel_sysenter_setup
    call kernel_fs_setup
    call kernel_userspace_setup

    mov eax, 2
    mov esi, .filename
    call kernel_fs_get_subfile_inode

    mov ebx, disk_buffer
    call kernel_fs_load_inode
    mov eax, 0

    call kernel_fs_load_inode_block


    mov ebx, disk_buffer


    ; Copy file contents to ring 3 address space
    mov esi, disk_buffer
    mov edi, 0
    mov ecx, 1024
    rep movsd


    mov ebx, 0
    call kernel_switch_to_userspace


    jmp kernel_sleep

    
.dirname db "testdir", 0
.filename db "test.bin", 0

kernel_sleep:
    sti
.sleep:
    hlt
    jmp .sleep

cpuid_not_supported:
kernel_halt:
    cli
.halt:
    hlt
    jmp .halt

    ret

kernel_void_idt:
    dq 0

kernel_restart:
    ; Purposefully triple fault CPU
    lidt [kernel_void_idt]
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


kernel_shutdown:
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

    mov byte [kernel_terminal_color], 0x0C
    mov byte [kernel_terminal_column], 0
    mov byte [kernel_terminal_row], 1
    mov esi, .errstr
    call kernel_terminal_write_string
    jmp kernel_halt

    .errstr db "Unimplemented. Use the hardware power button.", 0


; Ignored interrupt
kernel_unhandled_interrupt:
    push eax
    mov al,20h
    out 20h,al  ; acknowledge the interrupt to the PIC
    pop eax     ; restore state
    iret

disk_buffer:
    times 2048   db 0
    
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
