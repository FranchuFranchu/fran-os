; Implements sbrk() for the kernel

kernel_break_point dd 0

; Needs to be done after paging
kernel_set_break_setup:
	call kernel_paging_new_kernel_page.calculate_virtual_address
	mov [kernel_break_point], ebx
	mov eax, [kernel_break_point]
	
	ret

; https://linux.die.net/man/2/sbrk
; IN = ebx: Signed number representing how much to increment/decrement the kernel area
; OUT = ebx: New end of kernel memory
kernel_set_break:
	push eax
	push ecx
	cmp ebx, 0
	jnz .nonzero
	
; Zero
	mov ebx, [kernel_break_point]
	pop ecx
	pop eax
	ret
.nonzero:
	test ebx, 1 << 31
	jz .unsigned
.signed:
	and ebx, ~(1<<31)
	sub ebx, 1 << 31
	ret ; Freeing kernel pages isn't implemented yet
.unsigned:
	add ebx, [kernel_break_point]

.allocate_if_necessary:
	; Check if new pages need to be allocated
	mov eax, [kernel_break_point]
	
	shr ebx, 12
	shr eax, 12
	
	sub ebx, eax
	mov ecx, ebx
	
.loopy:
	cmp ecx, 0
	je .end
    
    push ecx
	call kernel_paging_new_kernel_page
	pop ecx
	
	dec ecx
	jmp .loopy
.end:
	add ebx, 4096
	mov [kernel_break_point], ebx
	pop ecx
	pop eax
	ret
	
	