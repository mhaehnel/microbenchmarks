global _start

section .text

_start: ;Do a lot of multiplications
	MOV RAX,0x1337
	MOV R10,0x42
	MOV RCX,(1<<31) ;How often do mul?
_loop:
	MUL R10
	LOOP _loop

	MOV RAX,0x3C ;exit
	MOV RDI,0x0  ;return 0
	SYSCALL
