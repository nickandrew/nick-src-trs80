;
;std_out: Output byte to $STDOUT
STD_OUT
	LD	DE,DCB_2O
	CALL	$PUT
	RET
