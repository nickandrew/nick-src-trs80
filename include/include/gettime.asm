;gettime: getday(), getmon(), getyear(), ...
;Last updated: 10-Jul-87
;
_GETYEAR
	LD	A,(4044H)
	LD	L,A
	LD	H,0
	RET
;
_GETMONTH
	LD	A,(4046H)
	LD	L,A
	LD	H,0
	RET
;
_GETDAY
	LD	A,(4045H)
	LD	L,A
	LD	H,0
	RET
;
_GETHOUR
	LD	A,(4043H)
	LD	L,A
	LD	H,0
	RET
;
_GETMINUT
	LD	A,(4042H)
	LD	L,A
	LD	H,0
	RET
;
_GETSECON
	LD	A,(4041H)
	LD	L,A
	LD	H,0
	RET
;
