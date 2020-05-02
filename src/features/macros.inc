%macro dump_register_8bit 1
    push ax
    mov al, %1
    call kernel_string_convert_2hex
    call kernel_terminal_putchar
    shr ax, 8
    call kernel_terminal_putchar
    pop ax
%endmacro