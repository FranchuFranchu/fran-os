struc kernel_acpi_rdsp_descriptor
	.signature: resb 8
	.checksum: resb 1
	.oemid: resb 6 
	.revision: resb 1
	; The physical address of the real table
	.address: resd 1
	
	; The following fields are used in ACPI 2.0 only
	.length: resd 1
	.xsdt_address: resq 1
	.extended_checksum: resb 1
	.reserved: resb 3
endstruc

kernel_acpi_find_rdsp_descriptor:
	pusha
	; https://wiki.osdev.org/RSDP#Detecting_the_RSDP
	mov esi, 0xE0000
	mov ecx, 0xFFFFF - 0xE0000
.find_loop:
	dec ecx
	jz .not_found
	add esi, 16
	lodsd
	cmp eax, "RSD "
	jne .find_loop
	mov eax, [esi+16]
	cmp eax, "PTR "
	jne .find_loop
	
	mov eax, [esi+kernel_acpi_rdsp_descriptor.address]
	call kernel_debug_print_eax
	popa
	ret
	
.not_found:
	jmp kernel_halt
	