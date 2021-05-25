; Generated from tools/make_sysenter_vectors.py

kernel_system_calls:
    dd kernel_syscall_no_operation ; 0
    dd kernel_syscall_debug_print_eax ; 1
    dd kernel_syscall_terminate_process ; 2
    dd kernel_syscall_read ; 3
    dd kernel_syscall_write ; 4
    dd kernel_syscall_seek ; 5
    dd kernel_syscall_close ; 6
    dd kernel_syscall_open ; 7
    dd kernel_syscall_execute ; 8
    dd kernel_syscall_fork_and_execute ; 9
    dd kernel_syscall_fork_process ; 10
    dd kernel_syscall_fork_thread ; 11
    dd kernel_syscall_set_file_descriptor_interactions ; 12
    dd kernel_syscall_get_file_descriptor_interactions ; 13
    dd kernel_syscall_wait_for_interaction ; 14

kernel_system_calls_end: