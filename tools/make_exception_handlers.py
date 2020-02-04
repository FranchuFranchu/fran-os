import csv

FMT_SETUP = '''
    mov eax, os_exception_handler_{hexcode:0>2}
    mov ebx, {hexcode:0>2}h
    call os_define_interrupt
    '''

FMT_STR = '''
os_exception_handler_{hexcode:0>2}:{pop_error_code}
    mov esi, .errmsg{print_eax}
    call os_exception_handler_print_string
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
    call os_exception_handler_insert_eax'''

ABORT_TEXT = "\n\tjmp os_halt\n"
TRAP_TEXT = ABORT_TEXT
FAULT_TEXT = ABORT_TEXT

TYPE_TEXTS = {
    "Abort": ABORT_TEXT,
    "NMI": ABORT_TEXT,
    "Trap": TRAP_TEXT,
    "Fault": FAULT_TEXT,
}

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

setups = """

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
"""
s = ""
for k,v in d.items():
    s += FMT_STR.format(**v)
    setups += FMT_SETUP.format(**v)
setups += "\n    ret"

with open('exceptions.asm', 'w') as f:
    f.write(setups + "\n\n\n" + s)