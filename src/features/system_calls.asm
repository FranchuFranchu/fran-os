; Doc for this in macros/sysenter_vectors.asm
; How to add a system call:
;  Add an entry in macros/sysenter_vectors.yaml
;  Add a function here

; Guidelines for system calls:
; These registers must be preserved
;  - ECX
;  - EDX

%include "features/stream descriptors/structure.asm"

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


kernel_syscall_open_filesystem_file:
    ret


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

kernel_syscall_set_stream_interactions:
    ret
kernel_syscall_get_stream_interactions:
    ret
kernel_syscall_wait_for_interaction:
    ret


