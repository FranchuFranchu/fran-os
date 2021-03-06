BITS 32

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


kernel_idt:
    times 0xFF dq 0   


kernel_idt_end:


kernel_idt_info:
    .size dw kernel_idt_end - kernel_idt - 1
    .pointer dd kernel_idt


kernel_idt_setup:
    lidt [kernel_idt_info]
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

; Set masks as we want them to be
pic_clear_mask:
    
    in al, PIC1_DATA
    mov al, 0xFF
    out PIC1_DATA, al
    in al, PIC2_DATA
    mov al, 0xFF
    out PIC2_DATA, al
    ret

; IN = EAX: IRQ number
kernel_pic_allow_irq:
    push eax
    push ebx
    push ecx

    mov ecx, eax
    mov ebx, 1

    inc ecx
    cmp ecx, 0x8
    jg .pic2
.pic1:
    ; This IRQ is sent by PIC 1
    ; shift mask
    shl ebx, 1
    loop .pic1
    shr ebx, 1
    not ebx


    in al, PIC1_DATA
    and al, bl

    out PIC1_DATA, al

    jmp .end
.pic2:
    ; This IRQ is sent by PIC 2
    ; shift mask

    sub ecx, 0x8
.picloop2:
    shl ebx, 1
    loop .picloop2


    shr ebx, 1
    not ebx
    


    in al, PIC2_DATA
    and al, bl

    out PIC2_DATA, al

    jmp .end

.end:
    pop ecx
    pop ebx
    pop eax
    ret



; IN = EAX: Function to be jumped to, EBX: Interrupt number
kernel_define_interrupt:
    cmp ebx, 0x30
    jge .noirq
    cmp ebx, 0x20
    jl .noirq

    push eax
    mov eax, ebx
    sub eax, 0x20
    call kernel_pic_allow_irq
    pop eax

.noirq:
    mov word [kernel_idt+ebx*8],ax
    mov word [kernel_idt+ebx*8+2],8h   
    mov byte [kernel_idt+ebx*8+4],0
    mov byte [kernel_idt+ebx*8+5],10001110b
    ror eax, 16
    mov word [kernel_idt+ebx*8+6],ax
    rol eax, 16
    ret
