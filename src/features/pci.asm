PCI_INDEX       EQU     0CF8h
PCI_DATA        EQU     0CFCh


; Example IDs
; name   |vendor|device| description
; RedHat | 1b36 | 0005 | QEMU pci testdev
; Realtek| 10ec | 8029 | RTL-8029(AS) (ne2000 network card)
kernel_pci_setup:
    mov     eax, 80000000h | (4 << 11)
    call kernel_pci_config_read_dword
    call kernel_debug_print_eax
    ret

; IN: EAX's Format must be (hex)
; 00BBDDRR
; 0 must be 0
; B is the bus number
; DD has this structure (bits):
;   DDDDDFFF
;   D is the device number
;   F is the function number
; OUT: dword in the config address
kernel_pci_config_read_dword:
    or eax, 8000000h
    push dx
    mov     dx, PCI_INDEX
    out     dx, eax                 ; send our request out
    mov     dx, PCI_DATA            
    in      eax, dx                 ; read back 32bit value.
    pop dx
    ret


; EBX: Callback to call for each device
kernel_pci_for_each_device:
    pusha

    mov ecx, 80000000h


.loopy:
    add ecx, 1 << 11
    mov eax, ecx

    call kernel_pci_config_read_dword
    cmp eax, 0xFFFFFFFF
    je .end
    call ebx
    jmp .loopy


.end:

    popa
    ret