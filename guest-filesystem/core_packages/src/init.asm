BITS 32
%include "sysenter_vectors.asm"
%include "userspace/system_calls.asm"

start:
    mov esi, test_string
    mov eax, test_string_end - test_string
    mov edi, 0
    system_call os_write
    system_call os_terminate_process

test_string: 
db "Hello from userspace"
test_string_end: