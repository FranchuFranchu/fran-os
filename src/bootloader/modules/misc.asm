
; IN = AL: Number to write
; OUT = AL: As a character
kernel_string_convert_1hex:
    and al, 0xF ; Mask out higher nibble

    push ax
    sub al, 0x9
    jng .number
.notnumber: ; A-F
    pop ax
    ; ascii 41 = A
    sub al, 0xA

    add al, "A"
    jmp .done

.number:
    pop ax
    add al, "0"

.done:
    ret

; IN = AL: Number to write
; OUT = AX: As two characters
kernel_string_convert_2hex:
    push edx

    push eax
    mov edx, 0

    call kernel_string_convert_1hex
    or dl, al

    pop eax
    shr eax, 4
    call kernel_string_convert_1hex
    shl edx, 8
    or dl, al
    mov eax, edx

    pop edx
    ret


; IN = AX: Number to write
; OUT = EAX: As four characters
kernel_string_convert_4hex:
    push edx

    push eax
    mov edx, 0

    call kernel_string_convert_2hex
    or dx, ax

    pop eax
    shr eax, 8
    call kernel_string_convert_2hex
    shl edx, 16
    or dx, ax
    mov eax, edx

    pop edx
    ret

kernel_print_eax:
    push eax
    push ebx
    ror eax, 16
    push eax

    call kernel_string_convert_4hex
    mov ebx, eax


    mov eax, ebx
    mov ah, 0Eh
    int 10h

    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8

    pop eax
    shr eax, 16

    call kernel_string_convert_4hex

    mov ebx, eax
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8
    mov eax, ebx
    mov ah, 0Eh
    int 10h
    
    shr ebx, 8

    mov ax, 0x0E20
    int 10h

    pop ebx
    pop eax
    ret
