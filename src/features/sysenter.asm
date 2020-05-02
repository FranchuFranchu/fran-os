KERNEL_MSR_IA32_SYSENTER_CS  equ 0x174
KERNEL_MSR_IA32_SYSENTER_ESP equ 0x175
KERNEL_MSR_IA32_SYSENTER_EIP equ 0x176

kernel_sysenter_setup:
    mov eax, 0
    mov edx, 0
    mov ax, 8h
    mov ecx, KERNEL_MSR_IA32_SYSENTER_CS
    wrmsr

    mov eax, esp
    mov edx, 0
    mov ecx, KERNEL_MSR_IA32_SYSENTER_ESP
    wrmsr

    mov eax, kernel_sysenter_entry_point
    mov edx, 0
    mov ecx, KERNEL_MSR_IA32_SYSENTER_EIP
    wrmsr
    ret

kernel_sysenter_entry_point:
    mov esi, .teststr
    call kernel_terminal_write_string

    mov ecx, esp
    mov edx, edx
    sysexit

    .teststr dd "Sysenter executed correctly!", 0
