
kernel_lba_heads_per_cylinder db 16
kernel_lba_sectors_per_track db 64
; C = LBA ÷ (HPC × SPT)
; IN = ESI: LBA
; OUT = BL: Cylinder
kernel_lba_to_cylinder:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0
    mov ebx, 0

    mov bl, [kernel_lba_heads_per_cylinder]
    mov al, [kernel_lba_sectors_per_track]
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
kernel_lba_to_head:

    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov eax, 0
    mov ebx, 0


    mov eax, esi
    mov bl, [kernel_lba_sectors_per_track]
    div ebx ; Quotient on eax

    mov edx, 0 ; Clear more garbage
    mov ebx, 0
    mov bl, [kernel_lba_heads_per_cylinder]
    div ebx ; Remainder on edx

    mov ebx, edx

    pop edx
    pop eax
    ret


; S = (LBA mod SPT) + 1
; IN = ESI: LBA
; OUT = BL: Sector
kernel_lba_to_sector:
    push eax
    push edx

    mov edx, 0 ; Clear garbage data so it doesnt interfere
    mov ebx, 0

    mov eax, esi
    mov bl, [kernel_lba_sectors_per_track]
    div ebx ; Remainder on edx

    mov bl, dl
    inc bl

    pop edx
    pop eax
    ret

DRIVE equ 0x81
; IN = ESI: LBA, AL: Sector count, ES:BX Buffer pointer
; OUT = Registers for int 13h
kernel_lba_to_int13h:
    push es
    push bx
    mov ah, 02h ; Read sectors from drive
    push ax


    call kernel_lba_to_cylinder
    mov ch, bl

    call kernel_lba_to_head
    mov dh, bl

    call kernel_lba_to_sector
    mov cl, bl

    mov dl, DRIVE

    pop ax
    pop bx
    pop es
    ret