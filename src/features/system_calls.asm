; Doc for this in macros/sysenter_vectors.asm
; How to add a system call:
;  Add an entry in macros/sysenter_vectors.yaml
;  Add a function here

; Guidelines for system calls:
; These registers must be preserved
;  - ECX
;  - EDX

%include "features/file descriptors/structure.asm"

kernel_syscall_no_operation:
    ret


kernel_syscall_debug_print_eax:
    call kernel_debug_print_eax
    ret

kernel_syscall_terminate_process:
    jmp kernel_sleep


kernel_syscall_read:
    ret

kernel_syscall_write:
    ; We haven't implemented file descriptors yet

    xchg eax, ecx
    call kernel_terminal_write
    xchg eax, ecx

    ret


kernel_syscall_seek:
    ret


kernel_syscall_open:
    ; EDI is the backend number
    ; Make sure it's not too large
    mov ebx, edi
    cmp ebx, kernel_file_descriptor_backend_map_size
    jg .out_of_range
    
    ; Load the backend struct pointer
    mov ebx, [kernel_file_descriptor_backend_map+edi*4]
    cmp ebx, 0
    
    ; If it's zero, then it's null
    jz .null_backend
    
    mov ebx, [ebx+kernel_file_descriptor_backend_struct.open]
    
    ; EBX now has the open function
    ; Allocate the file descriptor
    push ebx
    mov ebx, fd_list
    call kernel_debug_print_eax
    mov eax, ebx
    call kernel_debug_print_eax
    call kernel_data_structure_vec_first_free
    pop ebx
    
    
    
    call ebx
    ret

.out_of_range:
    mov eax, -2
    ret
.null_backend:
    mov eax, -3
    ret

; TODO make this process-specific
fd_list: db kernel_data_structure_vec.size
    

kernel_syscall_close:
    ret

kernel_syscall_execute:
    ret

kernel_syscall_fork_and_execute:
    ret

kernel_syscall_fork_process:
    ret


kernel_syscall_fork_thread:
    ret

kernel_syscall_set_file_descriptor_interactions:
    ret
kernel_syscall_get_file_descriptor_interactions:
    ret
kernel_syscall_wait_for_interaction:
    ret


