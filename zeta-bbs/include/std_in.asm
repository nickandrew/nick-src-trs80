;
;std_in: Input byte from $STDIN
STD_IN
	LD	DE,DCB_2O
	CALL	$PUT
	RET
