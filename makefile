showASCII: showASCII.o
	ld -o showASCII showASCII.o ../lib/show.o
showASCII.o: showASCII.asm
	nasm -f elf64 -g -F dwarf showASCII.asm
