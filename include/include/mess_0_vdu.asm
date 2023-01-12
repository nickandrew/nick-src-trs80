; MESS_0_VDU: Write a null-terminated string to the Video Display
;  Input: HL = start of string
;  Debug by setting a breakpoint at $$PUT_VDU
$$PUT_VDU	JP	33H

MESS_0_VDU
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$$PUT_VDU
	INC	HL
	JR	MESS_0_VDU
