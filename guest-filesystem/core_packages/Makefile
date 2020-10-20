sNASM_FLAGS = -I../../macros/

bin/%: src/*.asm
	nasm $(NASM_FLAGS) -o $@ $<

all: bin/init