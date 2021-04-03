kernel_test_backend_test_open:
	ret
kernel_test_backend_test_read:
	mov [ebx], 0
	ret
kernel_test_backend_test_struct:
	.open dd kernel_test_backend_test_open
	.read dd kernel_test_backend_test_read
	.write dd 0