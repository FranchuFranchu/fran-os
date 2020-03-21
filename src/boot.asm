; Declare constants for the multiboot header.
MBALIGN  equ  1 << 0            ; align loaded modules on page boundaries
MEMINFO  equ  1 << 1            ; provide memory map
FLAGS    equ  MBALIGN | MEMINFO ; this is the Multiboot 'flag' field
MAGIC    equ  0x1BADB002        ; 'magic number' lets bootloader find the header
CHECKSUM equ -(MAGIC + FLAGS)   ; checksum of above, to prove we are multiboot

; Offset which boot.asm is built with
KERNEL_VIRTUAL_BASE equ 0xC0000000                  ; 3GB
KERNEL_PAGE_NUMBER equ (KERNEL_VIRTUAL_BASE >> 22)  ; Page directory index of kernel's 4MB PTE.

; Declare a multiboot header that marks the program as a kernel. These are magic
; values that are documented in the multiboot standard. The bootloader will
; search for this signature in the first 8 KiB of the kernel file, aligned at a
; 32-bit boundary. The signature is in its own section so the header can be
; forced to be within the first 8 KiB of the kernel file.
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM
 
; The multiboot standard does not define the value of the stack pointer register
; (esp) and it is up to the kernel to provide a stack. This allocates room for a
; small stack by creating a symbol at the bottom of it, then allocating 16384
; bytes for it, and finally creating a symbol at the top. The stack grows
; downwards on x86. The stack is in its own section so it can be marked nobits,
; which means the kernel file is smaller because it does not contain an
; uninitialized stack. The stack on x86 must be 16-byte aligned according to the
; System V ABI standard and de-facto extensions. The compiler will assume the
; stack is properly aligned and failure to align the stack will result in
; undefined behavior.
section .bss
align 16
stack_bottom:
resb 16384 ; 16 KiB
stack_top:

section .data
align 0x1000
global page_directory
page_directory:
    ; This page directory entry identity-maps the first 4MB of the 32-bit physical address space.
    ; All bits are clear except the following:
    ; bit 7: PS The kernel page is 4MB.
    ; bit 1: RW The kernel page is read/write.
    ; bit 0: P  The kernel page is present.
    ; This entry must be here -- otherwise the kernel will crash immediately after paging is
    ; enabled because it can't fetch the next instruction! It's ok to unmap this page later.
    dd 0x00000083
    times (KERNEL_PAGE_NUMBER - 1) dd 0                 ; Pages before kernel space.
    ; Define three entries for a 16MiB kernel

    dd 0x00000083
    dd 0x00400083
    dd 0x00800083
    dd 0x00C00083
    times (1024 - KERNEL_PAGE_NUMBER - 1) dd 0  ; Pages after the kernel image.
 
; The linker script specifies _start as the entry point to the kernel and the
; bootloader will jump to this position once the kernel has been loaded. It
; doesn't make sense to return from this function as the bootloader is gone.
; Declare _start as a function symbol with the given symbol size.
section .text


gdt:
 
gdt_null:
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0
 
gdt_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 10011010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

gdt_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 10010010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0x0

gdt_stack:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0xFFFF
 
  .base_16_23 db 0xFF
  .access db 10010110b
  .limit_and_flags db 11001111b
  .base_24_31 db 0xFF
gdt_end:
 
gdt_desc:
   dw gdt_end - gdt - 1
   dd gdt-KERNEL_VIRTUAL_BASE


; IN = EAX: Page table address (4KiB aligned), EBX: Future location of PDT, AL: Flags
%define os_paging_make_pde mov [ebx], eax

; IN = EAX: Physical address to map to (4KiB aligned) address, EBX: Future location of PDT, AL: Flags
%define os_paging_make_pte mov [ebx], eax

; OUT = AL: Common page flags
%define os_paging_set_default_page_flags mov al, 111b

global os_multiboot_info_pointer
os_multiboot_info_pointer dd 0

global _start:function (_start.end - _start)
_start:
    ; The bootloader has loaded us into 32-bit protected mode on a x86
    ; machine. Interrupts are disabled. Paging is disabled. The processor
    ; state is as defined in the multiboot standard. The kernel has full
    ; control of the CPU. The kernel can only make use of hardware features
    ; and any code it provides as part of itself. There's no printf
    ; function, unless the kernel provides its own <stdio.h> header and a
    ; printf implementation. There are no security restrictions, no
    ; safeguards, no debugging mechanisms, only what the kernel provides
    ; itself. It has absolute and complete power over the
    ; machine.
 
    ; This is a good place to initialize crucial processor state before the
    ; high-level kernel is entered. It's best to minimize the early
    ; environment where crucial features are offline. Note that the
    ; processor is not fully initialized yet: Features such as floating
    ; point instructions and instruction set extensions are not initialized
    ; yet. The GDT should be loaded here. Paging should be enabled here.
    ; C++ features such as global constructors and exceptions will require
    ; runtime support to work as well.
     
    mov dword [0xB8000], "s 1 "
    
    add ebx, KERNEL_VIRTUAL_BASE
    mov [os_multiboot_info_pointer - KERNEL_VIRTUAL_BASE], ebx
    
    mov esp, stack_top-KERNEL_VIRTUAL_BASE
    cli
    .os_gdt_setup:
        lgdt [gdt_desc-KERNEL_VIRTUAL_BASE]  ;load GDT
    mov ax, 0x10
    mov ds, ax

    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp 0x08:.update_stack-KERNEL_VIRTUAL_BASE
    .update_stack:
      mov ax, 0x10
      mov ss, ax
      ; To set up a stack, we set the esp register to point to the top of our
      ; stack (as it grows downwards on x86 systems). This is necessarily done
      ; in assembly as languages such as C cannot function without a stack.

      mov esp, stack_top-KERNEL_VIRTUAL_BASE

    mov dword [0xB8000], "s 2 "

    ; NOTE: Until paging is set up, the code must be position-independent and use physical
    ; addresses, not virtual ones!
    mov ecx, (page_directory - KERNEL_VIRTUAL_BASE)
    mov cr3, ecx                                        ; Load Page Directory Base Register.
 
    mov ecx, cr4
    or ecx, 0x00000010                          ; Set PSE bit in CR4 to enable 4MB pages.
    mov cr4, ecx
 
    mov ecx, cr0
    or ecx, 0x80000000                          ; Set PG bit in CR0 to enable paging.
    mov cr0, ecx
 
    mov dword [0xB8000], "s 3 "

    ; Start fetching instructions in kernel space.
    ; Since eip at this point holds the physical address of this command (approximately 0x00100000)
    ; we need to do a long jump to the correct virtual address of StartInHigherHalf which is
    ; approximately 0xC0100000.
    lea ecx, [.on_higher_half]
    jmp ecx                                                     ; NOTE: Must be absolute jump!
 
.on_higher_half:
 

    ;mov dword [page_directory], 0
    ;invlpg [0]
 

    ; NOTE: From now on, paging should be enabled. The first 4MB of physical address space is
    ; mapped starting at KERNEL_VIRTUAL_BASE. Everything is linked to this address, so no more
    ; position-independent code or funny business with virtual-to-physical address translation
    ; should be necessary. We now have a higher-half kernel.
    mov esp, stack_top           ; set up the stack
    push eax                           ; pass Multiboot magic number
 
    ; pass Multiboot info structure -- WARNING: This is a physical address and may not be
    ; in the first 4MB!
    push ebx
 
    mov dword [0xC00B8000], "s 4 "

    ; Enter the high-level kernel. The ABI requires the stack is 16-byte
    ; aligned at the time of the call instruction (which afterwards pushes
    ; the return pointer of size 4 bytes). The stack was originally 16-byte
    ; aligned above and we've since pushed a multiple of 16 bytes to the
    ; stack since (pushed 0 bytes so far) and the alignment is thus
    ; preserved and the call is well defined.
        ; note, that if you are building on Windows, C functions may have "_" prefix in assembly: _kernel_main
    extern kernel_main
    jmp kernel_main
 
    ; If the system has nothing more to do, put the computer into an
    ; infinite loop. To do that:
    ; 1) Disable interrupts with cli (clear interrupt enable in eflags).
    ;    They are already disabled by the bootloader, so this is not needed.
    ;    Mind that you might later enable interrupts and return from
    ;    kernel_main (which is sort of nonsensical to do).
    ; 2) Wait for the next interrupt to arrive with hlt (halt instruction).
    ;    Since they are disabled, this will lock up the computer.
    ; 3) Jump to the hlt instruction if it ever wakes up due to a
    ;    non-maskable interrupt occurring or due to system management mode.
    cli
.hang:  hlt
    jmp .hang
.end:
