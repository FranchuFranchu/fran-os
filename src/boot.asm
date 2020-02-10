BITS 32
[org 0x100000]
jmp after_kernel_loaded

db "Kernel: Loading confirmed", 0


 
; The linker script specifies _start as the entry point to the kernel and the
; bootloader will jump to this position once the kernel has been loaded. It
; doesn't make sense to return from this function as the bootloader is gone.
; Declare _start as a function symbol with the given symbol size.





after_kernel_loaded:
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
    
    mov esp, stack_top

    cli
    .os_gdt_setup:
        lgdt [gdt_desc]  ;load GDT
    mov ax, 0x10
    mov ds, ax

    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp 0x08:.update_stack
    .update_stack:
      mov ax, 0x10
      mov ss, ax
      ; To set up a stack, we set the esp register to point to the top of our
      ; stack (as it grows downwards on x86 systems). This is necessarily done
      ; in assembly as languages such as C cannot function without a stack.

      mov esp, stack_top
    
    ; Enter the high-level kernel. The ABI requires the stack is 16-byte
    ; aligned at the time of the call instruction (which afterwards pushes
    ; the return pointer of size 4 bytes). The stack was originally 16-byte
    ; aligned above and we've since pushed a multiple of 16 bytes to the
    ; stack since (pushed 0 bytes so far) and the alignment is thus
    ; preserved and the call is well defined.
    ; note, that if you are building on Windows, C functions may have "_" prefix in assembly: _kernel_main
    
    call kernel_main
 
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
   dd gdt

%include "kernel.asm"


align 16
stack_bottom:
times 16384 db 0
stack_top: