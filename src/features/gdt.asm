os_gdt:
 
os_gdt_null:
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0
 
os_gdt_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 10011010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

os_gdt_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 10010010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0x0
os_gdt_user_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 11111010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

os_gdt_user_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 11110010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0x0
os_gdt_end:
 
os_gdt_desc:
  .size: dw os_gdt_end - os_gdt - 1
  .offset: dd os_gdt
