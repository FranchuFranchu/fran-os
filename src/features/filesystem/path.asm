
; IN = ESI: Zero-terminated path, EAX: Root inode number
; OUT = EAX: Inode number
kernel_fs_get_path_inode:
    push esi
    push ebx

    cmp byte [esi], '/'
    jne .notroot
    mov eax, 2
    inc esi
.notroot:

    mov ebx, esi

.loopy:
    cmp byte [esi], '/'
    je .slash
    cmp byte [esi], 0
    je .end

    inc esi

    jmp .loopy
.slash:
    call kernel_terminal_write_string
    mov byte [esi], 0

    xchg ebx, esi
    call kernel_fs_get_subfile_inode
    xchg ebx, esi

    mov byte [esi], "/"

    inc esi

    mov ebx, esi
    jmp .loopy

.end:
    xchg esi, ebx
    call kernel_fs_get_subfile_inode

    pop ebx
    pop esi
    ret
