; Generated from tools/make_sysenter_vectors.py

kernel_system_calls:
    dd kernel_syscall_no_operation ; 0
    dd kernel_syscall_debug_print_eax ; 1
    dd kernel_syscall_terminate_process ; 2
    dd kernel_syscall_read ; 3
    dd kernel_syscall_write ; 4

kernel_system_calls_end: