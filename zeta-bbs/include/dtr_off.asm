;
; dtr_off: Turn off DTR usually to drop carrier on modem
DTR_OFF
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	RES	DTR_BIT,A
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
