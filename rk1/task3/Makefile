asm_swap_files: swap_files.asm
	fasm swap_files.asm

comp_swap_files: asm_swap_files
	ld swap_files.o -o swap_files

clear:
	rm -f ./swap_files ./swap_files.o
