; IN = EBX: Userspace code
kernel_switch_to_userspace:
    
    ; We will fake the return stack for iret to make the cpu
    ; believe that a userspace process triggered an interrupt

    mov ax,0x23
    mov ds,ax
    mov es,ax 
    mov fs,ax 
    mov gs,ax ;we don't need to worry about SS. it's handled by iret

    mov eax,esp
    push 0x23 ;u ser data segment with bottom 2 bits set for ring 3
    push eax ; push our current ss for the iret stack frame
    pushf
    push 0x1B; ;u ser code segment with bottom 2 bits set for ring 3
    push ebx ; may need to remove the _ for this to work right 
    iret

kernel_task_state_segment:
   .prev_tss: dd 0   ; The previous TSS - if we used hardware task switching this would form a linked list.
   .esp0: dd 0       ; The stack pointer to load when we change to kernel mode.
   .ss0: dd 0        ; The stack segment to load when we change to kernel mode.
   .esp1: dd 0       ; everything below here is unusued now.. 
   .ss1: dd 0
   .esp2: dd 0
   .ss2: dd 0
   .cr3: dd 0
   .eip: dd 0
   .eflags: dd 0
   .eax: dd 0
   .ecx: dd 0
   .edx: dd 0
   .ebx: dd 0
   .esp: dd 0
   .ebp: dd 0
   .esi: dd 0
   .edi: dd 0
   .es: dd 0         
   .cs: dd 0        
   .ss: dd 0        
   .ds: dd 0        
   .fs: dd 0       
   .gs: dd 0         
   .ldt: dd 0      
   .trap: dw 0
   .iomap_base: dw 0

kernel_task_state_segment_end:

kernel_userspace_setup:
    ; Setup the TSS

    mov eax, esp
    mov [kernel_task_state_segment.esp0], eax
    
    xor eax, eax
    mov ax, ss
    mov [kernel_task_state_segment.ss0], eax
    

    mov eax, kernel_task_state_segment
    ; Set base in the GDT

    mov ebx, eax
    mov [kernel_gdt_task_state_segment.base_0_15], bx

    mov ebx, eax
    shr ebx, 16
    mov [kernel_gdt_task_state_segment.base_16_23], bl

    mov ebx, eax
    shr ebx, 24
    mov [kernel_gdt_task_state_segment.base_24_31], bl

    ; Set limit
    ; Note that the limit is a 20-bit value

    mov eax, kernel_task_state_segment_end - kernel_task_state_segment

    mov ebx, eax
    mov [kernel_gdt_task_state_segment.limit_0_15], bx

    mov ebx, eax
    shr ebx, 16
    and bl, 0x0F
    or [kernel_gdt_task_state_segment.limit_and_flags], bl

    ; Set the "present" flag
    or byte [kernel_gdt_task_state_segment.access], 0x80

    mov ax, 0x2B
    ltr ax


    ret