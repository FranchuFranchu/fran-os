%include "features/system_calls.asm"
%include "features/sysenter_vectors_list.asm"

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
    
    ; Allocate some things
    mov eax, 10
    mov ebx, fd_list
    call kernel_data_structure_vec_initialize
    
    ret


; IN = EBX: System call number, EDX: Return address, ECX: Return stack
kernel_sysenter_entry_point:
    ; Make sure system call in range
    cmp ebx, (kernel_system_calls_end - kernel_system_calls) / 4
    jge .out_of_range

    call [kernel_system_calls+ebx*4]
    
    sysexit
.out_of_range: 
    stc
    sysexit
    


    .teststr dd "Sysenter executed correctly!", 0
