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
	MOV R12,RAX
	MOV R11,RAX
	ADD R11,(1<<30) ;End of buffer (last qword one can write)
_loop:
	MOV byte [RAX],0x42
	ADD RAX,(1<<12)+16 ;Next page prevents prefetch?
	CMP RAX,R11
	JB _loop
	SUB RAX,(1<<30) ;Return to start of buffer
	CMP RAX,R12
	JNE _loop

	MOV RAX,0x3C	;exit
	MOV RDI,0
	SYSCALL
