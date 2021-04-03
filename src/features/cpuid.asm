
; OUT: EAX != 0 if cpuid available
kernel_cpuid_available:
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

kernel_cpuid_vendor_buffer times 12 db 0
; IN: EAX: passed to cpuid
; OUT: EAX, EBX, ECX, EDX: CPUID output
kernel_cpuid:
    cpuid
    ret

kernel_cpuid_print_vendor:
    mov eax, 0
    cpuid
    mov [kernel_cpuid_vendor_buffer+0], ebx
    mov [kernel_cpuid_vendor_buffer+4], edx
    mov [kernel_cpuid_vendor_buffer+8], ecx
    DEBUG_PRINT {"CPUID Vendor: ", '"'}
    mov ecx, 12
    mov esi, kernel_cpuid_vendor_buffer
    call kernel_terminal_write
    DEBUG_PRINT {'"', 0xa}
    ret
