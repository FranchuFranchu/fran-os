
; OUT: EAX: upper Memory / 1024
kernel_paging_get_memory:
    push ebx


    mov ebx, [kernel_multiboot_info_pointer]
    mov eax, [ebx]
    ; EAX has flags
    and eax, 1
    ; If it's zero then it means that the bootloader didn't tell us the memory
    ; Crash the system if that is the case
    jz kernel_exception_fault

    mov eax, [ebx+8]

    pop ebx
    ret


; OUT = EAX: Physical memory address of page
kernel_paging_allocate_physical_page:
    mov eax, [kernel_paging_first_free_physical_memory_address]


    ; Round down to closest multiple of 4096
    and eax, 0xFFFFF000

    add eax, 4096


    mov [kernel_paging_first_free_physical_memory_address], eax
        
    ret

; This function allocates some space for a page table
; OUT = EAX: Physical memory address of address where the kernel can place page tables, EBX: Virtual memory address w/ page table
kernel_paging_allocate_physical_page_for_page_table:

    call kernel_paging_allocate_physical_page

    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE

    xor ebx, ebx
    mov bx, [kernel_paging_first_free_page_in_meta_page_table]



    mov [kernel_paging_meta_page_table+ebx*4], eax

    inc word [kernel_paging_first_free_page_in_meta_page_table]

    ; ebx * 4KiB + [pde of page table] * 4MiB = virtual address
    push eax

    xor eax, eax
    mov ax, [kernel_paging_meta_page_table_directory_entry]



    shl eax, 22 ; Divide by 4MiB
    shl ebx, 12 ; Divide by 4KiB 


    add ebx, eax
    mov eax, ebx

    pop eax
    and eax, 0xFFFFF000 ; Un-set flags

    ; We could use invlpg here
    ; But i'm not sure how
    ; Reload cr3 instead

    push ecx
    mov ecx, cr3
    mov cr3, ecx
    pop ecx

    ret
