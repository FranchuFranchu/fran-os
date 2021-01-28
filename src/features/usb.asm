KERNEL_PCI_CLASS_SERIAL_BUS_CONTROLLER equ 0xC
KERNEL_PCI_SUBCLASS_USB_CONTROLLER equ 0x3
KERNEL_PCI_PROG_IF_UHCI equ 0x0
KERNEL_PCI_PROG_IF_OHCI equ 0x10
KERNEL_PCI_PROG_IF_EHCI equ 0x20
KERNEL_PCI_PROG_IF_XHCI equ 0x30


; Device locations in PCI bus for each controller type
kernel_controller_devices:
    kernel_usb_uhci_controller dd 0
    kernel_usb_ohci_controller dd 0
    kernel_usb_ehci_controller dd 0
    kernel_usb_xhci_controller dd 0

kernel_usb_setup:



    mov ebx, kernel_usb_find_device
    call kernel_pci_for_each_device

    mov eax, [kernel_usb_xhci_controller]
    ret

; Make the list of controllers
kernel_usb_find_device:
    push ebx
    push ecx



    ; Make sure header type is 00h
    mov eax, ecx
    or eax, 0xC
    call kernel_pci_config_read_dword
    and eax, 0x00FF00000 ; Header Type

    cmp eax, 0
    jnz .end


    ; Make sure class and subclass is USB
    mov eax, ecx
    or eax, 0x8
    call kernel_pci_config_read_dword
    shr eax, 16

    ; Now EAX is class:subclass
    cmp eax, KERNEL_PCI_CLASS_SERIAL_BUS_CONTROLLER << 8 | KERNEL_PCI_SUBCLASS_USB_CONTROLLER
    jne .end


    mov eax, ecx
    or eax, 0x8
    call kernel_pci_config_read_dword
    shr eax, 12
    and eax, 0xF
    mov ebx, eax

    cmp eax, 3 ; > 0x40
    jg .end

    mov ebx, eax

    mov [kernel_controller_devices+ebx*4], ecx




.end:


    pop ecx
    pop ebx
    ret