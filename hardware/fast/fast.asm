;fast/asm: switch the clock speed around.
;'fast' - high speed.
;'fast N' - low speed.
;
;Version 1.0, 07-Oct-84.

*GET	DOSCALLS

	ORG	5200H
FAST	LD	A,(HL)
	CP	'N'
	JR	Z,SLOW
	LD	A,1
	OUT	(254),A
	LD	HL,MFAST
	CALL	MESS_DO
	JP	DOS_NOERROR
SLOW	XOR	A
	OUT	(254),A
	LD	HL,MSLOW
	CALL	MESS_DO
	JP	DOS_NOERROR
;
MFAST	DEFM	'Now running at HIGH speed.',0DH
MSLOW	DEFM	'Now running at LOW  speed.',0DH
;
	END	FAST
;
