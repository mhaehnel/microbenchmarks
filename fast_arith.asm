global _start

section .text

_start: MOV RAX,0
	MOV R10,(1<<31)
_loop:  ADD RAX,R10
	JNZ _loop

	MOV RAX,0x3C ;exit
	MOV RDI,0x0  ;return 0
	SYSCALL
