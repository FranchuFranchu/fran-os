

os_exception_handler_insert_eax:
    mov ecx, eax ; store eax for later use

    call os_string_convert_4hex ; Convert lower 16 to hex
    mov cx, 4
    .loopy:
        shr eax, 8
        cmp cx, 4
        je .done
        mov byte [ebx], al
        inc ebx
        jmp .loopy
    .done:

    mov eax, ecx
    shr eax, 16 ; Get higher 16
    call os_string_convert_4hex
    .loopy2:
        shr eax, 8
        cmp cx, 0
        je .done2
        mov byte [ebx], al
        inc ebx
        jmp .loopy2
    .done2:
    ret


os_exception_handler_print_string:
    mov edi, 0xB8000
    .loopy:
        lodsb
        cmp al, 0
        je .done
        mov byte [edi], al
        inc edi
        mov byte [edi], 0xF4
        inc edi
        jmp .loopy
    .done:
    ret

os_exception_handler_setup:
    call os_exception_handler_define_int
    ret
os_exception_handler_define_int:

    mov eax, os_exception_handler_00
    mov ebx, 00h
    call os_define_interrupt
    
    mov eax, os_exception_handler_01
    mov ebx, 01h
    call os_define_interrupt
    
    mov eax, os_exception_handler_02
    mov ebx, 02h
    call os_define_interrupt
    
    mov eax, os_exception_handler_03
    mov ebx, 03h
    call os_define_interrupt
    
    mov eax, os_exception_handler_04
    mov ebx, 04h
    call os_define_interrupt
    
    mov eax, os_exception_handler_05
    mov ebx, 05h
    call os_define_interrupt
    
    mov eax, os_exception_handler_06
    mov ebx, 06h
    call os_define_interrupt
    
    mov eax, os_exception_handler_07
    mov ebx, 07h
    call os_define_interrupt
    
    mov eax, os_exception_handler_08
    mov ebx, 08h
    call os_define_interrupt
    
    mov eax, os_exception_handler_09
    mov ebx, 09h
    call os_define_interrupt
    
    mov eax, os_exception_handler_0a
    mov ebx, 0ah
    call os_define_interrupt
    
    mov eax, os_exception_handler_0b
    mov ebx, 0bh
    call os_define_interrupt
    
    mov eax, os_exception_handler_0c
    mov ebx, 0ch
    call os_define_interrupt
    
    mov eax, os_exception_handler_0d
    mov ebx, 0dh
    call os_define_interrupt
    
    mov eax, os_exception_handler_0e
    mov ebx, 0eh
    call os_define_interrupt
    
    mov eax, os_exception_handler_10
    mov ebx, 10h
    call os_define_interrupt
    
    mov eax, os_exception_handler_11
    mov ebx, 11h
    call os_define_interrupt
    
    mov eax, os_exception_handler_12
    mov ebx, 12h
    call os_define_interrupt
    
    mov eax, os_exception_handler_13
    mov ebx, 13h
    call os_define_interrupt
    
    mov eax, os_exception_handler_14
    mov ebx, 14h
    call os_define_interrupt
    
    ret



os_exception_handler_00:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x00: Divide-by-zero Error",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_01:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x01: Debug",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_02:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x02: Non-maskable Interrupt",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_03:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x03: Breakpoint",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_04:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x04: Overflow",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_05:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x05: Bound Range Exceeded",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_06:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x06: Invalid Opcode",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_07:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x07: Device Not Available",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_08:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x08: Double Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_09:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x09: Coprocessor Segment Overrun",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_0a:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x0a: Invalid TSS",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_0b:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x0b: Segment Not Present",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_0c:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x0c: Stack-Segment Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_0d:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x0d: General Protection Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_0e:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x0e: Page Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_10:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x10: x87 Floating-Point Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_11:
    pop eax
    mov esi, .errmsg
    mov ebx, .errmsgend
    call os_exception_handler_insert_eax
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x11: Alignment Check",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_12:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x12: Machine Check",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_13:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x13: SIMD Floating-Point Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

os_exception_handler_14:
    mov esi, .errmsg
    call os_exception_handler_print_string
    
	jmp os_halt

    .errmsg db "Exception 0x14: Virtualization Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string
