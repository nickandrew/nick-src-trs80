;pfilt: filter out rubbish from printer
;such as cursor on/off ...
	COM	'<Printer Filter V1 19-Mar-85>'
	ORG	5200H
START	LD	HL,(4049H)
	LD	DE,EN_CODE-ST_CODE
	PUSH	DE
	OR	A
	SBC	HL,DE
	LD	(4049H),HL
	INC	HL
	LD	(4026H),HL
	EX	DE,HL
	LD	HL,ST_CODE
	POP	BC
	LDIR
	LD	HL,M_DVR
	CALL	4467H
	JP	402DH
;
M_DVR	DEFM	'Clean Printer Driver V1 19-Mar-85.',0DH
;
ST_CODE
	LD	A,C
	CP	20H
	JR	NC,STD
	CP	0DH
	JR	Z,STD
	CP	08H
	RET	NZ
	LD	C,07FH
STD	JP	058DH
;
EN_CODE	NOP
;
	END	START
