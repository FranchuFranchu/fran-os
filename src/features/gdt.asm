kernel_gdt:
 
kernel_gdt_null:
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0
 
kernel_gdt_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 10011010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

kernel_gdt_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 10010010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0
kernel_gdt_user_code:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0
 
  .base_16_23 db 0
  .access db 11111010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0

kernel_gdt_user_data:
  .limit_0_15 dw 0xFFFF
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  .access db 11110010b
  .limit_and_flags db 11001111b
  .base_24_31 db 0x0

kernel_gdt_task_state_segment:
  ; We don't know the values of these yet; kernel_userspace_setup will set them
  .limit_0_15 dw 0
  .base_0_15 dw 0x0
 
  .base_16_23 db 0x0
  ; Note that the "present" flag is cleared.
  .access db 01101001b
  .limit_and_flags db 00000000b
  .base_24_31 db 0x0

kernel_gdt_end:
 
kernel_gdt_desc:
  .size: dw kernel_gdt_end - kernel_gdt - 1
  .offset: dd kernel_gdt
