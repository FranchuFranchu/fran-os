BITS 32
in_protected:
    mov eax, 13
    mov esi, .protected_msg
    call pm_print_string


    ; stage2.asm loaded the kernel in disk_buffer
    ; but we want it at 0x100000
    mov eax, 0
    mov ax, [BLOCK_SIZE]
    mul dword [KERNEL_SIZE]

    mov ecx, eax
    mov esi, kernel_buffer
    mov edi, 0x100000
.copy:
    mov al, [esi]
    mov [edi], al
    dec ecx
    inc esi
    inc edi
    cmp ecx, 0
    jne .copy

    mov eax, 15
    mov esi, .kernel_jumping
    call pm_print_string

    mov eax, 14
    mov esi, 0x100002
    call pm_print_string

    mov eax, kernel_buffer
    jmp 0x100000

    .protected_msg db "Protected mode: Switched correctly", 0
    .kernel_jumping db "Jumping to kernel...", 0

; ESI: string location EAX: Row
pm_print_string:
    push edi
    push eax
    mov edi, 160
    mul edi

    add eax, 0xB8000

    mov edi, eax

.loopy:
    mov al, [esi]
    mov [edi], al

    mov byte [edi + 1], 0x7

    add edi, 2
    inc esi

    cmp al, 0
    jne .loopy
.done:
    pop edi
    pop eax
    ret
