BITS 32

%include "features/scancodes.inc"

os_keyboard_irq_handler: 
    push eax    ;; make sure you don't damage current state
    
    mov eax, 0
    in al,60h   ;; read information from the keyboard
    mov bl, 0x80
    and bl, al
    cmp bl, 0
    jne .keyup
    je .keydown

.keydown:
    mov ebx, scancode_to_lowercase
    add ebx, eax
    mov al, [ebx]
    call os_terminal_putchar
    jmp .done
.keyup:

.done:
    mov al,20h
    out 20h,al  ;; acknowledge the interrupt to the PIC
    pop eax     ;; restore state
    iret

os_keyboard_setup:

    mov eax, os_keyboard_irq_handler
    mov ebx, 21h
    call os_define_interrupt