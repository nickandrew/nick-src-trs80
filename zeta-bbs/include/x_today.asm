;
;X_today: put today's date as in dd-mmm-yy in buffer.
X_TODAY
	PUSH	HL
	CALL	4470H
	POP	HL
	PUSH	HL
	CALL	X_DATE
	POP	HL
	RET
