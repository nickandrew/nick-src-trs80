;ZA: Make Zork.
;(C) 1985, Nick.
;This is the Zork1 currently running on Zeta....
;14-Feb-86.
	COM	'<Zork1 (Old version) for Zeta>'
	COM	'<14-Feb-86. Uses old data file format>'
;
ZETA	EQU	-1
NONZETA	EQU	.NOT.ZETA
;
	IF	ZETA
*GET	EXTERNAL
*GET	ASCII
*GET	DOSCALLS
	ENDIF
;
ORIGIN	EQU	5400H
	ORG	ORIGIN
	DEFS	80H	;Normal Stack
STACK
;
	DEFS	180H	;Internal Pseudo-stack.
;
;Following must be in that order because control flows
;across Zorkboot into ZorkA.
*GET	ZORKBOOT	;Boot Sector data
*GET	ZORKA/SRC	;File # 1
*GET	ZORKB/SRC	;File # 2
*GET	ZORKC/SRC	;File # 3
;
	END	H4200
