global _start

section .text

_start: ;Mmap memory ...
	MOV RAX,9 	;mmap
	MOV RDI,0 	;Don't care about address
	MOV RSI,(1<<30) ;1GB
	MOV RDX,3	;Read(1)/Write(2)
	MOV R10,0x22	;ANONYMOUS(20)/Private(2)
	MOV R8,-1	;no fd for anonymous memory
	MOV R9,0	;offset = 0
	SYSCALL		;Addr now in RAX

	MOV R10,5	;4 rounds
_bloop:
	MOV RDI,RAX
	MOV RCX,(1<<30)
_loop:
	STOSB
	LOOP _loop
	SUB R10,1
	JNZ _bloop

	MOV RAX,0x3C	;exit
	MOV RDI,0
	SYSCALL
