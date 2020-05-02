kernel_font_unknown:
db 00011000b
db 00111100b
db 01111110b
db 11100011b
db 11111011b
db 11111011b
db 11100011b
db 11101111b
db 11111111b
db 01101110b
db 00111100b
db 00011000b

db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00000000b
db 00000000b


kernel_font_setup:
    mov esi, kernel_font_unknown
    mov ebx, 16
    ;clear even/odd mode
    mov         dx, 03ceh
    mov         ax, 5
    out         dx, ax
    ;map VGA memory to 0C00A000h
    mov         ax, 0406h
    out         dx, ax
    ;set bitplane 2
    mov         dx, 03c4h
    mov         ax, 0402h
    out         dx, ax
    ;clear even/odd mode (the other way, don't ask why)
    mov         ax, 0604h
    out         dx, ax
    ;copy charmap
    mov         edi, 0C00A0000h + 0xFF * 32
    mov         ecx, 256
    ;copy 16 bytes to bitmap
    movsd
    movsd
    movsd
    movsd
    ;restore VGA state to normal operation
    mov         ax, 0302h
    out         dx, ax
    mov         ax, 0204h
    out         dx, ax
    mov         dx, 03ceh
    mov         ax, 1005h
    out         dx, ax
    mov         ax, 0E06h
    out         dx, ax
    ret
    