; Debug/asm: Debugging module.
; Date: 17-Jul-84.
; Included only if 'DEBUG'=true so no 'if's needed.
;
DEBUG_ERROR	CALL	MESSAGE_DO
	IF	NEWDOS_80
	JP	DOS
	ELSE
	JR	$	;loop infinite.
	ENDIF
;
OVER_RETN	LD	HL,STACK_UFLOW
	JR	DEBUG_ERROR
STACK_UFLOW	DEFM	'Stack Underflow!',0DH
;
