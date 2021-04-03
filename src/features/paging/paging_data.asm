
section .data

kernel_paging_first_free_physical_memory_address: dd 0
kernel_paging_meta_page_table_directory_entry: dw 0
kernel_paging_first_free_page_in_meta_page_table: dw 0 ; Offset / 4

kernel_paging_current_kernel_page_table dw 0 ; An offet in the page directory
kernel_paging_first_free_kernel_page dw 0 ; Offset in the page table pointed to by the previous value

kernel_paging_current_user_page_table dw 0 ; An offet in the page directory
kernel_paging_first_free_user_page dw 0 ; Offset in the page table pointed to by the previous value
kernel_paging_first_free_user_page_table dw 0



align 4096
kernel_paging_page_directory:
    times (KERNEL_PAGE_NUMBER ) dd 0                 ; Pages before kernel space.
    times (1024 - KERNEL_PAGE_NUMBER + 1) dd 0  ; Pages after the kernel image.

align 4096
kernel_paging_meta_page_table:
    ; Since there are 1024 max page tables, and each page table takes up 4KiB,
    ; this page table should be enough to hold the pages for the page tables

    ; This page table holds the pages where future page tables will be placed
    ; Read the previous sentence very carefully
    times 1024 dd 0


section .text