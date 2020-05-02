%macro system_call 1
    mov ebx, %1
    mov ecx, esp
    mov edx, %%after
    sysenter
    %%after:
%endmacro