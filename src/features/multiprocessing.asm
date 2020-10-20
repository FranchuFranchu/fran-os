%define EBDA_LOCATION 0xC0080000

kernel_find_mp_configuration_table:
    mov esi, EBDA_LOCATION

    .find_in_ebda:
        add esi, 16
        mov eax, [esi]
        cmp eax, "_MP_"
        je .found
        cmp esi, EBDA_LOCATION+1024
        jne .find_in_ebda

    mov esi, 0xC00F0000

    .find_in_rom:
        add esi, 16
        mov eax, [esi]
        cmp eax, "_MP_"
        je .found
        cmp esi, 0xC0100000
        jne .find_in_rom


.found:
    ret


kernel_mp_config_location: dd 0

kernel_mp_init:
    call kernel_find_mp_configuration_table
    mov [kernel_mp_config_location], eax
    ret