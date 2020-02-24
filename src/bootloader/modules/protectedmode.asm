pm_gdt:
 
pm_gdt_null:
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0
 
pm_gdt_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 10011010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

pm_gdt_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 10010010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0x0

pm_gdt_end:
 
pm_gdt_desc:
   dw pm_gdt_end - pm_gdt - 1
   dd pm_gdt

pm_start:
    cli
    xor ax, ax
    mov ds, ax
    
    lgdt [pm_gdt_desc]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 8h:clear_pipe
    
clear_pipe:
    mov ax, 10h
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp in_protected