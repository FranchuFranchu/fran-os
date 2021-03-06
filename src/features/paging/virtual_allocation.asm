

; OUT = EBX: Virtual memory address where the page data is stored. Next 4KiB are guaranteed to be free
kernel_paging_new_kernel_page:
    xor ebx, ebx
    mov bx, [kernel_paging_current_kernel_page_table]
    
    mov eax, [kernel_paging_page_directory+ebx]
    cmp eax, 0
    je .no_page_directory_entry
    jne .yes_page_directory_entry

.no_page_directory_entry:
    
    push ebx
    call kernel_paging_allocate_physical_page_for_page_table
    mov [kernel_paging_current_kernel_page_table], ebx
    pop ebx

    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE
    mov [kernel_paging_page_directory+ebx], eax


.yes_page_directory_entry:
    ; Remove flags
    and eax, ~(4096-1)
    
    ; Get the virtual address of the page table
    mov ebx, eax
    add ebx, KERNEL_VIRTUAL_BASE
    
    add bx, [kernel_paging_first_free_kernel_page]
    
    call kernel_paging_allocate_physical_page

    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE
    
    mov [ebx], eax
    
    
    ; Now, if we reload cr3 we should be able to read the corresponding virtual memory address
    mov ecx, cr3
    mov cr3, ecx
    

.calculate_virtual_address:
    xor ebx, ebx
    xor eax, eax
    mov bx, [kernel_paging_current_kernel_page_table]
    mov ax, [kernel_paging_first_free_kernel_page]

    shl ebx, 20 ; Multiply by 4MiB and divide by 4
    shl eax, 10 ; Multiply by 4KiB and divide by 4

    add ebx, eax
    
    sub ebx, 4096
    
    mov eax, ebx

    add word [kernel_paging_first_free_kernel_page], 4

    ret



; OUT = EBX: Virtual memory address where the page data is stored. Next 4KiB are guaranteed to be free
kernel_paging_new_user_page:
    xor ebx, ebx
    mov bx, [kernel_paging_current_user_page_table]
    
    mov eax, [kernel_paging_page_directory+ebx]
    cmp eax, 0
    je .no_page_directory_entry
    jne .yes_page_directory_entry

.no_page_directory_entry:
    push ebx
    call kernel_paging_allocate_physical_page_for_page_table
    pop ebx
    
    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE | KERNEL_PAGING_FLAG_USER
    call kernel_debug_print_eax
    mov [kernel_paging_page_directory+ebx], eax


.yes_page_directory_entry:
    ; Remove flags
    and eax, ~(4096-1)
    
    ; Get the virtual address of the page table
    push eax
    call kernel_paging_allocate_physical_page

    
    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE | KERNEL_PAGING_FLAG_USER

    pop ebx
    add ebx, KERNEL_VIRTUAL_BASE
    add bx, [kernel_paging_first_free_user_page]    
    sub ebx, 4096
    
    mov [ebx], eax
    
    
    ; Now, if we reload cr3 we should be able to read the corresponding virtual memory address
    mov ecx, cr3
    mov cr3, ecx
    

.calculate_virtual_address:
    xor ebx, ebx
    xor eax, eax
    mov bx, [kernel_paging_current_user_page_table]
    mov ax, [kernel_paging_first_free_user_page]

    shl ebx, 20 ; Multiply by 4MiB and divide by 4
    shl eax, 10 ; Multiply by 4KiB and divide by 4

    add ebx, eax
    
    mov eax, ebx

    add word [kernel_paging_first_free_user_page], 4
    
    call kernel_debug_print_eax
    
    ret

