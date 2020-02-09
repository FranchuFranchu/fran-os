
enable_a20:
    mov     ax,2403h                ;--- A20-Gate Support ---
    int     15h
    jb      a20_ns                  ;INT 15h is not supported
    cmp     ah,0
    jnz     a20_ns                  ;INT 15h is not supported
     
    mov     ax,2402h                ;--- A20-Gate Status ---
    int     15h
    jb      a20_failed              ;couldn't get status
    cmp     ah,0
    jnz     a20_failed              ;couldn't get status
     
    cmp     al,1
    jz      a20_success           ;A20 is already activated
     
    mov     ax,2401h                ;--- A20-Gate Activate ---
    int     15h
    jb      a20_failed              ;couldn't activate the gate
    cmp     ah,0
    jnz     a20_failed              ;couldn't activate the gate
     
a20_success:                  ;go on 
    mov si, string_a20_success
    call print_string
    ret
    
a20_failed:
    mov si, string_a20_failed
    call print_string
    jmp $
a20_ns:
    mov si, string_a20_ns
    call print_string
    jmp $

string_a20_ns db "A20 Line: BIOS interrupt not supported", 0xa, 0xd, 0
string_a20_failed db "A20 Line: Failed", 0xa, 0xd, 0
string_a20_success db "A20 Line: Success", 0xa, 0xd, 0
