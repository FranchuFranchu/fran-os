%define kernel_paging_directory_index(vaddr) ((vaddr >> 22) * 4)

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

KERNEL_VIRTUAL_BASE equ 0xC0000000                  ; 3GB
KERNEL_PAGE_NUMBER equ (KERNEL_VIRTUAL_BASE >> 22)  ; Page directory index of kernel's 4MB PTE.


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



kernel_paging_setup:
    
    call kernel_paging_get_memory

    ; EAX holds the amount of upper memory in KB
    ; 4MiB = 4194 KB
    mov edx, 0
    mov ebx, 4194
    div ebx
    mov ecx, eax
    ; ECX holds the amount of 4MiB pages we can use
 
    mov ebx, kernel_paging_directory_index(KERNEL_VIRTUAL_BASE)
    mov eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE | KERNEL_PAGING_FLAG_4MIB

    ; During the whole loop:
    ; EAX holds the first free physical address 
    ; EBX holds the first free virtual page directory

.fill_higher_half:

    dec ecx
    mov [kernel_paging_page_directory+ebx], eax
    add eax, 4096*1024
    add ebx, 4
    cmp ebx, _kernel_page_index_end*4
    jng .fill_higher_half

    
    dec ecx

    ; Now that we allocated the kernel text and data sections
    ; We have to configure stuff for dynamic page allocation

.make_meta_page_table:
    mov dword [kernel_paging_page_directory+ebx], kernel_paging_meta_page_table - KERNEL_VIRTUAL_BASE
    or dword [kernel_paging_page_directory+ebx], KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE

    push ebx


    shr bx, 2 ; Divide by 4
    mov [kernel_paging_meta_page_table_directory_entry], bx
    pop ebx

.end:
    sub eax, 4096
    mov [kernel_paging_first_free_physical_memory_address], eax
    add bx, 4
    mov [kernel_paging_first_free_page_table], bx

    mov dword [kernel_paging_page_directory+KERNEL_PAGE_NUMBER*4], 0x83
    ; Reload

    mov ecx, kernel_paging_page_directory - KERNEL_VIRTUAL_BASE
    mov cr3, ecx


    ret



; OUT = EBX: Virtual memory address where the page data is stored. Next 4KiB are guaranteed to be free
kernel_paging_new_kernel_page:

    xor ebx, ebx
    mov bx, [kernel_paging_first_free_page_table]

    mov eax, [kernel_paging_page_directory+ebx]
    cmp eax, 0
    je .no_page_directory_entry
    jne .yes_page_directory_entry

.no_page_directory_entry:
    
    push ebx
    call kernel_paging_physical_allocate_page_for_page_table
    mov [kernel_paging_current_kernel_page_table], ebx
    pop ebx

    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE
    mov [kernel_paging_page_directory+ebx], eax


.yes_page_directory_entry:
    mov ebx, [kernel_paging_current_kernel_page_table]


    add bx, [kernel_paging_first_free_page]

    call kernel_paging_physical_allocate_page

    or eax, 0x3

    mov [ebx], eax



    ; Now, if we reload cr3 we should be able to read the corresponding virtual memory address
    mov ecx, cr3
    mov cr3, ecx

.calculate_virtual_address
    xor ebx, ebx
    mov bx, [kernel_paging_first_free_page_table]
    mov ax, [kernel_paging_first_free_page]

    shl ebx, 20 ; Multiply by 4MiB and divide by 4
    shl eax, 10 ; Multiply by 4KiB and divide by 4

    add ebx, eax

    add word [kernel_paging_first_free_page], 4

    ret


    


; OUT = EAX: Physical memory address of page
kernel_paging_physical_allocate_page:
    mov eax, [kernel_paging_first_free_physical_memory_address]


    ; Round down to closest multiple of 4096
    and eax, 0xFFFFF000

    add eax, 4096


    mov [kernel_paging_first_free_physical_memory_address], eax
        
    ret

; This function allocates some space for a page table
; OUT = EAX: Physical memory address of address where the kernel can place page tables, EBX: Virtual memory address w/ page table
kernel_paging_physical_allocate_page_for_page_table:

    call kernel_paging_physical_allocate_page

    or eax, KERNEL_PAGING_FLAG_PRESENT | KERNEL_PAGING_FLAG_READ_AND_WRITE

    xor ebx, ebx
    mov bx, [kernel_paging_first_free_page_in_meta_page_table]



    mov [kernel_paging_meta_page_table+ebx*4], eax

    inc word [kernel_paging_first_free_page_in_meta_page_table]

    ; ebx * 4KiB + [pde of page table] * 4MiB = virtual address
    push eax

    xor eax, eax
    mov ax, [kernel_paging_meta_page_table_directory_entry]



    shl eax, 22 ; Divide by 4MiB
    shl ebx, 12 ; Divide by 4KiB 


    add ebx, eax
    mov eax, ebx

    pop eax
    and eax, 0xFFFFF000 ; Un-set flags

    ; We could use invlpg here
    ; But i'm not sure how
    ; Reload cr3 instead

    push ecx
    mov ecx, cr3
    mov cr3, ecx
    pop ecx

    ret

kernel_paging_meta_page_table_directory_entry: dw 0
kernel_paging_first_free_physical_memory_address: dd 0
kernel_paging_first_free_kernel_memory_address: dd 0
kernel_paging_first_free_page_in_meta_page_table: dw 0 ; Offset / 4

kernel_paging_current_kernel_page_table dd 0

kernel_paging_first_free_page_table dw 0
kernel_paging_first_free_page dw 0 ; Offset of the previous value

section .data


align 4096
kernel_paging_page_directory:
    times (KERNEL_PAGE_NUMBER ) dd 0                 ; Pages before kernel space.
    ; Define three entries for a 16MiB kernel
    dd 0
    ;dd 0x00000083
    times (1024 - KERNEL_PAGE_NUMBER + 1) dd 0  ; Pages after the kernel image.

align 4096
kernel_paging_meta_page_table:
    ; Since there are 1024 max page tables, and each page table takes up 4KiB,
    ; this page table should be enough to hold the pages for the page tables

    ; This page table holds the pages where future page tables will be placed
    ; Read the previous sentence very carefully
    times 1024 dd 0


section .text