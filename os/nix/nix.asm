;nix: Nicks operating system.
;
;Last updated: 25-Oct-86.
;
	ORG	5200H
;
OPEN
	CALL	SAVE_REG
	LD	IX,FDTABLE
	LD	B,FDNUM
OPEN_1
	LD	A,(IX+0)
	BIT	7,A
	JR	Z,OPEN_2	;inactive.
	LD	DE,32
	ADD	IX,DE
	DJNZ	OPEN_1
OPEN_ERR
	CALL	GET_REG
	LD	A,-1
	RET
;
OPEN_2
	LD	HL,0		;=root inode number
	LD	(CURR_INODE),HL
	LD	HL,(REG_HL)
	LD	(PATH_PTR),HL
	LD	A,(HL)
	OR	A
	JR	Z,OPEN_ERR
	CP	'/'
	JR	NZ,OPEN_3
	INC	HL
	LD	(PATH_PTR),HL
	LD	HL,(CDIR_INODE)	;current directory
	LD	(CURR_INODE),HL
;
OPEN_3
	CALL	ACC_CURR_INODE
	LD	HL,(PATH_PTR)
OPEN_4	LD	A,(HL)
	INC	HL
	CP	'/'
	JR	Z,OPEN_4
	DEC	HL
OPEN_5	OR	A		;end of filename
	JP	Z,OPEN_10
;otherwise it is a directory search.
;ensure current inode is a directory type
	LD	A,(CIN_FLAG2)
	AND	0E0H	;test 7,6,5
	CP	0A0H	;assigned, directory
	JP	NZ,OPEN_ERR
;check search permissions
	CALL	CHK_PERMS
	AND	5
	JP	Z,OPEN_ERR	;no search permission.
;
;read contents and compare against desired entry.
	LD	HL,(CIN_BLK)
	CALL	ACC_BLOCK
	JP	NZ,OPEN_ERR
	LD	DE,DIR_BLKLIST
	LD	BC,256
	LDIR
	LD	HL,0
	LD	(DEN),HL	;directory entry number
;
OPEN_6
;If DEN*16 >= Directory EOF then can't open.
	LD	HL,(DEN)
	SLA	L
	RL	H
	SLA	L
	RR	H
	SLA	L
	RR	H
	SLA	L
	RR	H
	LD	DE,(CIN_EOF)	;low order
	OR	A
	SBC	HL,DE
	JP	NC,OPEN_ERR
;read in slot data.
	LD	HL,(DEN)
	LD	A,L
	AND	15
	JR	NZ,OPEN_7
;New directory sector must be read in.
;Divide hl by 8
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
	LD	A,0FEH
	AND	L
	LD	L,A
;Now offset into DIR_BLKLIST...
	LD	DE,DIR_BLKLIST
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
;And read in the data block
	CALL	ACC_BLOCK
	LD	(DIR_BLKDATA),HL
;
OPEN_7
	LD	HL,(DEN)
	LD	A,L
;multiply by 16 to get offset within directory sector
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,(DIR_BLKDATA)
	ADD	HL,DE
	LD	(SLOT),HL
;
	LD	DE,PATH_PTR
	CALL	PATH_CMP
	JR	NZ,OPEN_8
;Equalled. Thats now our current inode. set & loop back
	LD	HL,(SLOT)
	LD	DE,14
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E		;check if unassigned slot
	JR	Z,OPEN_8	;lucked out!
	LD	(CURR_INODE),DE
	JP	OPEN_3
;
OPEN_8
;try the next directory slot
	LD	HL,(DEN)
	INC	HL
	LD	(DEN),HL
	JP	OPEN_6
;
;Open worked!
OPEN_10
	RET
;
