;bb6.asm: Resend message command.
;
RESEND_CMD
	LD	HL,M_RESENDTO
	CALL	GET_STRING
	JP	MAIN
;
	;move the string into a username buffer
	;process the username ala enter command
;
	;ask which message # to resend
	;check/locate that message
	;construct a new header & write it
	;copy the text - buffer if possible
	;write new topic file record
	;update & write message counts
	;jump back to main
;
