;
;get_number: Convert a string ptd to by HL to a number HL
GET_NUMBER
	LD	DE,0
$GN_01	LD	A,(HL)
	CALL	IF_NUM
	JR	NZ,$GN_02
	CALL	$GN_03
	INC	HL
	JR	$GN_01
;
$GN_02	PUSH	DE
	POP	HL
	RET
;
$GN_03	PUSH	HL
	SUB	'0'
	PUSH	DE
	POP	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	LD	E,A
	LD	D,0
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	RET
;
