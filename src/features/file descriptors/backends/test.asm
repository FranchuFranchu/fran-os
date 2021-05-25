kernel_test_backend_test_open:
	call kernel_debug_print_eax
	ret
kernel_test_backend_test_read:
	mov dword [ebx], 0
	ret
kernel_test_backend_test_struct:
	.open dd kernel_test_backend_test_open
	.read dd kernel_test_backend_test_read
	.write dd 0