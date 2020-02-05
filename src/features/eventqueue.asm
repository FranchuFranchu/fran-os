BITS 32


; Allocate space for 0xFE event queue lists
; Last vector points to next vector table
os_eventqueue_vectors:
    times 0xFF dd 0

os_eventqueue_on_next_tick_vectors:
    times 0xFF dd 0

os_eventqueue_setup:
    mov eax, os_execute_all_eventqueues
    mov ebx, 20h
    call os_define_interrupt
    ret

os_execute_all_eventqueues:
    pusha

    mov ebx, os_eventqueue_vectors

.loopy:
    cmp dword [ebx], 0
    je .done

    call os_execute_eventqueue

    add ebx, 4
.done:

    mov ebx, os_eventqueue_on_next_tick_vectors

.loopy2:
    cmp dword [ebx], 0
    je .done2

    call [ebx]

    add ebx, 4

.done2:
    mov al,20h
    out 20h,al  ; acknowledge the interrupt to the PIC

    popa     ; restore state
    iret

os_execute_eventqueue:
    pusha
    mov ecx, 0
    mov ebx, [ebx]
    ; Now EBX points to a single event queue list

    ; Store vector to call in ESI
    mov esi, [ebx]
    ; Store empty space before queue start in CL
    mov cl, [ebx + 4]
    ; Store total queue size in DL
    mov dl, [ebx + 5]
    ; if empty space equals total size it means the queue is empty
    mov dl, cl
    call os_string_convert_1hex
    call os_terminal_putchar
    shr ax, 8
    call os_string_convert_1hex
    call os_terminal_putchar
    shr ax, 8
    jne .done

    ; Push EBX for later use
    push ebx

    add ebx, 8 ; Add the header size
    add ebx, ecx; Reach the start of the queue

    ; Move one item in the queue to EAX and clear it
    mov eax, [ebx]
    mov dword [ebx], 0
    ; Increment the empty space size by one as we just removed one item
    pop ebx
    inc cl
    mov byte [ebx + 4], cl

    ; Execute the function requested by the queue
    call esi

    mov al, "b"
    call os_terminal_putchar
    
.done:
    mov al, "a"
    call os_terminal_putchar
    popa
    ret
