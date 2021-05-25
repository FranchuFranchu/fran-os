; IN = ESI: Path to open
kernel_backend_filesystem_open:
	call kernel_debug_print_eax
	ret
kernel_backend_filesystem_read:
	mov dword [ebx], 0
	ret
kernel_backend_filesystem_struct:
	.open dd kernel_backend_filesystem_open
	.read dd kernel_backend_filesystem_read
	.write dd 0