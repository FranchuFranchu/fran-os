%define os_paging_directory_index(vaddr) (vaddr >> 20) * 4

extern page_directory
extern _kernel_pages
extern _kernel_page_index_end


os_paging_setup:
    
    mov ebx, [os_multiboot_info_pointer]
    mov eax, [ebx]
    ; EAX has flags
    and eax, 1
    ; If it's zero then it means that the bootloader didn't tell us the memory
    ; Crash the system if that is the case
    jz os_exception_fault

    mov eax, [ebx+8]
    ; EAX holds the amount of upper memory in KB
    ; 4MiB = 4194 KB
    mov edx, 0
    mov ebx, 4194
    div ebx
    mov ecx, eax
    ; ECX holds the amount of 4MiB pages we can use
    call os_debug_print_eax

    mov ebx, os_paging_directory_index(0xC0000000)
    mov eax, 0
    or eax, 0x83

.fill_higher_half:
    dec ecx
    mov [page_directory+ebx], eax
    call os_debug_print_eax
    add eax, 4096*1024
    add ebx, 4
    cmp ebx, _kernel_page_index_end
    jng .fill_higher_half

    dec ecx

    mov ebx, 0
.fill_lower_half:
    cmp ecx, 0
    je .end

    call os_debug_print_eax
    mov [page_directory+ebx], eax
    add eax, 4096*1024
    add ebx, 4
    dec ecx

    jmp .fill_lower_half

.end:
    ; Reload
    mov ecx, cr3
    mov cr3, ecx    

    mov eax, $
    call os_debug_print_eax

    ret