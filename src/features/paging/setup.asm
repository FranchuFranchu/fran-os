

kernel_paging_setup:
    
    call kernel_paging_get_memory

    ; EAX holds the amount of upper memory in KB
    ; 4MiB = 4194 KB
    mov edx, 0
    mov ebx, 4194
    div ebx
    mov ecx, eax
    ; ECX holds the amount of 4MiB pages we can use
 
    mov ebx, kernel_paging_directory_index(KERNEL_VIRTUAL_BASE)
    mov eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE | KERNEL_PAGING_FLAG_4MIB

    ; During the whole loop:
    ; EAX holds the first free physical address 
    ; EBX holds the first free virtual page directory

.fill_higher_half:

    dec ecx
    mov [kernel_paging_page_directory+ebx], eax
    add eax, 4096*1024
    add ebx, 4
    cmp ebx, _kernel_page_index_end*4
    jng .fill_higher_half

    
    dec ecx

    ; Now that we allocated the kernel text and data sections
    ; We have to configure stuff for dynamic page allocation

.make_meta_page_table:
    mov dword [kernel_paging_page_directory+ebx], kernel_paging_meta_page_table - KERNEL_VIRTUAL_BASE
    or dword [kernel_paging_page_directory+ebx], KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE

    push ebx


    shr bx, 2 ; Divide by 4
    mov [kernel_paging_meta_page_table_directory_entry], bx
    pop ebx

.end:
    sub eax, 4096
    mov [kernel_paging_first_free_physical_memory_address], eax
    add bx, 4
    mov [kernel_paging_first_free_kernel_page_table], bx

    mov dword [kernel_paging_page_directory+KERNEL_PAGE_NUMBER*4], 0x83
    ; Reload

    mov ecx, kernel_paging_page_directory - KERNEL_VIRTUAL_BASE
    mov cr3, ecx


    ret

