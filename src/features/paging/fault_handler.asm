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
    
    jmp .bad_end

.userspace:
    ; TODO
    ; this could recursively call itself until it reaches the user page
    ; very bad
    ; but works
    ; call kernel_paging_new_user_page
    jmp .bad_end

.protection_fault:
    ; Simply stop the program
    ; TODO
    jmp .bad_end

.bad_end:
    push eax
    call kernel_terminal_clear_screen

    mov esi, .errmsg
    mov edi, VGA_BUFFER
    mov bl, 0x4F
    call kernel_exception_handler_print_string
    
    ; Print error code
    pop eax
    mov byte [kernel_terminal_row], 10
    call kernel_debug_print_eax
    
    mov ebx, cr2
    mov eax, ebx
    call kernel_debug_print_eax
    
    
    call kernel_exception_fault
    
    jmp kernel_halt
    .errmsg: db "Page fault", 0
.end:
    ret