; Macros and constants related to paging
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

KERNEL_VIRTUAL_BASE equ KERNEL_BASE					; 3GB
KERNEL_PAGE_NUMBER equ (KERNEL_VIRTUAL_BASE >> 22)	; Page directory index of kernel's 4MB PTE.



