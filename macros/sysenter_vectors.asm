; Generated from tools/make_sysenter_vectors.py

; Does nothing
%define os_no_operation 0

; Dumps the EAX register
; IN = eax: Register to dump
%define os_debug_print_eax 1

; Makes the CPU sleep
; IN = eax: Status code
%define os_terminate_process 2

; IN = esi: Stream descriptor, eax: Bytes to read, edi: Buffer
; OUT = edi: Filled buffer, eax: Bytes read
%define os_read 3

; IN = edi: Stream descriptor, eax: Bytes to write, esi: Buffer
; OUT = eax: Bytes extended
%define os_write 4

; IN = esi: Stream descriptor, eax: New position in stream descriptor
%define os_seek 5

; IN = esi: Stream descriptor
%define os_close 6

; IN = esi: File path
; OUT = edi: Stream descriptor
%define os_open_filesystem_file 7

; Copies the whole stream descriptor to memory, then replaces the process with it.
; IN = esi: Stream descriptor
%define os_execute 8

; Copies the whole stream descriptor to memory, then creates a new process from it.
; IN = esi: Stream descriptor
%define os_execute_and_fork 9

; Forks another process from the current process. Processes don't share code, data or stack
; OUT = eax: New thread ID if it's the new process, else 0
%define os_fork_process 10

; Forks another thread from the current thread. Threads share code and data, but not stack.
; OUT = eax: New thread ID if it's the new thread, else 0
%define os_fork_thread 11

