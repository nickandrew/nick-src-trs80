;listbas: List a tokenised BASIC file.
;listbas ver 0.0 - non BBS version.
;
*GET	DOSCALLS
	ORG	5400H
START
	LD	SP,START
	LD	(ARGS),HL
	CALL	USAGE
	LD	HL,(ARGS)
	LD	DE,FCB_I
	CALL	DOS_EXTRACT
	JP	NZ,USG_ERR
;
	LD	HL,BUFF_I
	LD	DE,FCB_I
	CALL	DOS_OPEN_EX
	JP	NZ,FILE_ERR
;
	LD	DE,FCB_I
	CALL	ROM@GET
	CP	0FFH
	JR	Z,HEADER
;Should jump to LIST filename instead.
	LD	HL,M_NOTBAS
	CALL	4467H
	JP	DOS_NOERROR
;
HEADER	LD	DE,FCB_I
	CALL	ROM@GET		;addr 1
	LD	L,A
	CALL	ROM@GET		;addr 2
	LD	H,A
	LD	A,H
	OR	L
	JP	Z,EXIT
	CALL	ROM@GET		;line 1
	LD	L,A
	CALL	ROM@GET		;line 2
	LD	H,A
;
;;	call	print_numb
;
LOOP	LD	DE,FCB_I
	CALL	ROM@GET
	JR	NZ,EOF
	CP	80H
	JR	NC,XLATE
;
	OR	A
	JR	Z,END_LINE
;
;;	CP	20H
;;	JR	C,LOOP
	CALL	PUT
;
	JR	LOOP
;
END_LINE
	LD	A,0DH
	CALL	PUT
	LD	A,' '
	CALL	PUT
	LD	A,' '
	CALL	PUT
	JR	HEADER
;
EOF	CP	1CH
	JR	Z,EXIT
	CP	1DH
	JP	NZ,FILE_ERR
EXIT	LD	A,0DH
	CALL	PUT
	JP	DOS_NOERROR
;
XLATE
	CP	0F0H
	JR	Z,F0_HEX
	SUB	80H
	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,CPM_TABLE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	A,H
	OR	L
	JR	Z,LOOP	;if no token applies.
;
;
PUT_TOK
	LD	A,(HL)
	OR	A
	JR	Z,LOOP
	CALL	PUT
	INC	HL
	JR	PUT_TOK
;
F0_HEX	LD	DE,FCB_I
	CALL	ROM@GET
	JR	LOOP
;
FILE_ERR
	CP	13H	;bad file name
	JR	Z,USG_ERR
	CP	20H	;illegal/missing drive #
	JR	Z,USG_ERR
	CP	30H	;bad filespec
	JR	Z,USG_ERR
	PUSH	AF
	LD	HL,M_LIST
	CALL	4467H
	POP	AF
	JP	DOS_ERROR
;
USAGE
	LD	A,(HL)
	CP	0DH
	RET	NZ
USG_ERR
	LD	HL,M_USAGE
	CALL	4467H
	JP	DOS_NOERROR
;
M_USAGE
	DEFM	'Usage: LISTBAS filename/bas',0DH
M_LIST	DEFM	'listbas: ',03H
M_NOTBAS
	DEFM	'listbas: Not a tokenised BASIC file.',0DH
;
PUT	CALL	ROM@PUT_VDU
	CALL	002BH
	OR	A
	RET	Z
	CP	01H
	JP	Z,EXIT
	CP	'w'
	RET	NZ
CTLS	CALL	002BH
	CP	'c'
	JR	NZ,CTLS
	RET
;
ARGS	DEFW	0
;
FCB_I	DEFS	32
BUFF_I	DEFS	256
;
TRS80_TABLE
	DEFW	TOK_1
	DEFW	TOK_2
	DEFW	TOK_3
	DEFW	TOK_4
	DEFW	TOK_5
	DEFW	TOK_6
	DEFW	TOK_7
	DEFW	TOK_8
	DEFW	TOK_9
	DEFW	TOK_10
	DEFW	TOK_11
	DEFW	TOK_12
	DEFW	TOK_13
	DEFW	TOK_14
	DEFW	TOK_15
	DEFW	TOK_16
	DEFW	TOK_17
	DEFW	TOK_51
	DEFW	TOK_19
	DEFW	TOK_20
	DEFW	TOK_21
	DEFW	TOK_22
	DEFW	TOK_23
	DEFW	TOK_24
	DEFW	TOK_25
	DEFW	TOK_26
	DEFW	TOK_27
	DEFW	TOK_28
	DEFW	TOK_29
	DEFW	TOK_30
	DEFW	TOK_31
	DEFW	TOK_32
	DEFW	TOK_33
	DEFW	TOK_34
	DEFW	TOK_35
	DEFW	TOK_36
	DEFW	TOK_37
	DEFW	TOK_38
	DEFW	TOK_39
	DEFW	TOK_40
	DEFW	TOK_41
	DEFW	TOK_42
	DEFW	TOK_43
	DEFW	TOK_44
	DEFW	TOK_45
	DEFW	TOK_46
	DEFW	TOK_47
	DEFW	TOK_48
	DEFW	TOK_49
	DEFW	TOK_50
	DEFW	TOK_51
	DEFW	TOK_52
	DEFW	TOK_53
	DEFW	TOK_54
	DEFW	TOK_55
	DEFW	TOK_56
	DEFW	TOK_57
	DEFW	TOK_58
	DEFW	TOK_59
	DEFW	TOK_60
	DEFW	TOK_61
	DEFW	TOK_62
	DEFW	TOK_63
	DEFW	TOK_64
	DEFW	TOK_65
	DEFW	TOK_66
	DEFW	TOK_67
	DEFW	TOK_68
	DEFW	TOK_69
	DEFW	TOK_70
	DEFW	TOK_71
	DEFW	TOK_72
	DEFW	TOK_73
	DEFW	TOK_74
	DEFW	TOK_75
	DEFW	TOK_76
	DEFW	TOK_77
	DEFW	TOK_78
	DEFW	TOK_79
	DEFW	TOK_80
	DEFW	TOK_81
	DEFW	TOK_82
	DEFW	TOK_83
	DEFW	TOK_84
	DEFW	TOK_85
	DEFW	TOK_86
	DEFW	TOK_87
	DEFW	TOK_88
	DEFW	TOK_89
	DEFW	TOK_90
	DEFW	TOK_91
	DEFW	TOK_92
	DEFW	TOK_93
	DEFW	TOK_94
	DEFW	TOK_95
	DEFW	TOK_96
	DEFW	TOK_97
	DEFW	TOK_98
	DEFW	TOK_99
	DEFW	TOK_100
	DEFW	TOK_101
	DEFW	TOK_102
	DEFW	TOK_103
	DEFW	TOK_104
	DEFW	TOK_105
	DEFW	TOK_106
	DEFW	TOK_107
	DEFW	TOK_108
	DEFW	TOK_109
	DEFW	TOK_110
	DEFW	TOK_111
	DEFW	TOK_112
	DEFW	TOK_113
	DEFW	TOK_114
	DEFW	TOK_115
	DEFW	TOK_116
	DEFW	TOK_117
	DEFW	TOK_118
	DEFW	TOK_119
	DEFW	TOK_120
	DEFW	TOK_121
	DEFW	TOK_122
	DEFW	TOK_123
	DEFW	TOK_124
	DEFW	0
	DEFW	0
	DEFW	0
	DEFW	0
;
CPM_TABLE
	DEFW	TOK_1		;1
	DEFW	TOK_2
	DEFW	TOK_3
	DEFW	TOK_4
	DEFW	TOK_5
	DEFW	TOK_6
	DEFW	TOK_7
	DEFW	TOK_8
	DEFW	TOK_9
	DEFW	TOK_10		;10
	DEFW	TOK_11
	DEFW	TOK_12
	DEFW	TOK_13
	DEFW	TOK_14
	DEFW	TOK_15
	DEFW	TOK_20		;16
	DEFW	TOK_17
	DEFW	TOK_51
	DEFW	TOK_19
	DEFW	TOK_20		;20
	DEFW	TOK_21
	DEFW	TOK_22
	DEFW	TOK_23
	DEFW	TOK_24
	DEFW	TOK_25
	DEFW	TOK_26
	DEFW	TOK_27
	DEFW	TOK_28
	DEFW	TOK_29
	DEFW	TOK_30		;30
	DEFW	TOK_31
	DEFW	TOK_32
	DEFW	TOK_33
	DEFW	TOK_34
	DEFW	TOK_35
	DEFW	TOK_36
	DEFW	TOK_37
	DEFW	TOK_38
	DEFW	TOK_39
	DEFW	TOK_40		;40
	DEFW	TOK_41
	DEFW	TOK_42
	DEFW	TOK_43
	DEFW	TOK_44
	DEFW	TOK_45
	DEFW	TOK_46
	DEFW	TOK_47
	DEFW	TOK_48
	DEFW	TOK_49
	DEFW	TOK_50		;50
	DEFW	TOK_51
	DEFW	TOK_52
	DEFW	TOK_53
	DEFW	TOK_54
	DEFW	TOK_55
	DEFW	TOK_56
	DEFW	TOK_57
	DEFW	TOK_58
	DEFW	TOK_59
	DEFW	TOK_60		;60
	DEFW	TOK_61
	DEFW	TOK_62
	DEFW	TOK_63
	DEFW	TOK_64
	DEFW	TOK_65
	DEFW	TOK_66
	DEFW	TOK_67
	DEFW	TOK_68
	DEFW	TOK_69
	DEFW	TOK_70		;70
	DEFW	TOK_71
	DEFW	TOK_72
	DEFW	TOK_73
	DEFW	TOK_74
	DEFW	TOK_75
	DEFW	TOK_76
	DEFW	TOK_77
	DEFW	TOK_78
	DEFW	TOK_79
	DEFW	TOK_80		;80
	DEFW	TOK_81
	DEFW	TOK_82
	DEFW	TOK_83
	DEFW	TOK_84
	DEFW	TOK_85
	DEFW	TOK_86
	DEFW	TOK_87
	DEFW	TOK_88
	DEFW	TOK_89
	DEFW	TOK_90		;90
	DEFW	TOK_91
	DEFW	TOK_92
	DEFW	TOK_93
	DEFW	TOK_94
	DEFW	TOK_95
	DEFW	TOK_96
	DEFW	TOK_97
	DEFW	TOK_98
	DEFW	TOK_99
	DEFW	TOK_100		;100
	DEFW	TOK_101
	DEFW	TOK_102
	DEFW	TOK_103
	DEFW	TOK_104
	DEFW	TOK_105
	DEFW	TOK_106
	DEFW	TOK_107
	DEFW	TOK_108
	DEFW	TOK_109
	DEFW	TOK_110		;110
	DEFW	TOK_111
	DEFW	TOK_112
	DEFW	TOK_113
	DEFW	TOK_114
	DEFW	TOK_115
	DEFW	TOK_116
	DEFW	TOK_117
	DEFW	TOK_118
	DEFW	TOK_119
	DEFW	TOK_120		;120
	DEFW	TOK_121
	DEFW	TOK_122
	DEFW	TOK_123
	DEFW	TOK_124
	DEFW	0
	DEFW	0
	DEFW	0
	DEFW	0
;
TOK_1	DEFM	'END',0
TOK_2	DEFM	'FOR',0
TOK_3	DEFM	'RESET',0
TOK_4	DEFM	'SET',0
TOK_5	DEFM	'CLS',0
TOK_6	DEFM	'CMD',0
TOK_7	DEFM	'RANDOM',0
TOK_8	DEFM	'NEXT',0
TOK_9	DEFM	'DATA',0
TOK_10	DEFM	'INPUT',0
TOK_11	DEFM	'DIM',0
TOK_12	DEFM	'READ',0
TOK_13	DEFM	'LET',0
TOK_14	DEFM	'GOTO',0
TOK_15	DEFM	'RUN',0
TOK_16	DEFM	'IF',0
TOK_17	DEFM	'RESTORE',0
TOK_18	DEFM	'GOSUB',0
TOK_19	DEFM	'RETURN',0
TOK_20	DEFM	'REM',0
TOK_21	DEFM	'STOP',0
TOK_22	DEFM	'ELSE',0
TOK_23	DEFM	'TRON',0
TOK_24	DEFM	'TROFF',0
TOK_25	DEFM	'DEFSTR',0
TOK_26	DEFM	'DEFINT',0
TOK_27	DEFM	'DEFSNG',0
TOK_28	DEFM	'DEFDBL',0
TOK_29	DEFM	'LINE',0
TOK_30	DEFM	'EDIT',0
TOK_31	DEFM	'ERROR',0
TOK_32	DEFM	'RESUME',0
TOK_33	DEFM	'OUT',0
TOK_34	DEFM	'ON',0
TOK_35	DEFM	'OPEN',0
TOK_36	DEFM	'FIELD',0
TOK_37	DEFM	'GET',0
TOK_38	DEFM	'PUT',0
TOK_39	DEFM	'CLOSE',0
TOK_40	DEFM	'LOAD',0
TOK_41	DEFM	'MERGE',0
TOK_42	DEFM	'NAME',0
TOK_43	DEFM	'KILL',0
TOK_44	DEFM	'LSET',0
TOK_45	DEFM	'RSET',0
TOK_46	DEFM	'SAVE',0
TOK_47	DEFM	'SYSTEM',0
TOK_48	DEFM	'LPRINT',0
TOK_49	DEFM	'DEF',0
TOK_50	DEFM	'POKE',0
TOK_51	DEFM	'PRINT',0
TOK_52	DEFM	'CONT',0
TOK_53	DEFM	'LIST',0
TOK_54	DEFM	'LLIST',0
TOK_55	DEFM	'DELETE',0
TOK_56	DEFM	'AUTO',0
TOK_57	DEFM	'CLEAR',0
TOK_58	DEFM	'CLOAD',0
TOK_59	DEFM	'CSAVE',0
TOK_60	DEFM	'NEW',0
TOK_61	DEFM	'TAB(',0
TOK_62	DEFM	'TO',0
TOK_63	DEFM	'FN',0
TOK_64	DEFM	'USING',0
TOK_65	DEFM	'VARPTR',0
TOK_66	DEFM	'USR',0
TOK_67	DEFM	'ERL',0
TOK_68	DEFM	'ERR',0
TOK_69	DEFM	'STRING$',0
TOK_70	DEFM	'INSTR',0
TOK_71	DEFM	'POINT',0
TOK_72	DEFM	'TIME$',0
TOK_73	DEFM	'MEM',0
TOK_74	DEFM	'INKEY$',0
TOK_75	DEFM	'THEN',0
TOK_76	DEFM	'NOT',0
TOK_77	DEFM	'STEP',0
TOK_78	DEFM	'+',0
TOK_79	DEFM	'-',0
TOK_80	DEFM	'*',0
TOK_81	DEFM	'/',0
TOK_82	DEFM	'[',0
TOK_83	DEFM	'AND',0
TOK_84	DEFM	'OR',0
TOK_85	DEFM	'>',0
TOK_86	DEFM	'=',0
TOK_87	DEFM	'<',0
TOK_88	DEFM	'SGN',0
TOK_89	DEFM	'INT',0
TOK_90	DEFM	'ABS',0
TOK_91	DEFM	'FRE',0
TOK_92	DEFM	'INP',0
TOK_93	DEFM	'POS',0
TOK_94	DEFM	'SQR',0
TOK_95	DEFM	'RND',0
TOK_96	DEFM	'LOG',0
TOK_97	DEFM	'EXP',0
TOK_98	DEFM	'COS',0
TOK_99	DEFM	'SIN',0
TOK_100	DEFM	'TAN',0
TOK_101	DEFM	'ATN',0
TOK_102	DEFM	'PEEK',0
TOK_103	DEFM	'CVI',0
TOK_104	DEFM	'CVS',0
TOK_105	DEFM	'CVD',0
TOK_106	DEFM	'EOF',0
TOK_107	DEFM	'LOC',0
TOK_108	DEFM	'LOF',0
TOK_109	DEFM	'MKI$',0
TOK_110	DEFM	'MKS$',0
TOK_111	DEFM	'MKD$',0
TOK_112	DEFM	'CINT',0
TOK_113	DEFM	'CSNG',0
TOK_114	DEFM	'CDBL',0
TOK_115	DEFM	'FIX',0
TOK_116	DEFM	'LEN',0
TOK_117	DEFM	'STR$',0
TOK_118	DEFM	'VAL',0
TOK_119	DEFM	'ASC',0
TOK_120	DEFM	'CHR$',0
TOK_121	DEFM	'LEFT$',0
TOK_122	DEFM	'RIGHT$',0
TOK_123	DEFM	'MID$',0
TOK_124	DEFB	27H,0	;single quote.
;
	END	START
