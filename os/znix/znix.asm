;Znix/asm: Filesystem calls... Include file.
;          13-Oct-85.
;
;Routines (will be) provided for:
;   1) FileSystem init            FSINIT
;   2) Pathname Open              FOPEN
;   3) File close                 FCLOSE
;   4) File block read            FREAD
;   5) File block write           FWRITE
;   6) Node creation              FMAKEN
;   7) File Unlink                FUNLINK
;   8) File Positioning           FSEEK
;
;
*GET	DOSCALLS
;
;
FSINIT	LD	HL,FCB_FS
	LD	DE,BUF_FS
	LD	B,0
	LD	A,(HL)
	BIT	7,A
	JP	NZ,FSCANT
	CALL	DOS_OPEN_EX
	JP	NZ,FSCANT
;
;Read superblock.
	LD	BC,0
	LD	DE,FCB_FS
	CALL	DOS_POSIT
	JP	NZ,FSCANT
	LD	HL,S_BLOCK
	CALL	DOS_READ_SECT
	JP	NZ,FSCANT
;
;Finished (I think).
	RET
;
; End of FSINIT.
;
;Data area.
FCB_FS	DEFB	'ZNIX/SYS',0DH
	DC	32-9,0
BUF_FS	DC	256,0
;
S_BLOCK
S_DNAME		DC	16,0
S_DCREAT	DC	3,0
S_DBCKUP	DC	3,0
S_DBLOCKS	DEFW	0
S_S_SIZ		DEFB	0
S_F_LEN		DEFB	0
S_F_START	DEFW	0
S_I_LEN		DEFB	0
S_I_START	DEFW	0
S_INODES	DEFW	0
S_INOD_ST	DEFW	0
S_FILLER	DC	256-35,0
;End of S-Block definition.
;
;Inode table definition.
INODE_TABLE
INOD_FLAGS	DEFB	0
INOD_TYPE	DEFB	0
INOD_OWNER	DEFW	0
INOD_PERMS	DEFB	0
INOD_EOF	DC	3,0
INOD_ALLOC	DC	24,0
;
CURR_INOD	DEFW	0	;Inode.
SET_INODE	DEFW	0	;Tree inode.
CHAR_PTR	DEFW	0	;Character ptr.
T_FILENAME	DEFW	0	;Pathname addr
T_BUFFER	DEFW	0	;Buffer addr
T_MODE		DEFW	0	;Mode addr
;
E_CANT		EQU	1	;Can't do what you want
;
;Directory format data
DIR_INODE	DEFW	0
DIR_NAME	DC	14,0
;
;
FSCANT	;Return 'CANT' error
	LD	A,E_CANT
	OR	A
	RET
;
FOPEN		;Open a path for read/write
	LD	(T_FILENAME),HL
	LD	(T_MODE),DE
	PUSH	BC
	POP	DE
	LD	(T_BUFFER),DE
;
	LD	A,(HL)
	CP	'/'
	JP	NZ,FSCANT
;
	CALL	ACCESS_INODE	;Find I-no of (hl) string
				;Create if necessary.
	JP	NZ,FSCANT
;I-No is in HL.
	LD	(CURR_INOD),HL
;	CALL	GET_INODE
;	JP	NZ,FSCANT
;
	LD	A,(INOD_FLAGS)
	BIT	7,A
	JP	Z,FSCANT
;
	LD	A,(INOD_TYPE)
	AND	0E0H
	JR	Z,FOP_02
	CP	0E0H
	JR	Z,FOP_01
	JP	FSCANT
;
FOP_01	;Check if directory. Disallow write.
	LD	A,(INOD_TYPE)
	AND	0E0H
	CP	0E0H
	JR	NZ,FOP_02
	LD	HL,(T_MODE)
	LD	A,(HL)
	CP	'r'
	JP	NZ,FSCANT
;Fall through
FOP_02	;Set flags for open.
	LD	A,10000000B	;Open.
	LD	IX,(T_BUFFER)
	LD	(IX+0),A
;
	LD	HL,(T_MODE)
	LD	A,(HL)
	LD	B,01000000B
	CP	'w'
	JR	Z,FP_03
	LD	B,00100000B
FP_03	LD	A,(IX+0)
	OR	B
	LD	(IX+0),A	;W/R perms now.
;Set Start of file.
	LD	(IX+1),0
	LD	(IX+2),0
	LD	(IX+3),0
;Set inode number.
	LD	HL,(CURR_INOD)
	LD	(IX+4),L
	LD	(IX+5),H
;Set file eof.
	LD	HL,(INOD_EOF)
	LD	(IX+6),L
	LD	(IX+7),H
	LD	A,(INOD_EOF+2)
	LD	(IX+8),A
;Done.
	XOR	A
	RET
;
;
;
FSEEK		;Seek a file position.
		;Parameters in H,L and C.
		;DE = File pointer.
;
	LD	(T_BUFFER),DE
	LD	IX,(T_BUFFER)
	EX	DE,HL
	LD	(IX+1),C
	LD	C,(IX+2)
	LD	B,(IX+3)
	LD	A,B
	CP	D
	JR	NZ,FSE_01
	LD	A,C
	CP	E
	JR	NZ,FSE_01
;No real change.
	XOR	A
	RET
FSE_01	;Substantial change.
;Set new file position.
	LD	(IX+2),E
	LD	(IX+3),D
;Handle flags.
	LD	A,(IX+0)
	RES	4,A
	LD	(IX+0),A
	BIT	3,A
	CALL	NZ,UPDATE_RECD
	JP	NZ,FSCANT
;Done (presumably).
	RET
;
;
;
FCLOSE			;DE is file buffer
	LD	(T_BUFFER),DE
	LD	A,(DE)
	BIT	7,A
	JP	Z,FSCANT
	BIT	3,A
	CALL	NZ,UPDATE_RECD
	JP	NZ,FSCANT
;Done (again Presumably).
	RET
;
GET_INODE		;Get inode data #HL.
	PUSH	HL
	POP	BC
;Multiply by 32 (length of inode data)
	ADD	HL,HL	;2
	ADD	HL,HL	;4
	ADD	HL,HL	;8
	ADD	HL,HL	;16
	ADD	HL,HL	;32
;Add inode table starting block number
	LD	DE,(S_INOD_ST)
	LD	D,E
	LD	E,0
	ADD	HL,DE
	PUSH	HL
	POP	BC
	LD	DE,FCB_FS
	CALL	DOS_POS_RBA
	JP	NZ,FSCANT
;
	LD	HL,INODE_TABLE
	LD	B,32
GTI_01	CALL	13H
	JP	NZ,FSCANT
	LD	(HL),A
	INC	HL
	DJNZ	GTI_01
;Done. Got inode data.
	XOR	A
	RET
;
;
UPDATE_RECD		;Write a files updated record
			;to disk.
	LD	IX,(T_BUFFER)
	BIT	7,(IX+0)
	JP	Z,FSCANT
	BIT	3,(IX+0)
	JP	Z,FSCANT
	RES	3,(IX+0)
	LD	E,(IX+9)
	LD	D,(IX+10)
	LD	HL,(T_BUFFER)
	LD	BC,11
	ADD	HL,BC
	CALL	WRITE_BLOCK
	JP	NZ,FSCANT
	RET
;
ACCESS_INODE
	LD	HL,(T_FILENAME)
	LD	A,(HL)
	CP	'/'
	JP	NZ,FSCANT
	INC	HL
;
	LD	DE,0		;Root inode
	LD	(SET_INODE),DE	;Set tree start
;
TREE_LOOP
	LD	HL,(CHAR_PTR)
	CALL	COPY_NEXT	;Next name.
	LD	(CHAR_PTR),HL
;
	CALL	OPEN_INODE
;Inode data is in INODE_TABLE.
	LD	A,(INODE_TABLE)
	BIT	7,A
	JP	Z,FSCANT
	LD	A,(INODE_TABLE+1)
	AND	0E0H
	CP	0E0H	;Directory.
	JR	Z,GO_DOWN
;Not dir so check must be last in path.
	LD	HL,(CHAR_PTR)
	LD	A,(HL)
	OR	A
	JP	NZ,FSCANT	;if not end path.
;All is OK. Inode located.
	RET
;
GO_DOWN		;Go down the tree.
	LD	HL,(CHAR_PTR)
	CP	'/'
	JR	NZ,END_SRCH
	CALL	SRCH_INODE
	JP	NZ,MUST_MAKE
;Exists.
;Gotta go DOWN!
	LD	HL,(DIR_INODE)
	LD	(SET_INODE),HL
	JR	TREE_LOOP
