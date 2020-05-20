; IN = EAX: Error code
kernel_exception_handler_page_fault:
    test eax, 0x1
    jnz .protection_fault
    jz .nonpresent

.nonpresent:    
    ; Load an extra page for the program
    mov ebx, cr2
    cmp ebx, KERNEL_VIRTUAL_BASE ; 0xC0000000
    jl .kernelspace
    jg .userspace

.kernelspace:
    ; Most likely an error
    ; We haven't implemented page swapping yet
    call kernel_exception_handler_page_fault

    jmp .end

.userspace:
    ; TODO
    ; this will recursively call itself until it reaches the user page
    ; very bad
    ; but works
    call kernel_paging_new_user_page
    jmp .end

.protection_fault:
    ; Simply stop the program
    call kernel_exception_handler_page_fault

.end:
    ret