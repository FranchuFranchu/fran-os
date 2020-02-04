scancode_to_lowercase:
	.c00: db 0   	; non-us-1
	.c01: db 0   	; esc
	.c02: db "1" 	; 1
	.c03: db "2" 	; 2
	.c04: db "3" 	; 3
	.c05: db "4" 	; 4
	.c06: db "5" 	; 5
	.c07: db "6" 	; 6
	.c08: db "7" 	; 7
	.c09: db "8" 	; 8
	.c0a: db "9" 	; 9
	.c0b: db "0" 	; 0
	.c0c: db "-" 	; -
	.c0d: db "=" 	; =
	.c0e: db 0   	; backspace
	.c0f: db 0   	; tab
	.c10: db "q" 	; q
	.c11: db "w" 	; w
	.c12: db "e" 	; e
	.c13: db "r" 	; r
	.c14: db "t" 	; t
	.c15: db "y" 	; y
	.c16: db "u" 	; u
	.c17: db "i" 	; i
	.c18: db "o" 	; o
	.c19: db "p" 	; p
	.c1a: db "[" 	; [
	.c1b: db "]" 	; ]
	.c1c: db 0   	; enter
	.c1d: db 0   	; lctrl
	.c1e: db "a" 	; a
	.c1f: db "s" 	; s
	.c20: db "d" 	; d
	.c21: db "f" 	; f
	.c22: db "g" 	; g
	.c23: db "h" 	; h
	.c24: db "j" 	; j
	.c25: db "k" 	; k
	.c26: db "l" 	; l
	.c27: db ";" 	; ;
	.c28: db "'" 	; '
	.c29: db "`" 	; `
	.c2a: db 0   	; lshift
	.c2b: db "\" 	; \
	.c2c: db "z" 	; z
	.c2d: db "x" 	; x
	.c2e: db "c" 	; c
	.c2f: db "v" 	; v
	.c30: db "b" 	; b
	.c31: db "n" 	; n
	.c32: db "m" 	; m
	.c33: db "," 	; ,
	.c34: db "." 	; .
	.c35: db "/" 	; /
	.c36: db 0   	; rshift
	.c37: db 0   	; kp-*
	.c38: db 0   	; lalt
	.c39: db 0   	; space
	.c3a: db 0   	; capslock
	.c3b: db 0   	; f1
	.c3c: db 0   	; f2
	.c3d: db 0   	; f3
	.c3e: db 0   	; f4
	.c3f: db 0   	; f5
	.c40: db 0   	; f6
	.c41: db 0   	; f7
	.c42: db 0   	; f8
	.c43: db 0   	; f9
	.c44: db 0   	; f10
	.c45: db 0   	; numlock
	.c46: db 0   	; scrolllock
	.c47: db 0   	; kp-7
	.c48: db 0   	; kp-8
	.c49: db 0   	; kp-9
	.c4a: db 0   	; kp--
	.c4b: db 0   	; kp-4
	.c4c: db 0   	; kp-5
	.c4d: db 0   	; kp-6
	.c4e: db 0   	; kp-+
	.c4f: db 0   	; kp-1
	.c50: db 0   	; kp-2
	.c51: db 0   	; kp-3
	.c52: db 0   	; kp-0
	.c53: db 0   	; kp-.
	.c54: db 0   	; alt+sysrq
	.c55: db 0   	; None
	.c56: db 0   	; None
	.c57: db 0   	; f11
	.c58: db 0   	; f12
	.c59: db 0   	; None
	.c5a: db 0   	; None
	.c5b: db 0   	; None
	.c5c: db 0   	; None
	.c5d: db 0   	; None
	.c5e: db 0   	; None
	.c5f: db 0   	; None
	.c60: db 0   	; None
	.c61: db 0   	; None
	.c62: db 0   	; None
	.c63: db 0   	; None
	.c64: db 0   	; None
	.c65: db 0   	; None
	.c66: db 0   	; None
	.c67: db 0   	; None
	.c68: db 0   	; None
	.c69: db 0   	; None
	.c6a: db 0   	; None
	.c6b: db 0   	; None
	.c6c: db 0   	; None
	.c6d: db 0   	; None
	.c6e: db 0   	; None
	.c6f: db 0   	; None
	.c70: db 0   	; None
	.c71: db 0   	; None
	.c72: db 0   	; None
	.c73: db 0   	; None
	.c74: db 0   	; None
	.c75: db 0   	; None
	.c76: db 0   	; None
	.c77: db 0   	; None
	.c78: db 0   	; None
	.c79: db 0   	; None
	.c7a: db 0   	; None
	.c7b: db 0   	; None
	.c7c: db 0   	; None
	.c7d: db 0   	; None
	.c7e: db 0   	; None
	.c7f: db 0   	; None
	.c80: db 0   	; None
	.c81: db 0   	; None
	.c82: db 0   	; None
	.c83: db 0   	; None
	.c84: db 0   	; None
	.c85: db 0   	; None
	.c86: db 0   	; None
	.c87: db 0   	; None
	.c88: db 0   	; None
	.c89: db 0   	; None
	.c8a: db 0   	; None
	.c8b: db 0   	; None
	.c8c: db 0   	; None
	.c8d: db 0   	; None
	.c8e: db 0   	; None
	.c8f: db 0   	; None
	.c90: db 0   	; None
	.c91: db 0   	; None
	.c92: db 0   	; None
	.c93: db 0   	; None
	.c94: db 0   	; None
	.c95: db 0   	; None
	.c96: db 0   	; None
	.c97: db 0   	; None
	.c98: db 0   	; None
	.c99: db 0   	; None
	.c9a: db 0   	; None
	.c9b: db 0   	; None
	.c9c: db 0   	; None
	.c9d: db 0   	; None
	.c9e: db 0   	; None
	.c9f: db 0   	; None
	.ca0: db 0   	; None
	.ca1: db 0   	; None
	.ca2: db 0   	; None
	.ca3: db 0   	; None
	.ca4: db 0   	; None
	.ca5: db 0   	; None
	.ca6: db 0   	; None
	.ca7: db 0   	; None
	.ca8: db 0   	; None
	.ca9: db 0   	; None
	.caa: db 0   	; None
	.cab: db 0   	; None
	.cac: db 0   	; None
	.cad: db 0   	; None
	.cae: db 0   	; None
	.caf: db 0   	; None
	.cb0: db 0   	; None
	.cb1: db 0   	; None
	.cb2: db 0   	; None
	.cb3: db 0   	; None
	.cb4: db 0   	; None
	.cb5: db 0   	; None
	.cb6: db 0   	; None
	.cb7: db 0   	; None
	.cb8: db 0   	; None
	.cb9: db 0   	; None
	.cba: db 0   	; None
	.cbb: db 0   	; None
	.cbc: db 0   	; None
	.cbd: db 0   	; None
	.cbe: db 0   	; None
	.cbf: db 0   	; None
	.cc0: db 0   	; None
	.cc1: db 0   	; None
	.cc2: db 0   	; None
	.cc3: db 0   	; None
	.cc4: db 0   	; None
	.cc5: db 0   	; None
	.cc6: db 0   	; None
	.cc7: db 0   	; None
	.cc8: db 0   	; None
	.cc9: db 0   	; None
	.cca: db 0   	; None
	.ccb: db 0   	; None
	.ccc: db 0   	; None
	.ccd: db 0   	; None
	.cce: db 0   	; None
	.ccf: db 0   	; None
	.cd0: db 0   	; None
	.cd1: db 0   	; None
	.cd2: db 0   	; None
	.cd3: db 0   	; None
	.cd4: db 0   	; None
	.cd5: db 0   	; None
	.cd6: db 0   	; None
	.cd7: db 0   	; None
	.cd8: db 0   	; None
	.cd9: db 0   	; None
	.cda: db 0   	; None
	.cdb: db 0   	; None
	.cdc: db 0   	; None
	.cdd: db 0   	; None
	.cde: db 0   	; None
	.cdf: db 0   	; None
	.ce0: db 0   	; None
	.ce1: db 0   	; None
	.ce2: db 0   	; None
	.ce3: db 0   	; None
	.ce4: db 0   	; None
	.ce5: db 0   	; None
	.ce6: db 0   	; None
	.ce7: db 0   	; None
	.ce8: db 0   	; None
	.ce9: db 0   	; None
	.cea: db 0   	; None
	.ceb: db 0   	; None
	.cec: db 0   	; None
	.ced: db 0   	; None
	.cee: db 0   	; None
	.cef: db 0   	; None
	.cf0: db 0   	; None
	.cf1: db 0   	; None
	.cf2: db 0   	; None
	.cf3: db 0   	; None
	.cf4: db 0   	; None
	.cf5: db 0   	; None
	.cf6: db 0   	; None
	.cf7: db 0   	; None
	.cf8: db 0   	; None
	.cf9: db 0   	; None
	.cfa: db 0   	; None
	.cfb: db 0   	; None
	.cfc: db 0   	; None
	.cfd: db 0   	; None
	.cfe: db 0   	; None
	.cff: db 0   	; None
