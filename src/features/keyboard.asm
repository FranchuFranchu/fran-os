BITS 32

PS2_KEYBOARD_RESEND equ 0xFE
PS2_KEYBOARD_ACK equ 0xFA
PS2_KEYBOARD_PREFERRED_SCANCODE_SET equ 1

KEYBOARD_FLAG_LSHIFT equ 10b
KEYBOARD_FLAG_LCTRL equ  1b

KEYBOARD_TOGGLE_CAPSLOCK equ  1b


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
    db 0 ; -       , RShift,   
    db 0 ; LControl, LShift, LAlt
os_togglekey_states:
    db 0 ; Caps Lock, Num lock, Scroll lock

os_keyboard_setup:

    mov eax, os_keyboard_irq_handler
    mov ebx, 21h
    call os_define_interrupt

    ;mov dword [os_eventqueue_on_next_tick_vectors], os_keyboard_phase_1
    ; Disabled due to bug

    ret
os_keyboard_send_next_byte:
    call os_terminal_putchar
    out 60h, al
    ret

os_keyboard_phase_1:
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
    je .keydown
    jmp .keyup

.keydown:
    and eax, 0x7F
    mov ebx, eax

    mov al, [scancode_to_lowercase+ebx]
    
    call os_keyboard_keydown ; Call the high-level handler

    jmp .done
.keyup:
    and eax, 0x7F
    mov ebx, eax

    mov al, [scancode_to_lowercase+ebx]
    
    call os_keyboard_keyup ; Call the high-level handler

    jmp .done

.done: 
    mov al,20h
    out 20h,al  ;; acknowledge the interrupt to the PIC

    popa    ;; restore state
    iret

os_keyboard_update_led:
    ret

os_keyboard_keydown:
    cmp al, 0
    je .unknownkey

    mov bl, al
    not bl

    mov al, bl
    not al
    test al, 0x80
    jz .asciikey ; Shift, alt, etc.

    mov al, bl
    test al, 0xB0
    jz .controlkey ; Shift, alt, etc.

    mov al, bl
    test al, 0xE0
    jz .togglekey ; Capslock, numlock


    mov al, bl
    test al, 0xD0
    jz .functionkey ; F1:F12

.unknownkey:
    mov al, 0xFF

.asciikey:

    mov dx, [os_controlkey_states]
    and dx, KEYBOARD_FLAG_LSHIFT
    shr dx, 1

    mov cx, [os_togglekey_states]
    and cx, KEYBOARD_TOGGLE_CAPSLOCK

    xor cx, dx ; capitalize = XOR(shift, capslock)

    cmp cl, 0
    je .lowercase

    xor ebx, ebx
    mov bl, al
    mov ebx, [ebx+ascii_to_uppercase] 
    xchg bl, al
    cmp al, 0
    jne .lowercase

    .lowercase:

    call os_terminal_putchar
    jmp .done

.controlkey:
    mov dx, [os_controlkey_states]
    and al, 0xF
    mov bx, 1000000000000000b ; OR Mask
    .shift_until_done:

        shr bx, 1
        dec al
        cmp al, 0
        jne .shift_until_done

    or dx, bx
    mov [os_controlkey_states], dx
    jmp .done
.togglekey:
    
    mov dx, [os_togglekey_states]
    and al, 0xF
    mov bx, 1000000000000000b ; OR Mask
    .shift_until_done_toggle:

        shr bx, 1
        dec al
        cmp al, 0
        jne .shift_until_done_toggle

    
    and dx, bx

    jz .cleared_to_set
    jnz .set_to_cleared

.cleared_to_set:
    mov dx, [os_togglekey_states]
    or dx, bx
    jmp .save
.set_to_cleared:
    mov dx, [os_togglekey_states]
    not bx
    and dx, bx
.save:
    mov [os_togglekey_states], dx

    call os_keyboard_update_led

    jmp .done

.functionkey:
    jmp .done
.done:
    ret




os_keyboard_keyup:
    cmp al, 0
    je .unknownkey

    mov bl, al
    not bl

    mov al, bl
    not al

    pusha
    %ifdef c

    call os_string_convert_2hex
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar

    %endif
    popa

    test al, 0x80
    jz .asciikey ; Shift, alt, etc.

    mov al, bl
    test al, 0xB0
    jz .controlkey ; Shift, alt, etc.

    mov al, bl
    test al, 0xE0
    jz .togglekey ; Capslock, numlock


    mov al, bl
    test al, 0xD0
    jz .functionkey ; F1:F12

.unknownkey:
    mov al, 0xFF

.asciikey:
    jmp .done

.controlkey:
    mov dx, [os_controlkey_states]
    and al, 0xF
    mov bx, 0111111111111111b ; AND Mask
    .shift_until_done:

        shr bx, 1
        dec al
        cmp al, 0
        jne .shift_until_done

    and dx, bx
    mov [os_controlkey_states], dx
    jmp .done
.togglekey:
    jmp .done
.functionkey:
    jmp .done
.done:
    ret