BITS 32

PS2_KEYBOARD_RESEND equ 0xFE
PS2_KEYBOARD_ACK equ 0xFA
PS2_KEYBOARD_PREFERRED_SCANCODE_SET equ 2


%include "features/scancodes.inc"

os_keyboard_event_queue:
    dd os_keyboard_send_next_byte
    db 10h
    db 10h
    db 0 ; Align
    db 0

    times 10h dd 0

os_keyboard_driver_state db 0
; 0 = must send scancode set command
; 1 = must send scancode number (3)
; 0xF = received bytes are now scancodes

os_controlkey_states:

os_keyboard_send_next_byte:
    call os_terminal_putchar
    out 60h, al
    ret

os_keyboard_phase_1:
    mov al, "a"
    call os_terminal_putchar
    mov byte [os_keyboard_driver_state], 0x1
    mov al, 0xF0
    out 60h, al
    mov dword [os_eventqueue_on_next_tick_vectors], os_keyboard_phase_2
    ret

os_keyboard_phase_2:
    in al,60h   ;; read information from the keyboard
    cmp al, PS2_KEYBOARD_RESEND
    je .number_resend

    cmp al, PS2_KEYBOARD_ACK
    je .number_ack

    jmp .number_ack

    .number_resend:
        mov al, 0xF0
        out 0x60, al
        ret

    .number_ack:
        mov al, "b"
        call os_terminal_putchar
        mov al, PS2_KEYBOARD_PREFERRED_SCANCODE_SET
        out 0x60, al

        mov dword [os_eventqueue_on_next_tick_vectors], 0

        mov byte [os_keyboard_driver_state], 0xF
        ret

os_keyboard_irq_handler: 
    pusha
    in al, 0x60

.read_scancode:
    cmp al, PS2_KEYBOARD_RESEND
    je .scn_resend
    jne .else

    .scn_resend:
        mov al, PS2_KEYBOARD_PREFERRED_SCANCODE_SET
        out 0x60, al
        jmp .done
    .else:

    cmp al, PS2_KEYBOARD_ACK
    je .done

    mov bl, 0x80
    and bl, al
    cmp bl, 0
    je .keyup
    jmp .keydown

.keydown:
    and eax, 0x7F
    mov ebx, eax

    mov al, [scancode_to_lowercase+ebx]
    
    call os_keyboard_keydown ; Call the high-level handler

    jmp .done
.keyup:

.done: 
    mov al,20h
    out 20h,al  ;; acknowledge the interrupt to the PIC

    popa    ;; restore state
    iret

os_keyboard_keydown:
    cmp al, 0
    jne .else
    mov al, 0xFF
    .else:
    call os_terminal_putchar
    ret

os_keyboard_setup:

    mov eax, os_keyboard_irq_handler
    mov ebx, 21h
    call os_define_interrupt

    mov dword [os_eventqueue_on_next_tick_vectors], os_keyboard_phase_1
    

    ret