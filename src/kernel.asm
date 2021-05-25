; Memory map for FranOS
; - 0x00000000 to 0xC0000000 :
;   - userspace processes
; - 0xC0000000 to 0xFFFFFFFF :
;   - kernel



section .text
 
BITS 32

%define da dd
%define resa resd


%define MULTIBOOT_SIZE 16
%define BASE_OF_SECTION 0;0x100000 + MULTIBOOT_SIZE

%define KERNEL_BASE 0xC0000000

; Macros need to be defined early on
%include "features/misc macros.asm"

%include "features/idt.asm"
%include "features/acpi/rdsp.asm"
%include "features/cpuid.asm"
%include "features/data structures/vec.asm"
%include "features/debugging.asm"
%include "features/eventqueue.asm"
%include "features/exception_handler.asm"
%include "features/file descriptors/backends.asm"
%include "features/filesystem/ext2.asm"
%include "features/filesystem/path.asm"
%include "features/font.asm"
%include "features/gdt.asm"
%include "features/halt_for_key.asm"
%include "features/keyboard.asm"
%include "features/memory allocation/dlmalloc_binding.asm"
%include "features/multiprocessing/mp table.asm"
%include "features/paging/index.asm"
%include "features/storage/ata_pio.asm"
%include "features/string.asm"
%include "features/terminal.asm"
%include "features/userspace.asm"
%include "features/sysenter.asm"

extern kernel_multiboot_info_pointer
extern gdt_desc
global kernel_main
extern _kernel_end

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

    call kernel_font_setup
    call kernel_ata_pio_setup
    call kernel_sysenter_setup
    call kernel_fs_setup
    call kernel_userspace_setup

    call kernel_cpuid_print_vendor

    write_vga_graphics_register 0Ah, 1110b
    write_vga_graphics_register 0Bh, 1111b
    
    call kernel_multiprocessing_find_mp_table

    call kernel_set_break_setup ; Needs to be called after paging
    
    
    mov eax, 10
    call kernel_malloc
    
    mov eax, 2
    mov esi, .other_filename
    call kernel_fs_get_path_inode
    

    ; mov eax, 21 ; HACK
    mov ebx, disk_buffer
    call kernel_fs_load_inode
    
    mov esi, .samplestr
    mov edi, disk_buffer_2
    mov ecx, 32
    rep movsd
    
    mov esi, disk_buffer_2
    mov eax, 0
    mov edi, 0
    call kernel_fs_write_inode_block
    
    ; Load the init file
    mov eax, 2
    mov esi, .filename
    call kernel_fs_get_path_inode

    mov ebx, disk_buffer
    call kernel_fs_load_inode
    mov eax, 0

    call kernel_fs_load_inode_block

    ; Copy file contents to ring 3 address space

    call kernel_paging_new_user_page

    mov esi, disk_buffer
    mov edi, ebx
    mov ecx, 1024
    rep movsd
    
    jmp kernel_switch_to_userspace


.filename db "Packages/Init/bin/init", 0
.other_filename db "testdir/file.txt"
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

align 16
disk_buffer:
    times 2048   db 0
    
align 16
disk_buffer_2:
    times 2048   db 0
hello_string db "Hello, kernel World!", 0xA, 0 ; 0xA = line feed
