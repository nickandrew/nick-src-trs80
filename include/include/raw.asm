;raw: Routines for raw() and cooked()
;Last updated: 13-Oct-87
;
_RAW
	LD	A,OM_RAW
	LD	(OUTPUT_MODE),A
	RET
;
_COOKED
	LD	A,OM_COOKED
	LD	(OUTPUT_MODE),A
	RET
;
