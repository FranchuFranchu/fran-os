os_halt_for_key_keypressed db 0

os_halt_for_key:
    ; Only accept a single key input, then un-halt. Used in exceptions
    cli

    in al, PIC1_DATA
    and al, 0xFD
    out PIC1_DATA, al
    in al, PIC2_DATA
    and al, 0xFD
    out PIC2_DATA, al

    mov eax, os_halt_for_key_irq_handler
    mov ebx, 21h
    call os_define_interrupt

    sti
.halt:
    hlt
    ; We received a keypress

    
.done:
    call pic_clear_mask

    mov eax, os_keyboard_irq_handler
    mov ebx, 21h
    call os_define_interrupt
    
    in al, 0x60
    and eax, 0x7F
    mov ebx, eax

    mov al, [scancode_to_lowercase+ebx]
    

    ret

os_halt_for_key_irq_handler:
    mov byte [os_halt_for_key_keypressed], 0xFF
    
    mov al,20h
    out 20h,al  ;; acknowledge the interrupt to the PIC
    
    iret
