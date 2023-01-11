;
;Shuffle: Display a 64 byte window on the screen.
SHUFFLE:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,3C41H	;line 1 + 1
	LD	DE,3C40H
	LD	BC,63
	LDIR
	LD	(3C7FH),A
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
