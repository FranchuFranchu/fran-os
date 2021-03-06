; This links together the C and Assembly code so that you won't have to push arguments to the stack yourself

global kernel_set_break_c
kernel_set_break_c:
	; We have to comply with the i386 system V ABI
	push ebp ; Create a new stack frame
	mov ebp, esp
	
	push ebx
	
 	; Push the offset
	mov ebx, [ebp+8]
	call kernel_set_break
	
	; The return value goes in EAX
	mov eax, ebx
	
	pop ebx
	
	pop ebp ; Restore stack frame
	ret
	
extern malloc
extern realloc

; IN = EAX: Amount of bytes to reserve
; OUT = EAX: Address of saved area
kernel_malloc:
	; Store scratch registers that may be modified by dlmalloc
	push ecx
	push edx
	
	push    ebp       ; save old call frame
    mov     ebp, esp  ; initialize new call frame
    push eax ; arg 1
    call malloc
    add esp, 4 ; Remove call arguments
    
    pop     ebp       ; restore old call frame
	
	pop edx
	pop ecx
    
    ret
    
; IN = EAX: Amount of bytes for new pointer, EBX: Pointer to realloc
; OUT = EAX: New pointer
kernel_realloc:
	push    ebp       ; save old call frame
    mov     ebp, esp  ; initialize new call frame
    push ebx ; arg 1
    push eax ; arg 2
    call realloc
    add esp, 4*2 ; Remove call arguments
    
    pop     ebp       ; restore old call frame
    
    ret
    

__errno_location_place: 
	dd 0
global __errno_location
__errno_location:
	mov ebx, __errno_location_place
	push ebx
	ret

global kernel_halt_log
kernel_halt_log:
	mov eax, 0xDEADC0DE
	call kernel_debug_print_eax
	jmp kernel_halt