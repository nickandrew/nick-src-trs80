;userfile.hdr: Format of one USERFILE entry.
;Last updated: 31-Mar-86.
;
UF_LRL		EQU	56	;Userfile LRL
;
US_UBUFF			;User data buffer
UF_STATUS	DEFB	0	;Status byte.
UF_NAME		DEFS	24	;Users name
UF_PASSWD	DEFS	13	;Password.
UF_UID		DEFW	0	;User id.
UF_NCALLS	DEFW	0	;Number of logons
UF_LASTCALL	DEFS	3	;Date of last call
UF_PRIV1	DEFB	0	;Priv_1
UF_PRIV2	DEFB	0	;Priv_2
UF_PRIV3	DEFB	0	;Priv_3 (unused)
UF_TDATA	DEFB	0	;Terminal X,Y
UF_REGCOUNT	DEFB	0	;Register info
UF_BADLOGIN	DEFB	0	;Number of bad logons
UF_TFLAG1	DEFB	0	;Flags 1
UF_TFLAG2	DEFB	0	;Flags 2
UF_ERASE	DEFB	0	;Erase char default ^H
UF_KILL		DEFB	0	;Kill  char default ^X
UF_NOTHING	DEFB	0	;Nothing.
;End of UserFile record definitions.
;
;Definitions for UF_STATUS
UF_ST_ZERO	EQU	6	;=1 if record used.
UF_ST_NOTUSER	EQU	5	;1=A fake username or
				;rude disconnection.
;
