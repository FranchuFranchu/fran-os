import csv

FMT_SETUP = '''
    mov eax, kernel_exception_handler_{hexcode:0>2}
    mov ebx, {hexcode:0>2}h
    call kernel_define_interrupt
    '''


FMT_STR = '''
kernel_exception_handler_{hexcode:0>2}:{pop_error_code}
    
    {todonext}

    .errmsg db "Exception 0x{hexcode:0>2}: {name}",0
    .errmsgend:
    times 8 db 0 ; Allocate space for error code (if necessary)
    db 0 ; Terminate string
'''
POP_AX_TEXT = '''
    pop eax''' # Pop error code

PRINT_EAX_TEXT = '''
    mov ebx, .errmsgend
    call kernel_exception_handler_insert_eax'''

ABORT_TEXT = '''
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
    '''
FAULT_TEXT = '''
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string

    call kernel_exception_fault
    iret
'''
TRAP_TEXT = FAULT_TEXT

TYPE_TEXTS = {
    "Abort": ABORT_TEXT,
    "NMI": ABORT_TEXT,
    "Trap": TRAP_TEXT,
    "Fault": FAULT_TEXT,
}

setups = """

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
"""


with open("exceptions.csv") as f:
    l = list(csv.reader(f))

d = {}
for row in l:
    hexcode = hex(int(row[1].split(' ')[0]))[2:]
    d[hexcode] = {
        "hexcode": hexcode,
        "name": row[0],
        "print_eax": PRINT_EAX_TEXT if row[4] == "Yes" else '',
        "pop_error_code": POP_AX_TEXT if row[4] == "Yes" else '',
        "todonext": TYPE_TEXTS[row[2]] 

    }
    if hexcode == "e": 
        d[hexcode]["todonext"] = "call kernel_exception_handler_page_fault"


s = ""
for k,v in d.items():
    s += FMT_STR.format(**v)
    setups += FMT_SETUP.format(**v)
setups += "\n    ret"

with open('exceptions.asm', 'w') as f:
    f.write(setups + "\n\n\n" + s)
