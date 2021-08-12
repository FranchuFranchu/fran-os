; Implements a type similar to C++'s std::vector<void*>

struc kernel_data_structure_vec
	.length resd 1
	.reserved_length resd 1
	; Pointer to the array of void*
	; Heap-allocated
	.data resd 1
	
	.size resd 0 ; Marker
endstruc

; IN = EAX: Amount to reserve, EBX: Pointer to struct
; OUT = EBX: Preserved
kernel_data_structure_vec_initialize:
	mov [ebx+kernel_data_structure_vec.reserved_length], eax
	call kernel_malloc
	mov [ebx+kernel_data_structure_vec.data], eax
	mov dword [ebx+kernel_data_structure_vec.length], 0
	ret
	
	
; IN = EAX: Amount to reserve (new size of vector), EBX: Vector pointer
; Eax not preserved
kernel_data_structure_vec_reserve:
	push esi
	
	mov [ebx+kernel_data_structure_vec.reserved_length], eax
	
	mov esi, [ebx+kernel_data_structure_vec.data]
	xchg esi, ebx
	
	; Multiply by 4
	shl eax, 2
	; Here, ebx is the .data pointer and eax is the amount to reserve
	call kernel_realloc
	; New pointer is in eax
	mov [esi+kernel_data_structure_vec.data], ebx
	
	pop esi
	ret

; Gets the first free or null index in the list
; IN = EBX: Vector pointer
; OUT = EBX: First free index
kernel_data_structure_vec_first_free:
	push ecx
	push edx
	; Push the vector pointer for later use
	push ebx
	
	mov ecx, [ebx+kernel_data_structure_vec.length]
	mov ebx, [ebx+kernel_data_structure_vec.data]
	mov ebx, [ebx+kernel_data_structure_vec.reserved_length]
	
	inc ecx
	; Iterate
.loopy
	dec ecx
	jz .found_free
	cmp dword [ebx], 0
	je .found_null
	add ebx, 4
	jmp .loopy
	
.found_free:
	; This is reached when we reached the end of the vector
	; Pop vector pointer
	pop ebx
	; Get the length and reserved length
	mov ecx, [ebx+kernel_data_structure_vec.reserved_length]
	mov edx, [ebx+kernel_data_structure_vec.length]
	; Check if we need to allocate more
	cmp edx, ecx
	jne .dont_allocate_more
	
.allocate_more
	; If the reserved length is the same then we need to allocate more
	; (16 just to be sure)
	push eax
	mov eax, ecx
	add eax, 16
	call kernel_data_structure_vec_reserve
	pop eax

.dont_allocate_more:
	; Add item at the end
	inc dword [ebx+kernel_data_structure_vec.length]
	mov ebx, [ebx+kernel_data_structure_vec.length]
	dec ebx
	
	
	jmp .end
	
.found_null:
	; Pop the vector pointer
	pop ebx
	; Get length
	mov ebx, [ebx+kernel_data_structure_vec.length]
	; Get our position in the data (relative to the start of the vector)
	sub ebx, ecx
	
.end:
	pop edx
	pop ecx
	ret