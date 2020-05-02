; Does nothing
%define os_no_operation 0

; IN = esi: File descriptor, eax: Bytes to read, edi: Buffer
; OUT = edi: Filled buffer
%define os_read_file 1

; Dumps the EAX register
; IN = eax: Register to dump
%define os_debug 2

