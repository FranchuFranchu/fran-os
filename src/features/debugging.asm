; IN = ESI: Start location, ECX: Count in bytes

os_debug_dump_memory:
    pusha
    mov eax, 0
.dump:
    mov eax, 0
    mov al, [esi]

    call os_string_convert_2hex
    call os_terminal_putchar
    shr ax, 8
    call os_terminal_putchar

    inc esi
    dec ecx
    cmp ecx, 0
    jne .dump
    popa
    ret

os_debug_print_eax:
    push eax
    push ebx
    push eax
    ror eax, 16
    call os_string_convert_4hex
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8


    pop eax
    call os_string_convert_4hex
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar
    shr eax, 8
    pop ebx
    mov al, 0xa
    call os_terminal_putchar
    pop eax
    ret

; Carry, Parity, Auxiliary, Zero, Sign, Trap, Interrupt, Direction, Overflow
os_debug_print_flags:
    pusha
    pushfd
    pop edx
    mov eax, edx
    call os_debug_print_eax
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
    call os_terminal_putchar
    mov edx, esi ; restore register

.dontprint:
    inc ebx
    cmp ebx, .charsend-.chars
    jne .loopy

    popa
    ret
.chars db "c", 0, "p", 0, "a", 0, "z", "s", "t", "i", "d", "o"
.charsend: