struc kernel_acpi_rsdp_descriptor
	.signature: resb 8
	.checksum: resb 1
	.oemid: resb 6 
	.revision: resb 1
	; The physical address of the real table
	.address: resd 1
	
	.acpi1_end:
	
	; The following fields are used in ACPI 2.0 only
	.length: resd 1
	.xsdt_address: resq 1
	.extended_checksum: resb 1
	.reserved: resb 3
endstruc


kernel_acpi_find_rsdp_descriptor:
	pusha
	; https://wiki.osdev.org/RSDP#Detecting_the_RSDP
	; Find it between 0xE0000 and 0xFFFFF
	mov esi, 0xC00E0000
	mov ecx, (0xFFFFF - 0xE0000) / 16
	call kernel_acpi_find_rsdp_loop
	jnc .end
	
	; Find it in the EBDA
	xor ebx, ebx
	mov bx, [0x040E]
	add ebx, 0xC0000000
	
	
	xor eax, eax
	mov ax, [ebx]
	
	mov ebx, 0xC0000000
	add ebx, eax
	
	
	mov esi, [ebx]
	mov ecx, 1024
	call kernel_acpi_find_rsdp_loop
	
.end:
	clc
	add eax, 0xC0000000
	mov esi, eax
	mov eax, [esi]
	popa
	jmp $
	ret
	
	
	
kernel_acpi_find_rsdp_loop:
	dec ecx
	jz .not_found
	add esi, 16
	
	mov eax, [esi]
	cmp eax, "RSD "
	jne kernel_acpi_find_rsdp_loop
	call kernel_debug_print_eax
	
	mov eax, [esi+4]
	cmp eax, "PTR "
	jne kernel_acpi_find_rsdp_loop
	call kernel_debug_print_eax
	
	mov eax, [esi+kernel_acpi_rsdp_descriptor.address]
	
	call kernel_acpi_validate_rsdp_table
	jnc kernel_acpi_find_rsdp_loop
	clc
	
	ret
	
.not_found:
	stc
	ret
	
kernel_acpi_validate_rsdp_table:
	pusha
	xor eax, eax
	mov ebx, esi
	mov ecx, kernel_acpi_rsdp_descriptor.acpi1_end
.loopy:
	add al, [esi]
	inc esi
	dec ecx
	jnz .loopy
	
	cmp al, 0
	jne .invalid
	clc
	popa
	ret

.invalid:
	stc
	popa
	ret