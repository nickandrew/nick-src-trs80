;
GETDATE
	PUSH	DE
	LD	A,(4045H)
	LD	(DE),A
	INC	DE
	LD	A,(4046H)
	LD	(DE),A
	INC	DE
	LD	A,(4044H)
	LD	(DE),A
	POP	DE
	RET
;
DMY_BUF
DMY_D	DEFB	0
DMY_M	DEFB	0
DMY_Y	DEFB	0