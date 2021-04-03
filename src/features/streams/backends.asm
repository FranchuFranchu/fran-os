%include "./backends/test.asm"

struc backend
	.open	resd 1
	; IN = ESI: Writable buffer, ECX: Length of said buffer
	.read	resd 1
	.write	resd 1
	.end:
endstruc

kernel_stream_backend_map:
	dd 1, 
