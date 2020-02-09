os_fs_setup:
    mov edi, os_fs_buffer
    mov esi, 65
    mov ecx, 1
    call os_ata_pio_read
    mov dword [os_eventqueue_on_next_tick_vectors], start_dumping
    ret

counter dw 0xFF

start_dumping:
    dec word [counter]
    cmp word [counter], 0
    je .else
    mov dword [os_eventqueue_on_next_tick_vectors], start_dumping
    ret
    .else:

    mov dword [os_eventqueue_on_next_tick_vectors], start_dumping
    mov ecx, 512
    mov esi, os_fs_buffer

.loopy_dump:
    lodsb
    call os_string_convert_2hex
    call os_terminal_putchar
    shr eax, 8
    call os_terminal_putchar

    dec ecx
    cmp ecx, 0
    jne .loopy_dump

    ret


os_fs_buffer:
    times 512 db 0