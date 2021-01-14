;menu: the end of real programming on Zeta
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Menu 1.4d 23-Apr-89>'
	ORG	BASE+100H
START	LD	SP,START
	LD	A,(HL)
	CP	'-'
	JR	NZ,MENU
	LD	A,1
	LD	(DFLAG),A
MENU
	LD	HL,M_MENU
	LD	DE,DCB_2O
	CALL	MESS_0
;
ME_0
	LD	HL,M_PROMPT
	CALL	PUTS
;
	LD	HL,C_BUFF
	LD	B,1
	CALL	40H
	JR	C,ME_0
;
	LD	A,(C_BUFF)
	CP	'7'		;Shell/exit
	JR	NZ,ME_1B
	LD	A,(DFLAG)
	OR	A
	JR	NZ,ME_1
	PUSH	HL
	LD	HL,M_SMENU
	LD	DE,DCB_2O
	CALL	MESS_0
	POP	HL
	XOR	A
	JP	TERMINATE
ME_1
	PUSH	HL
	LD	HL,M_SEXIT
	LD	DE,DCB_2O
	CALL	MESS_0
	POP	HL
ME_1B
	LD	A,(HL)
	CP	'?'
	JR	Z,MENU
;
	CP	CR
	JR	Z,ME_0
	CP	'a'
	JR	C,ME_1A
	AND	5FH
ME_1A	LD	B,A
	LD	HL,MENU_TAB
ME_2	LD	A,(HL)
	OR	A
	JR	Z,MENU
	CP	B
	JR	Z,ME_3
	INC	HL
	INC	HL
	INC	HL
	JR	ME_2
;
ME_3	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	PUSH	HL
	LD	HL,M_EXEC
	LD	DE,DCB_2O
	CALL	MESS_0
	POP	HL
	PUSH	HL
	CALL	MESS_0
	LD	HL,M_EXEC2
	CALL	MESS_0
	POP	HL
	CALL	CALL_PROG
;
	JP	START
;
*GET	ROUTINES
;
DFLAG	DEFB	0
C_BUFF	DC	3,0
;
M_SEXIT	DEFM	CR,CR,'Use "exit" to return to this menu.',CR,CR,0
M_SMENU	DEFM	CR,CR,'Use "menu" to return to this menu.',CR,CR,0
;
M_MENU	DEFM	CR
	DEFM	'Zeta menu options - enter a single digit',CR
	DEFM	CR
	DEFM	' 1   News and Echomail system',CR
	DEFM	'  2   Private Mail system',CR
	DEFM	'   3   Download software and file catalogues',CR
	DEFM	'    4   Try to chat to the Sysop',CR
	DEFM	'     5   Leave a message to the Sysop',CR
	DEFM	'      6   Get help',CR
	DEFM	'       7   Use the command line Shell',CR
	DEFM	'        8   Answer a survey',CR
	DEFM	'         9   Logout',CR
	DEFB	0
;
M_PROMPT
	DEFM	CR,CR
	DEFM	'Menu # ',0
;
M_EXEC	DEFM	CR,'Now executing: "',0
M_EXEC2	DEFM	'"',CR,CR,0
;
MENU_TAB
	DEFB	'1'
	DEFW	CMD_1
	DEFB	'2'
	DEFW	CMD_2
	DEFB	'3'
	DEFW	CMD_3
	DEFB	'4'
	DEFW	CMD_4
	DEFB	'5'
	DEFW	CMD_5
	DEFB	'6'
	DEFW	CMD_6
	DEFB	'7'
	DEFW	CMD_7
	DEFB	'8'
	DEFW	CMD_8
	DEFB	'9'
	DEFW	CMD_9
	DEFB	0,0,0
;
CMD_1	DEFB	'bb',0
CMD_2	DEFB	'mail',0
CMD_3	DEFB	'xfer',0
CMD_4	DEFB	'chat',0
CMD_5	DEFB	'mail Sysop',0
CMD_6	DEFB	'help',0
CMD_7	DEFB	'shell',0
CMD_8	DEFB	'survey',0
CMD_9	DEFB	'logout',0
;
THIS_PROG_END	EQU	$
;
	END	START
