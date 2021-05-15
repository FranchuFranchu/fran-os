%include "src/features/streams/backends/test.asm"

struc kernel_stream_backend_struct
	.open	resd 1
	; IN = ESI: Writable buffer, ECX: Length of said buffer
	.read	resd 1
	.write	resd 1
	.end:
endstruc

kernel_stream_backend_map:
	dd 0 ; 0
	dd kernel_test_backend_test_struct ; 1
kernel_stream_backend_map_end:

%define kernel_stream_backend_map_size ((kernel_stream_backend_map_end - kernel_stream_backend_map) / 4 + 1)
