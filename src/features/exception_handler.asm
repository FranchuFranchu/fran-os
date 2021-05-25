

kernel_exception_fault:
    mov bl, 0x4F
    mov esi, .errmsg2
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 2
    call kernel_exception_handler_print_string

    mov esi, .errmsg3
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 3
    call kernel_exception_handler_print_string

    mov esi, .errmsg4
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 4
    call kernel_exception_handler_print_string

    mov esi, .errmsg5
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 5
    call kernel_exception_handler_print_string
    
    
    .waitfork:
    call kernel_halt_for_key

    

    cmp al, "s"
    je .shutdown

    cmp al, "r"
    je .restart

    cmp al, "h"
    je .halt

    cmp al, "c"
    je .continue
    jne .waitfork

.acknowledge_retry:

    mov al,20h
    out 20h,al  ;; acknowledge the interrupt to the PIC

    jmp .waitfork

.shutdown:  
    ; Highlight option with blue
    mov bl, 0x4B
    mov esi, .errmsg3
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 3
    call kernel_exception_handler_print_string

    jmp kernel_shutdown
.restart:
    ; Highlight option with blue
    mov bl, 0x4B
    mov esi, .errmsg4
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 4
    call kernel_exception_handler_print_string
    
    jmp kernel_restart
.continue:
    ; Highlight option with blue
    mov bl, 0x4B
    mov esi, .errmsg2
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 2
    call kernel_exception_handler_print_string
    
    ret
.halt:
    ; Highlight option with blue
    mov bl, 0x4B
    mov esi, .errmsg5
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 5
    call kernel_exception_handler_print_string
    
    jmp kernel_halt


    .errmsg2 db "Press C to continue.",0
    .errmsg3 db "Press S to shutdown.",0
    .errmsg4 db "Press R to restart.",0
    .errmsg5 db "Press H to halt forever.",0
kernel_exception_handler_insert_eax:
    mov ecx, eax ; store eax for later use

    call kernel_string_convert_4hex ; Convert lower 16 to hex
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
    call kernel_string_convert_4hex
    .loopy2:
        shr eax, 8
        cmp cx, 0
        je .done2
        mov byte [ebx], al
        inc ebx
        jmp .loopy2
    .done2:
    ret


kernel_exception_handler_print_string:
    .loopy:
        lodsb
        cmp al, 0
        je .done
        mov byte [edi], al
        inc edi
        mov byte [edi], bl
        inc edi
        jmp .loopy
    .done:
    ret

kernel_exception_handler_setup:
    call kernel_exception_handler_define_int
    ret
kernel_exception_handler_define_int:

    mov eax, kernel_exception_handler_00
    mov ebx, 00h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_01
    mov ebx, 01h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_02
    mov ebx, 02h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_03
    mov ebx, 03h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_04
    mov ebx, 04h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_05
    mov ebx, 05h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_06
    mov ebx, 06h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_07
    mov ebx, 07h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_08
    mov ebx, 08h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_09
    mov ebx, 09h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_0a
    mov ebx, 0ah
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_0b
    mov ebx, 0bh
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_0c
    mov ebx, 0ch
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_0d
    mov ebx, 0dh
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_0e
    mov ebx, 0eh
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_10
    mov ebx, 10h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_11
    mov ebx, 11h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_12
    mov ebx, 12h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_13
    mov ebx, 13h
    call kernel_define_interrupt
    
    mov eax, kernel_exception_handler_14
    mov ebx, 14h
    call kernel_define_interrupt
    
    ret



kernel_exception_handler_00:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x00: Divide-by-zero Error",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_01:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x01: Debug",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_02:
    
    
    call kernel_terminal_clear_screen
    mov bl, 0x4F

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    call kernel_exception_handler_print_string

    mov esi, .errmsg2
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 2
    call kernel_exception_handler_print_string

    mov esi, .errmsg3
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 3
    call kernel_exception_handler_print_string

    jmp kernel_halt

    .errmsg2 db "This error is fatal.",0
    .errmsg3 db "Shutdown your computer manually.",0
    

    .errmsg db "Exception 0x02: Non-maskable Interrupt",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_03:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x03: Breakpoint",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_04:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x04: Overflow",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_05:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x05: Bound Range Exceeded",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_06:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x06: Invalid Opcode",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_07:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x07: Device Not Available",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_08:
    
    
    call kernel_terminal_clear_screen
    mov bl, 0x4F

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    call kernel_exception_handler_print_string

    mov esi, .errmsg2
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 2
    call kernel_exception_handler_print_string

    mov esi, .errmsg3
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 3
    call kernel_exception_handler_print_string

    jmp kernel_halt

    .errmsg2 db "This error is fatal.",0
    .errmsg3 db "Shutdown your computer manually.",0
    

    .errmsg db "Exception 0x08: Double Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_09:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x09: Coprocessor Segment Overrun",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_0a:
    pop eax
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x0a: Invalid TSS",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_0b:
    pop eax
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x0b: Segment Not Present",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_0c:
    pop eax
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x0c: Stack-Segment Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_0d:
    pop eax
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x0d: General Protection Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_0e:
    mov [.tmp], eax
    pop eax
    call kernel_exception_handler_page_fault
    iret
    
    .tmp dd 0

    .errmsg db "Exception 0x0e: Page Fault",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_10:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x10: x87 Floating-Point Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_11:
    pop eax
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x11: Alignment Check",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_12:
    
    
    call kernel_terminal_clear_screen
    mov bl, 0x4F

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    call kernel_exception_handler_print_string

    mov esi, .errmsg2
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 2
    call kernel_exception_handler_print_string

    mov esi, .errmsg3
    mov edi, VGA_BUFFER + VGA_WIDTH * 2 * 3
    call kernel_exception_handler_print_string

    jmp kernel_halt

    .errmsg2 db "This error is fatal.",0
    .errmsg3 db "Shutdown your computer manually.",0
    

    .errmsg db "Exception 0x12: Machine Check",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_13:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x13: SIMD Floating-Point Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string

kernel_exception_handler_14:
    
    
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret


    .errmsg db "Exception 0x14: Virtualization Exception",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string
