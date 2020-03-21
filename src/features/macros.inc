%macro dump_register_8bit 1
    push ax
    mov al, %1
    call os_string_convert_2hex
    call os_terminal_putchar
    shr ax, 8
    call os_terminal_putchar
    pop ax
%endmacro