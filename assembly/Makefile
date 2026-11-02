CC = nasm
AS = nasm
LD = ld

all: main

main: main.o
	$(LD) -o main main.o -lpthread

main.o: main.asm
	$(AS) -f elf64 -o main.o main.asm

clean:
	rm -f main.o main

run: main
	./main 100000

.PHONY: all clean run
