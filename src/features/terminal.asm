BITS 32

VGA_BUFFER equ 0xC00B8000; 0xB8000
VGA_WIDTH equ 80
VGA_HEIGHT equ 25

VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA equ 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15

; IN = dx: Output of os_terminal_getidx
os_vga_update_cursor:
    pusha

    mov bx, dx
    shr bx, 1 ; Un-multiply by 2

    mov dx, 0x03D4
    mov al, 0x0F
    out dx, al
 
    mov dx, 0x03D5
    mov al, bl
    out dx, al
 
    mov dx, 0x03D4
    mov al, 0x0E
    out dx, al
 
    mov dx, 0x03D5
    mov al, bh
    out dx, al

    popa
    ret

os_terminal_clear_screen:
    mov ecx, VGA_WIDTH * VGA_HEIGHT * 2


.loopy:
    mov byte [VGA_BUFFER + ecx], 0x20
    mov byte [VGA_BUFFER + ecx + 1], 0x0
    cmp ecx, 0
    je .done
    sub ecx, 2
    jmp .loopy

.done:
    ret
; IN = dl: y, dh: x
; OUT = edx: Index with offset VGA_BUFFER at VGA buffer
; Other registers preserved
os_terminal_getidx:
    push eax; preserve registers
    push ebx
    ;xchg dl, dh


    mov al, VGA_WIDTH
    mul dl

    shr dx, 8
    add dx, ax

    shl edx, 1 ; Multiply by 2 because each entry takes up 2 bytes

    pop ebx
    pop eax
    ret

; IN = dl: bg color, dh: fg color
; OUT = none
os_terminal_set_color:
    shl dl, 4

    or dl, dh
    mov [os_terminal_color], dl


    ret

; IN = dl: y, dh: x, al: ASCII char
; OUT = none
os_terminal_putentryat:
    pusha
    call os_terminal_getidx
    mov ebx, edx

    mov dl, [os_terminal_color]
    mov byte [VGA_BUFFER + ebx], al
    mov byte [VGA_BUFFER + 1 + ebx], dl


    popa
    ret

; Puts a 0x00 if the character at dx is a space. Used for cursor
; IN = dx: Output of os_terminal_getidx
; OUT = none
os_terminal_put_none_if_space: 
    pusha
    mov ebx, edx

    cmp byte [VGA_BUFFER + ebx], 0x20
    jne .notspace

    mov dl, [os_terminal_color]    
    mov byte [VGA_BUFFER + ebx], 0x0
    mov byte [VGA_BUFFER + 1 + ebx], dl

.notspace:
    popa
    ret


; IN = al: ASCII char
os_terminal_putchar:
    pusha
    mov dx, [os_terminal_cursor_pos] ; This loads os_terminal_column at DH, and os_terminal_row at DL
    mov dh, [os_terminal_column]
    mov dl, [os_terminal_row]

    cmp al, 0xA
    je .nextline

    call os_terminal_putentryat
    
    inc dh
    cmp dh, VGA_WIDTH
    jne .cursor_moved

.nextline:
    mov dh, 0
    inc dl



    cmp dl, VGA_HEIGHT
    jne .cursor_moved

    mov dl, 0


.cursor_moved:
    ; Store new cursor position

    mov [os_terminal_column], dh
    mov [os_terminal_row], dl

    call os_terminal_getidx
    call os_terminal_put_none_if_space
    call os_vga_update_cursor

    popa

    ret

; IN = ECX: length of string, ESI: string location
; OUT = none
os_terminal_write:
    pusha
.loopy:

    mov al, [esi]
    call os_terminal_putchar

    dec ecx
    cmp ecx, 0
    je .done

    inc esi
    jmp .loopy


.done:
    popa
    ret

; IN = ESI: zero delimited string location
; OUT = ECX: length of string
os_terminal_strlen:
    push eax
    push esi
    mov ecx, 0
.loopy:
    mov al, [esi]
    cmp al, 0
    je .done

    inc esi
    inc ecx

    jmp .loopy


.done:
    pop esi
    pop eax
    ret

; IN = ESI: string location
; OUT = none
os_terminal_write_string:
    pusha
    call os_terminal_strlen
    call os_terminal_write
    popa
    ret

os_terminal_setup:
    ret

section .data
os_terminal_color db 0

os_terminal_cursor_pos:
os_terminal_column db 0
os_terminal_row db 0
section .text