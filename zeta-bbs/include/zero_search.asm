;
;ZERO_SEARCH: Search the USERFILE for an empty slot?
; Sets the US_ZERO flag, and does not set US_HASH.
ZERO_SEARCH
	LD	A,1
	LD	(US_ZERO),A
	JP	COMMON_SEARCH
;
