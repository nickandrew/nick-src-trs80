; Priority/asm: Process selector implementing priority.
; Date: 19-Jul-84.
; This one is just a cheapie selection system:
; All processes are equal priority and executed in
;order by number.
;
	LD	A,(CURR_PROCESS)
V0_PRIOR	INC	A
	CP	MAX_PROCESS
	JR	C,PRIO_SEL
	XOR	A	;process #0.
PRIO_SEL	LD	E,A
	LD	D,0
	LD	HL,PID_ASSIGNED
	ADD	HL,DE
	LD	A,(HL)
	CP	FALSE	;bypass unassigned processes.
	LD	A,E
	JR	Z,V0_PRIOR
