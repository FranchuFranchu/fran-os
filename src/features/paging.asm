
; IN = EAX: Page table address (4KiB aligned), EBX: Future location of PDT, AL: Flags
%define os_paging_make_pde mov [ebx], eax

; IN = EAX: Physical address to map to (4KiB aligned) address, EBX: Future location of PDT, AL: Flags
%define os_paging_make_pte mov [ebx], eax

; OUT = AL: Common page flags
%define os_paging_set_default_page_flags mov al, 111b


os_paging_setup:
    pusha

    call os_paging_identity_paging

    mov eax, os_paging_page_directory_table
    mov cr3, eax
     
    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax

    popa
    ret

os_paging_identity_paging:
    ret

os_paging_page_directory_table:
times 1024 dd 0
os_paging_page_tables:
%rep 1024
    times 1024 dd 0
%endrep