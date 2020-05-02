%include "sysenter_vectors.asm"
%include "userspace/system_calls.asm"

[ORG 0]
BITS 32
start:
    mov esi, .teststr
    mov edi, 1
    mov eax, .teststr_end - .teststr
    system_call os_write

    mov eax, 0 ; Status code 0
    system_call os_terminate_process

.teststr db "Hello from userspace!"
.teststr_end