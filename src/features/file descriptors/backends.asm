%include "src/features/file descriptors/backends/test.asm"
%include "src/features/file descriptors/backends/filesystem.asm"

struc kernel_file_descriptor_backend_struct
	.open	resd 1
	; IN = ESI: Writable buffer, ECX: Length of said buffer
	.read	resd 1
	.write	resd 1
	.end:
endstruc

kernel_file_descriptor_backend_map:
	dd 0 ; 0
	dd kernel_test_backend_test_struct ; 1
	dd kernel_backend_filesystem_struct ; 2
kernel_file_descriptor_backend_map_end:

%define kernel_file_descriptor_backend_map_size ((kernel_file_descriptor_backend_map_end - kernel_file_descriptor_backend_map) / 4 + 1)
