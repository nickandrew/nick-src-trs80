;
;twirl: Reselect & spin the last selected drive.
TWIRL
	LD	A,(4308H)
	CALL	445BH
	RET
