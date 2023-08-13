;
;fix_prog_end: Update the end of the program according to the _brksize
FIX_PROG_END
	LD	HL,(_BRKSIZE)
	LD	(PROG_END),HL
	RET
