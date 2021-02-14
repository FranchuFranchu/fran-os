BITS 32

VGA_BUFFER equ 0xC00B8000
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




%macro write_vga_graphics_register 2
    
    mov dx, 0x03D4
    mov al, %1
    out dx, al

    mov dx, 0x03D5
    mov al, %2
    out dx, al

%endmacro
 

; IN = dx: Output of kernel_terminal_getidx
kernel_vga_update_cursor:
    pusha

    mov bx, dx
    shr bx, 1 ; Un-multiply by 2


    write_vga_graphics_register 0Fh, bl ; Cursor low register

    write_vga_graphics_register 0Eh, bh ; Cursor high register

    popa
    ret

kernel_terminal_clear_screen:
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
kernel_terminal_getidx:
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
kernel_terminal_set_color:
    shl dl, 4

    or dl, dh
    mov [kernel_terminal_color], dl


    ret

; IN = dl: y, dh: x, al: ASCII char
; OUT = none
kernel_terminal_putentryat:
    pusha
    call kernel_terminal_getidx
    mov ebx, edx

    mov dl, [kernel_terminal_color]
    mov byte [VGA_BUFFER + ebx], al
    mov byte [VGA_BUFFER + 1 + ebx], dl


    popa
    ret

; Puts a 0x00 if the character at dx is a space. Used for cursor
; IN = dx: Output of kernel_terminal_getidx
; OUT = none
kernel_terminal_put_none_if_space: 
    pusha
    mov ebx, edx

    cmp byte [VGA_BUFFER + ebx], 0x20
    jne .notspace

    mov dl, [kernel_terminal_color]    
    mov byte [VGA_BUFFER + ebx], 0x0
    mov byte [VGA_BUFFER + 1 + ebx], dl

.notspace:
    popa
    ret


; IN = al: ASCII char
kernel_terminal_putchar:
    pusha

    mov dx, [kernel_terminal_cursor_pos] ; This loads kernel_terminal_column at DH, and kernel_terminal_row at DL


    cmp al, 0xA
    je .nextline
    cmp al, 0x8
    je .backspace

    call kernel_terminal_putentryat
    
    inc dh
    cmp dh, VGA_WIDTH
    jne .cursor_moved

.nextline:
    mov dh, 0
    inc dl



    cmp dl, VGA_HEIGHT
    jne .cursor_moved

    mov dl, 0

.backspace:
    mov al, 0


    cmp dh, 0
    jne .decrement_col

    dec dl
    mov dh, 0
    jmp .cursor_moved

.decrement_col:
    dec dh

    call kernel_terminal_putentryat



.cursor_moved:
    ; Store new cursor position

    mov [kernel_terminal_column], dh
    mov [kernel_terminal_row], dl

    call kernel_terminal_getidx
    call kernel_terminal_put_none_if_space
    call kernel_vga_update_cursor

    popa

    ret

; IN = ECX: length of string, ESI: string location
; OUT = none
kernel_terminal_write:
    pusha
.loopy:

    mov al, [esi]
    call kernel_terminal_putchar

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
kernel_terminal_strlen:
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
kernel_terminal_write_string:
    pusha
    call kernel_terminal_strlen
    call kernel_terminal_write
    popa
    ret

kernel_terminal_setup:
    ret

section .data
kernel_terminal_color db 0

kernel_terminal_cursor_pos:
kernel_terminal_row db 0
kernel_terminal_column db 0
section .text