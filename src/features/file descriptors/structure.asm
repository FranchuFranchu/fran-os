struc stream_descriptor
	; Process ID that owns this
	.owned_by resd 0	
	; These values specify the "kernel backend", which is the part of the kernel that handles interactions with this file descriptor
	.backend resd 0
	; The instance is a pointer to the backend-specific structure
	.instance resd 0 
	
endstruc