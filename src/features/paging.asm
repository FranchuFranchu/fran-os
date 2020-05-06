%define kernel_paging_directory_index(vaddr) (vaddr >> 20) * 4

extern page_directory
extern _kernel_size
extern _kernel_pages
extern _kernel_page_index_end

KERNEL_PAGING_FLAG_4MIB equ 0x80
KERNEL_PAGING_FLAG_ACCESSED equ 0x20
KERNEL_PAGING_FLAG_CACHE_DISABLE equ 0x10
KERNEL_PAGING_FLAG_WRITE_THROUGH equ 0x08
KERNEL_PAGING_FLAG_USER equ 0x04
KERNEL_PAGING_FLAG_READ_AND_WRITE equ 0x02
KERNEL_PAGING_FLAG_PRESENT equ 0x01

; OUT: EAX: upper Memory / 1024
kernel_paging_get_memory:
    push ebx


    mov ebx, [kernel_multiboot_info_pointer]
    mov eax, [ebx]
    ; EAX has flags
    and eax, 1
    ; If it's zero then it means that the bootloader didn't tell us the memory
    ; Crash the system if that is the case
    jz kernel_exception_fault

    mov eax, [ebx+8]

    pop ebx
    ret

kernel_paging_get_unallocated_page_directory_entry_in_kernel_space:
    mov ebx, kernel_paging_page_directory + kernel_paging_directory_index(0xc0000000)

.find:
    mov eax, [ebx]
    call kernel_debug_print_eax
    add ebx, 4
    cmp dword [ebx], 0
    jnz .find

    ret


kernel_paging_setup:
    
    call kernel_paging_get_memory
    
    ; EAX holds the amount of upper memory in KB
    ; 4MiB = 4194 KB
    mov edx, 0
    mov ebx, 4194
    div ebx
    mov ecx, eax
    ; ECX holds the amount of 4MiB pages we can use

    mov ebx, kernel_paging_directory_index(0xC0000000)
    mov eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE | KERNEL_PAGING_FLAG_4MIB

.fill_higher_half:
    dec ecx
    mov [page_directory+ebx], eax
    add eax, 4096*1024
    add ebx, 4
    cmp ebx, _kernel_page_index_end
    jng .fill_higher_half

    dec ecx

    or eax, KERNEL_PAGING_FLAG_USER
    mov ebx, 0
.fill_lower_half:
    cmp ecx, 0
    je .end

    mov [page_directory+ebx], eax
    add eax, 4096*1024
    add ebx, 4
    dec ecx

    jmp .fill_lower_half

.end:
    ; Reload
    mov ecx, cr3
    mov cr3, ecx    


    ret

kernel_paging_page_directory:
dd 0x83
times 1023 dd 0