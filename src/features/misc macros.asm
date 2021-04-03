%macro DEBUG_PRINT 1
	mov esi, %%string
	call kernel_terminal_write_string
	section .data
	%%string: db %1, 0
	section .text
%endmacro

%macro FATAL_ERROR 1
	mov dl, VGA_COLOR_WHITE
	mov dH, VGA_COLOR_RED
	call kernel_terminal_set_color
	DEBUG_PRINT %1
	call kernel_halt
%endmacro