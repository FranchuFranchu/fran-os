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
; OUT = edi: Filled buffer, eax: Bytes read
%define os_read 3

; IN = edi: File descriptor, eax: Bytes to write, esi: Buffer
; OUT = eax: Bytes extended
%define os_write 4

; IN = esi: File descriptor, eax: New position in File descriptor
%define os_seek 5

; IN = esi: File descriptor
%define os_close 6

; IN = esi: Argument to pass to backend (can be a path, an integer, anything basically), edi: Backend number, eax: Flags, ebp: Flags 2
; OUT = edi: File descriptor
%define os_open 7

; Copies the whole file descriptor contents to memory, then replaces the process with it.
; IN = esi: File descriptor
%define os_execute 8

; Copies the whole file descriptor contents to memory, then creates a new process from it.
; IN = esi: File descriptor
; OUT = eax: New PID
%define os_fork_and_execute 9

; Forks another process from the current process. Processes don't share code, data or stack
; OUT = eax: New thread ID if it's the new process, else 0
%define os_fork_process 10

; Forks another thread from the current thread. Threads share code and data, but not stack.
; OUT = eax: New thread ID if it's the new thread, else 0
%define os_fork_thread 11

; IN = eax: File descriptor, ecx: Bitmask specifying where the interactions to accept are set and the interactions to reject are cleared
%define os_set_file_descriptor_interactions 12

; IN = eax: File descriptor
; OUT = eax: Interaction bitmask set by the peer
%define os_get_file_descriptor_interactions 13

; Waits for the peer to set or clear flags, then sets the values at "edi" to the result of the interactions
; IN = eax: File descriptor, ecx: Bitmask specifying the necessary interactions, edx: Bitmask specifying which of those interactions need to be cleared or set
%define os_wait_for_interaction 14

