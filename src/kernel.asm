; Memory map for FranOS
; - 0x00000000 to 0xC0000000 :
;   - userspace processes
; - 0xC0000000 to 0xFFFFFFFF :
;   - userspace processes



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
%include "features/filesystem/path.asm"
%include "features/font.asm"
%include "features/gdt.asm"
%include "features/halt_for_key.asm"
%include "features/keyboard.asm"
%include "features/paging/index.asm"
%include "features/pci.asm"
%include "features/storage/ata_pio.asm"
%include "features/string.asm"
%include "features/terminal.asm"
%include "features/usb.asm"
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
    call kernel_pci_setup

    call kernel_idt_setup
    call kernel_exception_handler_setup
    call kernel_keyboard_setup
    call kernel_paging_setup

    ;call kernel_font_setup
    call kernel_ata_pio_setup
    call kernel_sysenter_setup
    call kernel_fs_setup
    call kernel_userspace_setup
    call kernel_usb_setup


    write_vga_graphics_register 0Ah, 1110b
    write_vga_graphics_register 0Bh, 1111b

%ifdef COMMENT
    push eax
    push ebx ; Address of inode 


    mov esi, .samplestr
    mov ecx, kernel_sleep - .samplestr
    mov edi, kernel_block_sized_buffer
    rep movsd



    mov eax, 0
    mov ebx, kernel_block_sized_buffer
    mov edi, kernel_fs_disk_buffer
    call kernel_fs_create_or_override_inode_block


    pop ebx

    sub ebx, kernel_fs_disk_buffer



    add ebx, edi

    mov eax, 0x3
    call kernel_fs_set_file_size

    pop eax



    mov eax, 2
    mov esi, .test_filename
    call kernel_fs_get_path_inode
    call kernel_debug_print_eax
    

    mov ebx, kernel_fs_disk_buffer
    call kernel_fs_load_inode
    mov ebx, kernel_fs_disk_buffer

    xchg bx, bx

    mov esi, kernel_fs_disk_buffer
    mov edi, kernel_fs_second_disk_buffer
    mov ecx, 1024
    rep movsd
    
    ret
    mov ebx, kernel_fs_second_disk_buffer
    call kernel_fs_write_inode

    mov dword [0xC00B8000], "e n "
    jmp kernel_sleep
    ret
%endif
    ; Load userspace program




    mov eax, 2
    mov esi, .userspace_filename
    call kernel_fs_get_path_inode

    call kernel_debug_print_eax    

    mov ebx, kernel_fs_disk_buffer
    call kernel_fs_load_inode
    mov eax, 0

    call kernel_fs_load_inode_block

    ; Copy file contents to ring 3 address space
    call kernel_paging_new_user_page

    mov esi, kernel_fs_disk_buffer
    mov edi, ebx
    mov ecx, 1024
    rep movsd

    jmp kernel_switch_to_userspace


.userspace_filename db "core_packages/init", 0
.test_filename db "testdir/file.txt", 0
.samplestr db "The mitochondria is the powerhouse of the cell", 0

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
    mov ax, 0x2000
    out dx, ax
    ; Else, try this
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax

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

kernel_block_sized_buffer:
    times 1024 db 0
    
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
