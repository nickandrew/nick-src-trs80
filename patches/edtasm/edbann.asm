;EDbann: PATCHES EDTASM FOR A NICE
; BRIGHT BANNER.
; Assembled OK 30-Mar-85.
	ORG	561DH
	CALL	BANNER
	ORG	5D2DH
	RET
	ORG	5615H
S1	EQU	7080H
S2	EQU	70C0H
S3	EQU	70C1H
	DEFW	S1
	ORG	565EH
	DEFW	S1
	ORG	5FBDH
	DEFW	S1
	ORG	5648H
	DEFW	S2
	ORG	5964H
	DEFW	S2
	ORG	5F4EH
	DEFW	S2
	ORG	5F9AH
	DEFW	S2
	ORG	6037H
	DEFW	S2
	ORG	6DE4H
	DEFW	S2
	ORG	58D6H
	DEFW	S3
	ORG	6F60H
BANNER	LD	HL,6F80H
	LD	B,192
BANV01	LD	A,(HL)
	INC	HL
	PUSH	HL
	PUSH	BC
	CALL	0033H
	POP	BC
	POP	HL
	DJNZ	BANV01
	RET
	END	5614H
