BITS 32

ATA_PRIMARY_DATA equ 0x1F0
ATA_SECONDARY_DATA equ 0x170
ATA_PRIMARY_CONTROL equ 0x3F6
ATA_SECONDARY_CONTROL equ 0x376


kernel_ata_pio_writing db 0

kernel_ata_pio_setup:
    mov eax, kernel_ata_pio_irq_handler
    mov ebx, 2eh
    call kernel_define_interrupt

    ret

%macro kernel_ata_pio_poll 0
    mov dx, ATA_PRIMARY_CONTROL
%%poll:
    in al, dx
    
    test al, 0x21 ; Test if either ERR or DF is set
    jnz ata_pio_error
    
    test al, 0x08 ; Test if DRQ is set
    jz %%poll
%%end:
%endmacro
    
    
%macro kernel_ata_pio_poll_nodrq 0
    mov dx, ATA_PRIMARY_CONTROL
%%poll:
    in al, dx
    
    test al, 0x21 ; Test if either ERR or DF is set
    jnz ata_pio_error
    
    test al, 0x80 ; Test if BSY is not set
    jnz %%poll
%%end:


%endmacro

ata_pio_error:
    pusha
    mov dh, VGA_COLOR_WHITE
    mov dl, VGA_COLOR_RED
    call kernel_terminal_set_color
    mov esi, .fatalerr
    call kernel_terminal_write_string
    popa
    jmp kernel_halt
    
.fatalerr: db "Fatal disk reading error! Use a debugger to see the state of the registers", 0

; IN = EDI: Disk buffer, ESI: LBA address (as an immediate value, not the location of the value), ECX: Amount of sectors to load
; OUT = Disk buffer filled. Carry set if driver is busy
kernel_ata_pio_read:    

    pusha

    cmp dword [kernel_ata_pio_pointer_to_buffer], 0 ; Driver busy?
    jne .busy
    mov dword [kernel_ata_pio_pointer_to_buffer], edi
    mov byte [kernel_ata_pio_writing], 0



    mov     dx, ATA_PRIMARY_DATA + 6         ; Drive and head port
    mov     al, 0xB0 ; Drive 2

    call kernel_ata_pio_lba_to_head

    or      al, bl
    out     dx, al
    

    mov     dx, ATA_PRIMARY_DATA + 2         ; Sector count port
    mov     al, 1    
    out     dx, al

    call kernel_ata_pio_lba_to_sector

    mov     dx,ATA_PRIMARY_DATA + 3         ;Sector number port
    mov     al, bl            
    out     dx, al

    call kernel_ata_pio_lba_to_cylinder

    mov     dx, ATA_PRIMARY_DATA + 4         ; Cylinder low port
    mov     al, bl
    out     dx, al


    mov     dx, ATA_PRIMARY_DATA + 5         ; Cylinder high port
    mov     al, bh

    out     dx, al
    
    sti
    mov     dx, ATA_PRIMARY_DATA + 7 ; Command port
    mov     al, 0x20          ; Read sectors
    out     dx, al

    
    kernel_ata_pio_poll
    
.stoppolling:

    int 2eh

    clc

    popa
    ret
.busy:

    stc ; Set carry flag
    popa
    ret

; IN = ESI: Disk buffer, EDI: LBA address (as an immediate value, not the location of the value), ECX: Amount of sectors to load
; OUT = Disk buffer filled. Carry set if driver is busy
kernel_ata_pio_write:    

    pusha


    cmp dword [kernel_ata_pio_pointer_to_buffer], 0 ; Driver busy?
    jne .busy
    mov dword [kernel_ata_pio_pointer_to_buffer], esi
    mov byte [kernel_ata_pio_writing], 1

    xchg esi, edi

    mov     dx, ATA_PRIMARY_DATA + 6         ; Drive and head port
    mov     al, 0xB0 ; Drive 2

    call kernel_ata_pio_lba_to_head

    or      al, bl
    out     dx, al
    

    mov     dx, ATA_PRIMARY_DATA + 2         ; Sector count port
    mov     al, 1    
    out     dx, al

    call kernel_ata_pio_lba_to_sector

    mov     dx,ATA_PRIMARY_DATA + 3         ;Sector number port
    mov     al, bl            
    out     dx, al

    call kernel_ata_pio_lba_to_cylinder

    mov     dx, ATA_PRIMARY_DATA + 4         ; Cylinder low port
    mov     al, bl
    out     dx, al


    mov     dx, ATA_PRIMARY_DATA + 5         ; Cylinder high port
    mov     al, bh

    out     dx, al

    sti
    mov     dx, ATA_PRIMARY_DATA + 7 ; Command port
    mov     al, 0x30          ; Write sectors
    out     dx, al
    
    
    kernel_ata_pio_poll
    
    int 2eh
    
    mov     dx, ATA_PRIMARY_DATA + 7 ; Command port
    mov     al, 0xe7          ; Cache flush, sometimes needed
    out     dx, al
    
    kernel_ata_pio_poll_nodrq
    
    
    
    clc
    
    popa
    ret
.busy:

    stc ; Set carry flag
    popa
    ret

kernel_ata_pio_pointer_to_buffer dd 0

kernel_ata_pio_irq_handler:
    pusha
    
    cmp byte [kernel_ata_pio_writing], 0
    jne .write

.read:
    call kernel_ata_pio_read_irq
    jmp .done

.write:
    call kernel_ata_pio_write_irq
    jmp .done

.done:
    
    mov dword [kernel_ata_pio_pointer_to_buffer], 0 ; Clear the buffer pointer to signal that the drive is not busy

    mov al,20h
    out 0xA0,al  ; acknowledge the interrupt to both PICs
    out 0x20,al  ;

    popa
    iret


kernel_ata_pio_read_irq:

    mov ecx, 0x200 ; Must transfer 512 bytes
    mov edi, [kernel_ata_pio_pointer_to_buffer]

    mov dx, ATA_PRIMARY_DATA
.loopy:
    in ax, dx


    mov [edi], ax

    add edi, 2
    sub ecx, 2
    cmp ecx, 0
    jne .loopy
.done:
    ret


kernel_ata_pio_write_irq:

    mov ecx, 0x200 ; Must transfer 512 bytes
    mov esi, [kernel_ata_pio_pointer_to_buffer]

    mov dx, ATA_PRIMARY_DATA
.loopy:
    mov ax, [esi]

    out dx, ax


    add esi, 2
    sub ecx, 2
    cmp ecx, 0
    jne .loopy

.done:
    ret




kernel_ata_pio_heads_per_cylinder dd 16
kernel_ata_pio_sectors_per_track dd 63

; C = LBA ÷ (HPC × SPT)
; IN = ESI: LBA
; OUT = BL: Cylinder
kernel_ata_pio_lba_to_cylinder:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0
    mov ebx, 0

    mov bl, [kernel_ata_pio_heads_per_cylinder]
    mov al, [kernel_ata_pio_sectors_per_track]
    mul ebx

    mov ebx, eax

    mov eax, esi


    div ebx

    mov ebx, eax

    pop edx
    pop eax
    ret

; H = (LBA ÷ SPT) mod HPC
; IN = ESI: LBA
; OUT = BL: Head
kernel_ata_pio_lba_to_head:

    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere


    mov eax, esi
    mov ebx, [kernel_ata_pio_sectors_per_track]
    div ebx ; Quotient on eax

    mov edx, 0 ; Clear more garbage
    mov ebx, [kernel_ata_pio_heads_per_cylinder]
    div ebx ; Remainder on edx

    mov ebx, edx

    pop edx
    pop eax
    ret


; S = (LBA mod SPT) + 1
; IN = ESI: LBA
; OUT = BL: Head
kernel_ata_pio_lba_to_sector:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0

    mov eax, esi
    mov ebx, [kernel_ata_pio_sectors_per_track]
    div ebx ; Remainder on edx

    mov ebx, 0

    mov bl, dl
    inc bl


    pop edx
    pop eax
    ret