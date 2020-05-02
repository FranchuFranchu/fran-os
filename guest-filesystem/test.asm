BITS 32
mov edx, after_sysenter
sysenter
after_sysenter
mov edx, after_sysenter2
sysenter
after_sysenter2
jmp $
mov dword [0xC00B8000], "s 5 "
ret
