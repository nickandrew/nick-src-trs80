;Diskio/asm: Disk Input Output file.
; Date: 06-Aug-84.
;
; Currently set up for Newdos/80 V2 only.
;
	IF	NEWDOS_80
; Get dos call addresses and Dos error message numbers.
*GET DOSCALLS
	ENDIF
;
; Firstly, System calls for use by system routines.
;
; open_file: Open a file with filespec pointed to by HL.
;Returns NZ and error code if error.
; If flag NZ set, the file will be created if necessary.
;
OPEN_FILE	CALL	SYS_BUSY
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF
;
	LD	BC,0120H
	CALL	ALLOC	;Allocate FCB and FCB_BUFFER.
	JR	NZ,ERR_OP_FILE	;if out of memory.
;
	LD	(SYS_FCB),HL
	LD	BC,20H
	ADD	HL,BC
	LD	(SYS_FCB_BUFF),HL
;
	POP	AF
	POP	HL
	PUSH	HL
	PUSH	AF
;
	LD	DE,(SYS_FCB)
	CALL	DOS_EXTRACT
	JR	Z,V2_OP_FILE
;
	LD	A,7	;'Cant extract filespec'
	JR	ERR_OP_FILE
;
V2_OP_FILE	LD	HL,(SYS_FCB_BUFF)
	LD	B,0
	POP	AF
	PUSH	AF	;Test Z status.
	JR	NZ,V3_OP_FILE	;New/Existing.
	CALL	DOS_OPEN_EX
	JR	V4_OP_FILE
V3_OP_FILE	CALL	DOS_OPEN_NEW
;
V4_OP_FILE	JR	Z,V5_OP_FILE	;Ret status.
;
	OR	80H	;A is a Dos error code.
	JR	ERR_OP_FILE
;
V5_OP_FILE	POP	AF
	POP	HL
	POP	DE
	POP	BC
	CP	A	;Set Z - no error.
	CALL	SYS_UNBUSY
	RET
;
ERR_OP_FILE	POP	HL	;Discard old AF.
	POP	HL		;Get registers.
	POP	DE
	POP	BC
	CALL	SYS_UNBUSY
	RET			;With error.
;
;
; 'close_file': Close a file. A buffer of length 0120H
;is unalloc'ed even if the dos_close call fails.
; It is assumed that this routine will be used only
;by system routines (not user processes).
CLOSE_FILE	CALL	SYS_BUSY
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	DE,(SYS_FCB)
	CALL	DOS_CLOSE
	JR	Z,V1_CL_FILE
	OR	80H
V1_CL_FILE	PUSH	AF
	LD	BC,0120H
	CALL	UNALLOC
	JR	Z,V2_CL_FILE
	CALL	ERROR
V2_CL_FILE	POP	AF
	POP	BC
	POP	DE
	POP	HL
	CALL	SYS_UNBUSY
	RET
;
