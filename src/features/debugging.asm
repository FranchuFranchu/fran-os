; IN = ESI: Start location, ECX: Count in bytes

kernel_debug_dump_memory:
    pusha
    mov eax, 0
.dump:
    mov eax, 0
    mov al, [esi]

    call kernel_string_convert_2hex
    call kernel_terminal_putchar
    shr ax, 8
    call kernel_terminal_putchar

    inc esi
    dec ecx
    cmp ecx, 0
    jne .dump
    popa
    ret

kernel_debug_print_eax:
    push eax
    push ebx
    push eax
    ror eax, 16
    call kernel_string_convert_4hex
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8


    pop eax
    call kernel_string_convert_4hex
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8
    call kernel_terminal_putchar
    shr eax, 8
    pop ebx
    mov al, 0xa
    call kernel_terminal_putchar
    pop eax
    ret

; Carry, Parity, Auxiliary, Zero, Sign, Trap, Interrupt, Direction, Overflow
kernel_debug_print_flags:
    pusha
    pushfd
    pop edx
    mov eax, edx
    call kernel_debug_print_eax
    mov ebx, 0
    mov ecx, 0x80
.loopy:
    mov al, [ebx+.chars]
    cmp al, 0
    je .dontprint

    mov ecx, 1  ; mask 

    mov esi, ebx ; save register
    inc ebx
.shift:
    dec ebx
    shl ecx, 1
    cmp ebx, 0
    jne .shift

    shr ecx, 1

    mov ebx, esi ; restore
    mov esi, edx ; save

    and edx, ecx
    jnz .upper
.lower:

    jmp .restore
.upper:
    sub al, 0x20


.restore:
    call kernel_terminal_putchar
    mov edx, esi ; restore register

.dontprint:
    inc ebx
    cmp ebx, .charsend-.chars
    jne .loopy

    popa
    ret
.chars db "c", 0, "p", 0, "a", 0, "z", "s", "t", "i", "d", "o"
.charsend: