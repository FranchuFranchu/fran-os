struc file_descriptor
	; Back-reference in the file descriptor array. Can be useful sometimes
	.number resd 1
	; Process ID that owns this
	.owned_by resd 1
	; These values specify the "kernel backend", which is the part of the kernel that handles interactions with this file descriptor
	.backend resd 1
	; The instance is a pointer to the backend-specific structure
	.instance resd 1
	
	; Size marker
	.size resd 0
	
endstruc