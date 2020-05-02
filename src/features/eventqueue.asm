BITS 32


; Allocate space for 0xFE event queue lists
; Last vector points to next vector table
kernel_eventqueue_vectors:
    times 0xFF dd 0

kernel_eventqueue_on_next_tick_vectors:
    times 0xFF dd 0

kernel_eventqueue_sleeping_processes:
    %rep 0xFF
        dd 0 ; Address to return to
        dd 0 ; Interrupts to wait until it's reached
    %endrep

kernel_eventqueue_setup:

    mov ax, 1000
    cli
    out 0x40, al        ; Set low byte of reload value
    rol ax, 8           ; al = high byte, ah = low byte
    out 0x40, al        ; Set high byte of reload value
    rol ax, 8           ; al = low byte, ah = high byte (ax = original reload value)

    mov eax, kernel_pit_irq_handler
    mov ebx, 20h
    call kernel_define_interrupt
    sti
    ret

PIT_OSCILLATION_S  equ 11 ; pit oscillations in second
PIT_OSCILLATION_MS  equ 1 ; pit oscillations in a milisecond
PIT_OSCILLATION_AS equ 0;.01 ; pit oscillations in a microsecond 
; fuck the precision is too low
PIT_INCREMENT_EACH_TIME equ 1 ; Make sure its prime
kernel_pit_counter dd 0 ; loops back on 2**32 ns, or 3600 seconds (an hour)

kernel_pit_irq_handler:
    pusha

    call kernel_execute_all_eventqueues
    call kernel_eventqueue_oscillation_pit

    mov al, 0x20
    out 0x20, al

    popa
    iret

kernel_eventqueue_oscillation_1s:
    mov al, "a"
    call kernel_terminal_putchar
    ret

kernel_eventqueue_oscillation_1ms:
    ret

kernel_eventqueue_oscillation_pit:
    ; Substract 1 from all sleeping processes
    pusha
    mov ebx, kernel_eventqueue_sleeping_processes - 8
    mov ecx, 0
    .look_for_empty: 
        inc ecx

        mov eax, [ebx + 4]
        dec eax
        mov [ebx + 4], eax


        add ebx, 8 ; Skip to next entry
        cmp ecx, 0xFF
        jne .look_for_empty
    popa
    ret

kernel_eventqueue_oscillation_1as:
    ret

; IN = EDX: Time in PIT interrupts
; OUT = All registers get changed
; Wait for the amount of time specified in ECX (in PIT interrupts), then return
kernel_eventqueue_sleep:
    
    pop ecx ; Return value was pushed to stack. Pop it to ECX
    mov eax, ecx 
    ; We do this so that EAX does not get damaged

    mov ebx, kernel_eventqueue_sleeping_processes - 8
    .look_for_empty: 
        add ebx, 8 ; Skip to next entry
        cmp dword [ebx], 0 ; If the address is 0, it means its unused
        jne .look_for_empty
    mov dword [ebx], eax
    mov dword [ebx + 4], edx

    ; Don't return. Just wait until an interrupt happens
    .halt: hlt
    cmp dword [ebx + 8], 0
    jne .halt
    
    jmp [ebx]




kernel_execute_all_eventqueues:
    mov ebx, kernel_eventqueue_vectors

.loopy:
    cmp dword [ebx], 0
    je .done 

    call kernel_execute_eventqueue

    add ebx, 4
.done:

    mov ebx, kernel_eventqueue_on_next_tick_vectors

.loopy2:
    cmp dword [ebx], 0
    je .done2

    call [ebx]

    add ebx, 4

.done2:
    ret

kernel_execute_eventqueue:
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
    call kernel_string_convert_1hex
    call kernel_terminal_putchar
    shr ax, 8
    call kernel_string_convert_1hex
    call kernel_terminal_putchar
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
    call kernel_terminal_putchar
    
.done:
    mov al, "a"
    call kernel_terminal_putchar
    popa
    ret
