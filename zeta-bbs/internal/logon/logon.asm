;logon: Allow a user or non-user to logon
;
;Options:
SYSOPONLY	EQU	0	;Only sysop can login
ACSNET_ID	EQU	6	;Runx & Nswitgould
NEWCOND		EQU	0	;Must answer Y to conditions to logon
CREDITS		EQU	0	;Print credit info
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Logon 3.5d 18-Feb-88>'
	ORG	BASE+100H
;
*GET	LOGON1
*GET	LOGON2
;
*GET	FORTYHEX.LIB
*GET	ROUTINES.LIB
;
;List of prohibited words or parts of words
BADN_1	DEFM	'SYSOP',0
BADN_2	DEFM	'ZETA',0
BADN_3	DEFM	'THE ',0
BADN_4	DEFM	'SHIT',0
BADN_5	DEFM	'FUCK',0
BADN_6	DEFM	'GET ',0
BADN_7	DEFM	'CRACKER',0
BADN_8	DEFM	'CRASHER',0
BADN_9	DEFM	'HACKER',0
BADN_10	DEFM	'64',0
BADN_11	DEFM	'80',0
BADN_12	DEFM	'SYSTEM',0
BADN_13	DEFM	'COMPUTER',0
;
M_PASS_SHRT
	DEFM	'Password too short. Try one 4 or more chars long.',CR
	DEFM	0
;
M_PASS_NAME
	DEFM	'Password too trivial. Try again.',CR,0
;
M_NAUGHTY
	DEFM	'*** Extremely Naughty - disconnected ***',CR,0
;
M_REGISTER
	DEFM	'Name: "',0
M_WITHPASS
	DEFM	'"',0
;
M_WHPASS
	DEFM	'What logon password do you want? (4-12 chars): ',0
;
M_AGRD	DEFM	CR,'   Thank you.',CR,CR,0
;
M_BADSTAT DEFM	CR,'Logging you on as SYSOP',CR,'Done',CR,0
;
M_WAIT	DEFM	'Wait...',CR,0
;
M_YOURE	DEFM	'You are Zeta''s ',0
M_SCALL	DEFM	' logged-in caller.',CR,0
M_YOURNO DEFM	'This is your ',0
M_YOURCL DEFM	' call to Zeta.',CR,0
;
M_OLDMATE
	DEFM	CR,CR,'Your last call was more than a month ago.',CR
	DEFM	'Please call more often lest you miss out on mail & news.',CR,CR,0
;
M_THENAME
	DEFM	'The name: "',0
M_UNKN	DEFM	'" is unknown to Zeta. Use upper and lower case.'
	DEFM	CR,0
;
M_1	DEFM	'Please Login now.',CR,7,0
M_UNSUC	DEFM	'Unsuccessful attempt: ',0
M_SUCCE	DEFM	'Logged in: ',0
M_LOG	DEFM	CR,'Logged in...',CR,0
M_FULLNAME
	DEFM	'Enter your Full Name : ',0
M_ERROR	DEFM	'** Login Error Occurred **!!!',CR,0
M_HNGUP	DEFM	'Sorry but I have to hang up',CR,0
;
M_CR	DEFM	CR,0
;
M_SHELLERR
	DEFM	CR,'Couldn''t run the shell for you, sorry.',CR
	DEFM	'I will have to disconnect.',CR,0
;
M_ACSERR
	DEFM	'Couldn''t run ACSnet connect program',CR
	DEFM	'I will have to disconnect.',CR,0
;
M_PWBAD	DEFM	'Bad Password, try again.',CR,0
M_THISPWD
	DEFM	'Tried this password: ',0
M_THISUSR
	DEFM	'This User Name: ',0
M_YESNO	DEFM	'SYSOP: let this user log in? ',CR,0
M_DENIED
	DEFM	'Login attempt denied (sorry).',CR,0
;
M_FORGOT
	DEFM	'You seem to have forgotten your password. Enter a comment now',CR
	DEFM	'to the Sysop stating your name,address,phone number,',CR
	DEFM	'what you thought your password was,',CR
	DEFM	'and what you want it to be changed to.',CR,CR,0
;
M_KICKOUT
	DEFM	'Invalid login: ',0
;
M_VISIT	DEFM	CR,CR,'Here is some useful information about Zeta for new users.',CR
	DEFM	'Hit your return key when ready',CR,0
;
M_AGREE	DEFM	'Do you agree to the above conditions? (Y/N): ',0
;
M_STUFFED
	DEFM	CR,CR,'Suit yourself.',CR,CR,CR,CR,0
;
M_FEES4	DEFM	CR,0
;
M_HITKEY
	DEFM	'Hit any key to continue',CR,CR,0
;
M_NOLOG1
	DEFM	'Sorry but you were unable to provide a suitable name.',CR
	DEFM	'Try again on another call...',CR,CR,0
M_CORRECT
	DEFM	'Is spelling correct? (Y/N): ',0
M_BADFMT
	DEFM	'" is in bad format.',CR
	DEFM	'Enter your first and last names on one line.',CR
	DEFM	'Use upper and lower case',CR,CR,0
;
M_CRED1	DEFM	'You have $',0
M_CRED2	DEFM	' credit.',CR,0
M_CRED3	DEFM	'You owe Zeta $',0
M_CRED4	DEFM	' (monthly usage charge).',CR
	DEFM	'Note: Payment is currently optional.',CR,0
;
M_PASSWD DEFM	'Your password: ',0
NAME_FAIL DEFM	' (failed)',CR,0
;
HI_FILE	DEFM	'hello.zms',CR
LOGIN_FILE
	DEFM	'login.zms',CR
F_VISIT	DEFM	'visitor.zms',CR
;
REGIST_FCB
	DEFM	'register.log',CR
	DC	32-13,0
REGIST_BUF
	DEFS	256
;
S_STR	DEFW	0	;Short instr string
L_STR	DEFW	0	;Long  instr string
;
F_THISUSR
	DEFB	0
;
PASS_TRY DEFB	0
COUNT	DEFB	0
IN_BUFF		DC	64,0
NAME_BUFF	DC	32,0
PASS_BUFF	DC	14,0
;
DATE
DATE_BUF DEFM	'dd-mmm-yy '
TIME_BUF DEFM	'hh:mm:ss ',0
;
PRESHELL	DEFM	'Preshell',CR,0
ACSNET		DEFM	'Acsnet',CR,0
SHELL		DEFM	'Shell',0
COMMENT		DEFM	'Comment',0
;
YN_BUFF	DEFS	5
;
THIS_PROG_END	EQU	$
;
	END	START
