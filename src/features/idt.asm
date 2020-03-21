BITS 32

%define LINEAR_ADDRESS(x) (BASE_OF_SECTION + x - $$)

%define PIC1        0x20        ; IO base address for master PIC 
%define PIC2        0xA0        ; IO base address for slave PIC 
%define PIC1_COMMAND    PIC1
%define PIC1_DATA   (PIC1+1)
%define PIC2_COMMAND    PIC2
%define PIC2_DATA   (PIC2+1)
%define PIC1_OFFSET  0x20
%define PIC2_OFFSET  0x28

%define ICW1_ICW4   0x01        ; ICW4 (not) needed 
%define ICW1_SINGLE 0x02        ; Single (cascade) mode 
%define ICW1_INTERVAL4  0x04        ; Call address interval 4 (8) 
%define ICW1_LEVEL  0x08        ; Level triggered (edge) mode 
%define ICW1_INIT   0x10        ; Initialization - required! 
 
%define ICW4_8086   0x01        ; 8086/88 (MCS-80/85) mode 
%define ICW4_AUTO   0x02        ; Auto (normal) EOI 
%define ICW4_BUF_SLAVE  0x08        ; Buffered mode/slave 
%define ICW4_BUF_MASTER 0x0C        ; Buffered mode/master 
%define ICW4_SFNM   0x10        ; Special fully nested (not) 

os_idt:
    times 0xFF dq 0   


os_idt_end:


os_idt_info:
    .size dw os_idt_end - os_idt - 1
    .pointer dd os_idt 

wait_some_time:
    mov ecx, 0xFFFFFFFF

    .cont:
        dec cx
        cmp cx, 0
        jne .cont
    ret

os_idt_setup:
    lidt [os_idt_info]
    ; Initialize both PICs and remap 
    mov dx, PIC1_COMMAND
    mov bl, 0x20
    call .setup_pic

    mov dx, PIC2_COMMAND
    mov bl, 0x28
    call .setup_pic

    call pic_clear_mask
    ; Reset keyboard
    mov al,  0xFF
    out 0x64, al
    ret

; IN = DX: Port to setup (master/slave) BL: Offset 
.setup_pic:
    mov al, ICW1_INIT | ICW1_ICW4
    out dx, al
    add dx, 1

    mov al, bl
    out dx, al

    cmp dx, PIC1_DATA
    je .do4
    .do2:
        mov al, 2
        out dx, al
        jmp .continue
    .do4:
        mov al, 4
        out dx, al
    .continue:
    mov al, ICW4_8086
    out dx, al

    ret

; Clears all masks
pic_clear_mask:
    in al, PIC1_DATA
    and al, 11011100b
    out PIC1_DATA, al
    in al, PIC2_DATA
    and al, 10111111b
    out PIC2_DATA, al
    ret


; IN = EAX: Function to be jumped to, EBX: Interrupt number
os_define_interrupt:
    mov word [os_idt+ebx*8],ax
    mov word [os_idt+ebx*8+2],8h   
    mov byte [os_idt+ebx*8+4],0
    mov byte [os_idt+ebx*8+5],10001110b
    ror eax, 16
    mov word [os_idt+ebx*8+6],ax
    rol eax, 16
    ret
