struc kernel_multiprocessing_mp_pointer_structure
	.signature resb 4
	.configuration_table resd 1
	.length resb 1
	.revision resb 1
	.checksum resb 1
	.default_configuration resb 1
	.features resd 1
	.end:
endstruc

kernel_multiprocessing_mp_pointer_table_location: dd 0
kernel_multiprocessing_mp_configuration_table_location: dd 0

kernel_multiprocessing_debug_print_mp_table_data:
	pusha
	mov ebx, [kernel_multiprocessing_mp_configuration_table_location]
	
	DEBUG_PRINT {"OEMID: ", '"'}
	mov esi, ebx
	add esi, 8
	mov ecx, 8
	call kernel_terminal_write
	
	DEBUG_PRINT {'"', 0xa, "PRODUCT ID: ", '"'}
	mov ecx, 8
	mov esi, ebx
	add esi, 16
	mov ecx, 12
	call kernel_terminal_write
	DEBUG_PRINT {'"', 0xa}
	
	popa
	ret

kernel_multiprocessing_find_mp_table:
	mov esi, KERNEL_BASE + 0xF0000
	mov ecx, (0x100000 - 0xF0000) / 16
	call kernel_multiprocessing_find_mp_table_at
	jnc .found
	FATAL_ERROR "MP table not found!"
.found:
	mov eax, [esi+kernel_multiprocessing_mp_pointer_structure.configuration_table]
	add eax, KERNEL_BASE
	mov [kernel_multiprocessing_mp_configuration_table_location], eax
	mov [kernel_multiprocessing_mp_pointer_table_location], esi
	
	call kernel_multiprocessing_debug_print_mp_table_data
	
	ret
	
; IN = ESI: Start location, ECX: Checksum area length
; OUT = ZF set if checksum passed
kernel_checksum_addition_byte:
	pusha
	xor eax, eax
.loopy:
	add al, [esi]
	inc esi
	dec ecx
	jnz .loopy
	
	cmp al, 0
	popa
	ret
		

; IN = ESI: Start location, ECX: Length to search / 16
; OUT = ESI: Location, Registers may be altered
kernel_multiprocessing_find_mp_table_at:
.loopy:
	mov eax, [esi]
	cmp eax, "_MP_"
	je .found
	
	add esi, 16
	dec ecx
	jnz .loopy
	stc
	ret
.found:
	push ecx
	mov ecx, kernel_multiprocessing_mp_pointer_structure.end 
	call kernel_checksum_addition_byte
	jz .checksum_passed
	pop ecx
	jmp .loopy
.checksum_passed:
	pop ecx
	clc
	ret