[bits 16]
[org 0x7c00]
 
start:
  cli    
  
  mov ax, 07C0h   ; Set up 4K stack space after this bootloader
  add ax, 288   ; (4096 + 512) / 16 bytes per paragraph
  mov ss, ax
  mov sp, 4096

  mov ah, 02h
  mov al, 63
  mov dl, dl
  mov ch, 0
  mov cl, 2
  mov dh, 0
  mov bx, disk_buffer

  int 13h

  mov si, .stri
  call print_string

  jmp disk_buffer

  .stri db "MBR: Executed correctly.", 0xd, 0xa, 0 ; 0xd: CR, 0xA: LF
 

print_string:     ; Routine: output string in SI to screen
  mov ah, 0Eh   ; int 10h 'print char' function

.repeat:
  lodsb     ; Get character from string
  cmp al, 0
  je .done    ; If char is zero, end of string
  int 10h     ; Otherwise, print it
  jmp .repeat

.done:
  ret


times (218 - ($-$$)) nop      ; Pad for disk time stamp
 
DiskTimeStamp times 8 db 0    ; Disk Time Stamp
 
bootDrive db 0                ; Our Drive Number Variable
PToff dw 0                    ; Our Partition Table Entry Offset
 
times (0x1b4 - ($-$$)) nop    ; Pad For MBR Partition Table

UID times 10 db 0             ; Unique Disk ID
PT1 times 16 db 0
PT2 times 16 db 0             ; Second Partition Entry
PT3 times 16 db 0             ; Third Partition Entry
PT4 times 16 db 0             ; Fourth Partition Entry
 
dw 0xAA55                     ; Boot Signature

disk_buffer: