;f80pch/asm: Patch to F80/cmd to let Nedas write
;Fortran-80 source code (ie. /for).
; Version 1.0 Date: 05-Aug-84.
; (C) Zeta Microcomputer Software.
	ORG	7BF4H
	JP	XXX
	ORG	0B260H	;I hope!
XXX	JR	NZ,XXY
	OR	A
	RET	NZ
	LD	A,1CH
XXY	CP	1CH
	JP	7BF7H
	END	5200H
