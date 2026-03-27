;
;
;if_num: Check if contents of A is numeric
IF_NUM::
	CP	'0'
	RET	C
	CP	'9'
	RET	NC
	CP	A
	RET
