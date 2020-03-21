ATA_PRIMARY_DATA equ 0x1F0
ATA_SECONDARY_DATA equ 0x170
ATA_PRIMARY_CONTROL equ 0x3F6
ATA_SECONDARY_CONTROL equ 0x376


os_ata_pio_setup:
    mov eax, os_ata_pio_irq_handler
    mov ebx, 2eh
    call os_define_interrupt

    ret

; IN = EDI: Disk buffer, ESI: LBA address (as an immediate value, not the location of the value), ECX: Amount of sectors to load
; OUT = Disk buffer filled. Carry set if driver is busy
os_ata_pio_read:    

    pusha

    cmp dword [os_ata_pio_pointer_to_buffer], 0 ; Driver busy?
    jne .busy
    mov dword [os_ata_pio_pointer_to_buffer], edi


    mov     dx, ATA_PRIMARY_DATA + 7 ; Status port
    in      al, dx   ; Haven't found a use for this yet        


    mov     dx, ATA_PRIMARY_DATA + 6         ; Drive and head port
    mov     al, 0xB0 ; Drive 2

    call os_ata_pio_lba_to_head

    or      al, bl
    out     dx, al
    

    mov     dx, ATA_PRIMARY_DATA + 2         ; Sector count port
    mov     al, 1    
    out     dx, al

    call os_ata_pio_lba_to_sector

    mov     dx,ATA_PRIMARY_DATA + 3         ;Sector number port
    mov     al, bl            
    out     dx, al

    call os_ata_pio_lba_to_cylinder

    mov     dx, ATA_PRIMARY_DATA + 4         ; Cylinder low port
    mov     al, bl
    out     dx, al


    mov     dx, ATA_PRIMARY_DATA + 5         ; Cylinder high port
    mov     al, bh

    out     dx, al

    mov     dx, ATA_PRIMARY_DATA + 7 ; Command port
    mov     al, 0x20          ; Read sectors
    out     dx, al


    clc
    popa
    ret
.busy:

    stc ; Set carry flag
    popa
    ret


os_ata_pio_pointer_to_buffer dd 0

os_ata_pio_irq_handler:
    pusha

    mov ecx, 0x200 ; Must transfer 512 bytes
    mov edi, [os_ata_pio_pointer_to_buffer]
    mov dx, ATA_PRIMARY_DATA
.loopy:
    in ax, dx

    mov [edi], ax


    add edi, 2
    sub ecx, 2
    cmp ecx, 0
    jne .loopy

.done:

    mov dword [os_ata_pio_pointer_to_buffer], 0 ; Clear the buffer pointer to signal that the drive is not busy

    mov al,20h
    out 0xA0,al  ; acknowledge the interrupt to both pics
    out 0x20,al  ;

    popa
    iret

os_ata_pio_heads_per_cylinder dd 16
os_ata_pio_sectors_per_track dd 63

; C = LBA ÷ (HPC × SPT)
; IN = ESI: LBA
; OUT = BL: Cylinder
os_ata_pio_lba_to_cylinder:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0
    mov ebx, 0

    mov bl, [os_ata_pio_heads_per_cylinder]
    mov al, [os_ata_pio_sectors_per_track]
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
os_ata_pio_lba_to_head:

    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere


    mov eax, esi
    mov ebx, [os_ata_pio_sectors_per_track]
    div ebx ; Quotient on eax

    mov edx, 0 ; Clear more garbage
    mov ebx, [os_ata_pio_heads_per_cylinder]
    div ebx ; Remainder on edx

    mov ebx, edx

    pop edx
    pop eax
    ret


; S = (LBA mod SPT) + 1
; IN = ESI: LBA
; OUT = BL: Head
os_ata_pio_lba_to_sector:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0

    mov eax, esi
    mov ebx, [os_ata_pio_sectors_per_track]
    div ebx ; Remainder on edx

    mov ebx, 0

    mov bl, dl
    inc bl


    pop edx
    pop eax
    ret