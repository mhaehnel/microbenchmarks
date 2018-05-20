SOURCES=$(wildcard *.asm)
LINK.o=ld

#$(info Sources: $(SOURCES))

all: $(SOURCES:.asm=)

%.o: %.asm
	nasm -f elf64 $<

clean:
	rm -rf $(SOURCES:.asm=.o) $(SOURCES:.asm=)
