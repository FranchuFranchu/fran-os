OS_MSR_IA32_SYSENTER_CS  equ 0x174
OS_MSR_IA32_SYSENTER_ESP equ 0x175
OS_MSR_IA32_SYSENTER_EIP equ 0x176

os_sysenter_setup:
    mov eax, 0
    mov edx, 0
    mov ax, 8h
    mov ecx, OS_MSR_IA32_SYSENTER_CS
    wrmsr

    mov eax, esp
    mov edx, 0
    mov ecx, OS_MSR_IA32_SYSENTER_ESP
    wrmsr

    mov eax, os_sysenter_entry_point
    mov edx, 0
    mov ecx, OS_MSR_IA32_SYSENTER_EIP
    wrmsr
    ret

os_sysenter_entry_point:
    mov dword [0xC00B8000], "a d "
    mov ecx, esp
    mov edx, os_sleep