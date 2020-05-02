; Generated from tools/make_sysenter_vectors.py

; Does nothing
%define os_no_operation 0

; Dumps the EAX register
; IN = eax: Register to dump
%define os_debug_print_eax 1

; Makes the CPU sleep
; IN = eax: Status code
%define os_terminate_process 2

; IN = esi: File descriptor, eax: Bytes to read, edi: Buffer
; OUT = edi: Filled buffer
%define os_read 3

; IN = edi: File descriptor, eax: Bytes to read, esi: Buffer
%define os_write 4

