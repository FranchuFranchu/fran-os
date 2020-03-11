; WIP
; OUT: EAX != 0  if cpuid available
os_cpuid_available:
    pushfd
    pushfd                               ;Store EFLAGS
    xor dword [esp],0x00200000           ;Invert the ID bit in stored EFLAGS
    popfd                                ;Load stored EFLAGS (with ID bit inverted)
    pushfd                               ;Store EFLAGS again (ID bit may or may not be inverted)
    pop eax                              ;eax = modified EFLAGS (ID bit may or may not be inverted)
    xor eax,[esp]                        ;eax = whichever bits were changed
    popfd                                ;Restore original EFLAGS
    and eax,0x00200000                   ;eax = zero if ID bit can't be changed, else non-zero
    ret

; IN: EAX: passed to cpuid
; OUT: EAX, EBX, ECX, EDX: CPUID output
os_cpuid:
    ret

os_cpuid_print_vendor:
    mov eax, 80000002h
    mov esi, 0
    mov edi, 0
    mov ebx, 0
    mov ecx, 0
    mov edx, 0
    cpuid

    call .print_eax

    ret
.print_eax:
    call os_terminal_putchar
    ror eax, 8
    call os_terminal_putchar
    ror eax, 8
    call os_terminal_putchar
    ror eax, 8
    call os_terminal_putchar
    ror eax, 8
    ret

    
