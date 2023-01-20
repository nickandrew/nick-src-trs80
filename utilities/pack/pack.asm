;pack: Pack a file according to the Unix tradition
;Hacked from pack.c, Nick Andrew, 19-Oct-86
;
*GET	DOSCALLS
;
US	EQU	1FH
RS	EQU	1EH
CR	EQU	0DH
BUFF_LEN	EQU	36	;sectors/track.
;
	COM	'<pack 1.1  02-Nov-86>'
;
	ORG	5300H
START	LD	SP,START
;
	PUSH	HL
	LD	DE,INFILE
	CALL	STR_CPY_WORD
	POP	HL
;
	LD	DE,FCB_IN
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
;
START_1	LD	A,(HL)
	INC	HL
	CP	' '
	JR	Z,START_1
	DEC	HL
;
	LD	DE,FCB_OUT
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
;
	LD	HL,BUF_IN
	LD	DE,FCB_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	HL,BUF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
;
	LD	HL,M_PACK
	CALL	MESS
	LD	HL,INFILE
	CALL	MESS
	LD	HL,M_COLON
	CALL	MESS
;
	CALL	INPUT
	CALL	PACKFILE
	CALL	OUTPUT
;
	CALL	BFLUSH
	LD	HL,M_PACKED
	CALL	MESS
;
	LD	DE,FCB_IN
	CALL	DOS_CLOSE
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	XOR	A
	JP	DOS_NOERROR
;
PACKFILE			;attempt to pack it.
;
;Put occurring chars in heap with their counts
	LD	HL,-1
	LD	(DIFFBYTES),HL
	LD	HL,4*256+COUNT
	LD	DE,1		;low order long
	LD	BC,0		;high order long
	CALL	LONGMOVE
	LD	DE,0
	LD	HL,INSIZE
	CALL	LONGMOVE
	LD	HL,0
	LD	(N),HL
;
;Loop 257 times (256 ... 0)
	LD	BC,257
;
PA_01	DEC	BC
	LD	HL,PARENT	;parent(i)=0;
	ADD	HL,BC
	ADD	HL,BC
	LD	(HL),0
	INC	HL
	LD	(HL),0
;
	LD	HL,COUNT
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	XOR	A
	CP	(HL)
	JR	NZ,PA_03
	INC	HL
	CP	(HL)
	JR	NZ,PA_03
	INC	HL
	CP	(HL)
	JR	NZ,PA_03
	INC	HL
	CP	(HL)
	JR	NZ,PA_03
PA_02	LD	A,B
	OR	C
	JR	NZ,PA_01
	JR	PA_04
;
PA_03	LD	HL,(DIFFBYTES)
	INC	HL
	LD	(DIFFBYTES),HL
;
	LD	HL,COUNT
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	LD	DE,INSIZE
	PUSH	HL
	LD	A,(DE)		;long addition.
	ADD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
;
	LD	HL,(N)		;++n
	INC	HL
	LD	(N),HL
	PUSH	HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	ADD	HL,HL		;multiply by 6
	LD	DE,HEAP
	ADD	HL,DE		;&(heap(++n).count)
	POP	DE		;pop count(i)
	EX	DE,HL
	PUSH	BC
	LD	BC,4
	LDIR			;heap(++n).count=count(i)
	POP	BC
	EX	DE,HL
	LD	(HL),C		;heap(n).node=i;
	INC	HL
	LD	(HL),B
;
	JR	PA_02
;
PA_04	LD	HL,(DIFFBYTES)
	LD	DE,2
	OR	A
	SBC	HL,DE
	JR	NC,PA_05
;
	LD	HL,M_TRIVIAL
	CALL	MESS
	JP	NOPACK
;
PA_05	LD	HL,INSIZE	;insize >>=1;
	CALL	LONG_SR
;
;for (i=n/2; i>=1; i--) heapify(i);
	LD	HL,(N)
	LD	A,H
	SRL	A
	LD	B,A
	LD	A,L
	RRA
	LD	C,A
PA_06
	LD	A,B
	OR	C
	JR	Z,PA_07
	PUSH	BC
	CALL	HEAPIFY
	POP	BC
	DEC	BC
	JR	PA_06
;
PA_07				;Build huffman tree
	LD	HL,256
	LD	(LASTNODE),HL
;
;while (n > 1)
PA_08	LD	HL,(N)
	LD	DE,2
	OR	A
	SBC	HL,DE
	JR	C,PA_09
;
	LD	HL,HEAP+10	;&heap(1).node
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de=heap(1).node
	LD	HL,PARENT	;parent(heap(1).node)= ++lastnode;
	ADD	HL,DE
	ADD	HL,DE
	LD	DE,(LASTNODE)
	INC	DE
	LD	(LASTNODE),DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
;
	LD	HL,HEAP+6	;&heap(1).count
	LD	DE,INC
	LD	BC,4
	LDIR			;inc=heap(1).count
;
	LD	HL,(N)
	PUSH	HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	ADD	HL,HL
	LD	DE,HEAP
	ADD	HL,DE		;hl=&heap(n)
	LD	DE,HEAP+6	;de=&heap(1)
	LD	BC,6
	LDIR			;hmove(heap(n),heap(1));
;
	LD	HL,(N)
	DEC	HL
	LD	(N),HL
;
	LD	BC,1		;heapify(1);
	CALL	HEAPIFY
;
	LD	HL,HEAP+10	;&heap(1).node
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,PARENT
	ADD	HL,DE
	ADD	HL,DE		;hl=parent(heap(1).node)
	LD	DE,(LASTNODE)
	LD	(HL),E
	INC	HL
	LD	(HL),D		;parent(...)=lastnode;
;
	LD	HL,HEAP+10	;&heap(1).node
	LD	(HL),E
	INC	HL
	LD	(HL),D
;
	LD	DE,HEAP+6	;&heap(1).count
	LD	HL,INC
	LD	A,(DE)		;long addition.
	ADD	A,(HL)		;heap(1).count+=inc;
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
;
	LD	BC,1
	CALL	HEAPIFY
;
	JP	PA_08		;continue while (n>1)
;
PA_09
	LD	HL,(LASTNODE)	;parent(lastnode)=0;
	ADD	HL,HL
	LD	DE,PARENT
	ADD	HL,DE
	LD	(HL),0
	INC	HL
	LD	(HL),0
;
;Assign lengths to encoding for each character
	LD	HL,0
	LD	(MAXLEV),HL	;maxlev=0;
	LD	(BITSOUT),HL	;bitsout=0;
	LD	(BITSOUT+2),HL	;...
;
	LD	B,48		;for (i=1;i<=24;i++)
	LD	HL,LEVCOUNT+2	;&levcount(1)
	XOR	A
PA_10	LD	(HL),A
	INC	HL
	DJNZ	PA_10
;
	LD	BC,0		;for (i=0;i<=256;i++)
PA_11
	LD	HL,0
	LD	(_C),HL		;c=0;
;
	LD	HL,PARENT
	ADD	HL,BC
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;parent(i)
;
PA_12	LD	A,D
	OR	E
	JR	Z,PA_13
	LD	HL,(_C)		;++c;
	INC	HL
	LD	(_C),HL
	EX	DE,HL		;hl=p
	ADD	HL,HL
	LD	DE,PARENT
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	JR	PA_12
;
PA_13	LD	HL,(_C)		;levcount(c)++;
	ADD	HL,HL
	LD	DE,LEVCOUNT
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
;
	LD	HL,LENGTH
	ADD	HL,BC
	LD	DE,(_C)
	LD	(HL),E
;
	LD	HL,(MAXLEV)
	OR	A
	SBC	HL,DE
	JR	NC,PA_13A
	LD	(MAXLEV),DE
PA_13A
	PUSH	BC
	PUSH	DE
	LD	HL,COUNT	;index into count(i)
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	LD	DE,COUNT2
	LD	BC,4
	LDIR
	LD	HL,COUNT2	;divide long by 2
	CALL	LONG_SR
;
	POP	BC	;=_c
PA_14	LD	A,B
	OR	C
	JR	Z,PA_15		;successive addition.
;
	LD	HL,BITSOUT
	LD	DE,COUNT2
;
	LD	A,(DE)
	ADD	A,(HL)
	LD	(HL),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(HL),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)
	ADC	A,(HL)
	LD	(HL),A
;
	DEC	BC
	JR	PA_14
;
PA_15	POP	BC
	INC	BC
	LD	HL,257
	OR	A
	SBC	HL,BC
	JP	NZ,PA_11	;loop
;
;if (maxlev > 24)
	LD	HL,(MAXLEV)
	LD	DE,25
	OR	A
	SBC	HL,DE
	JR	C,PA_16
;
	LD	HL,M_LEVELS
	CALL	MESS
	JP	NOPACK
;
PA_16
;Code not written ... too tedious. Follows:
;outsize=((bitsout+7)>>3)+6+maxlev+diffbytes;
;if ((insize+BLKSIZE-1)/BLKSIZE <=
;  (outsize+BLKSIZE-1)/BLKSIZE && !force) {
;     printf(": no saving");
;     return(0);
;  }
;
;But! This piece of code is necessary.
;compute bit patterns for each character
	LD	HL,INC		;inc= 1L <<24
	LD	DE,0
	LD	BC,0100H
	CALL	LONGMOVE
;
	LD	BC,(MAXLEV)	;inc >>= maxlev;
	LD	HL,INC
PA_17	LD	A,B
	OR	C
	JR	Z,PA_18
	CALL	LONG_SR
	DEC	BC
	JR	PA_17
;
PA_18
	LD	HL,MASK
	LD	DE,0
	LD	BC,0
	CALL	LONGMOVE
;
	LD	HL,(MAXLEV)
	LD	(_I),HL
;
PA_19	LD	HL,(_I)
	LD	A,H
	OR	L
	JP	Z,PA_25
;
	LD	HL,0
	LD	(_C),HL
PA_20	LD	HL,(_C)
	LD	DE,257
	OR	A
	SBC	HL,DE
	JR	Z,PA_22
	LD	HL,(_C)
	LD	DE,LENGTH
	ADD	HL,DE
	LD	E,(HL)
	LD	D,0
	LD	HL,(_I)
	OR	A
	SBC	HL,DE
	JR	NZ,PA_21
;
	LD	HL,(_C)		;bits(c)=mask;
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,BITS
	ADD	HL,DE
	EX	DE,HL
	LD	HL,MASK
	LD	BC,4
	LDIR
;
	LD	DE,MASK		;mask += inc;
	LD	HL,INC
	LD	A,(DE)		;long addition.
	ADD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(DE)
	ADC	A,(HL)
	LD	(DE),A
;
PA_21
	LD	HL,(_C)
	INC	HL
	LD	(_C),HL
	JR	PA_20
;
PA_22
	LD	B,4
	LD	HL,INC
	LD	DE,INC2
PA_23	LD	A,(HL)
	CPL
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	PA_23
;
	LD	B,4
	LD	HL,MASK
	LD	DE,INC2		;complement of inc
PA_24	LD	A,(DE)
	AND	(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	PA_24
;
	LD	HL,INC
	CALL	LONG_SL
;
	LD	HL,(_I)
	DEC	HL
	LD	(_I),HL
	JP	PA_19
;
PA_25
;end of packfile()
	RET
;
;input(): Gather character frequency statistics.
INPUT
	LD	BC,1024		;256*4
	LD	HL,COUNT
IN_01	LD	(HL),0
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,IN_01
;
IN_02	CALL	GETFILE
	JR	NZ,IN_03
;
	LD	L,A
	LD	H,0
	LD	B,H		;b=0
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,COUNT
	ADD	HL,DE
	LD	A,(HL)		;count(i)+=2;
	ADD	A,2
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
;
	JR	IN_02
;
IN_03	RET
;
;output(): Encode the current file.
OUTPUT
	LD	DE,FCB_IN
	CALL	DOS_REWIND
	JP	NZ,ERROR
;
	LD	A,US		;output header
	CALL	PUTFILE
	LD	A,RS
	CALL	PUTFILE
;
	LD	HL,INSIZE+3
	LD	A,(HL)		;output lengths
	CALL	PUTFILE
	DEC	HL
	LD	A,(HL)
	CALL	PUTFILE
	DEC	HL
	LD	A,(HL)
	CALL	PUTFILE
	DEC	HL
	LD	A,(HL)
	CALL	PUTFILE
;
	LD	A,(MAXLEV)
	CALL	PUTFILE
;
	LD	BC,1		;for (i=1; i<maxlev;++i)
OU_01
	LD	HL,(MAXLEV)
	OR	A
	SBC	HL,BC
	JR	Z,OU_02
	LD	HL,LEVCOUNT
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(HL)
	CALL	PUTFILE
	INC	BC
	JR	OU_01
;
OU_02
	LD	HL,(MAXLEV)
	ADD	HL,HL
	LD	BC,LEVCOUNT
	ADD	HL,BC
	LD	A,(HL)
	SUB	2
	CALL	PUTFILE
;
	LD	HL,1
	LD	(_I),HL
;
OU_03	LD	HL,(MAXLEV)
	LD	DE,(_I)
	OR	A
	SBC	HL,DE
	JR	C,OU_06
;
	LD	BC,0
OU_04	LD	A,B
	CP	1
	JR	Z,OU_05
	LD	HL,LENGTH
	ADD	HL,BC
	LD	E,(HL)
	LD	D,0
	LD	HL,(_I)
	OR	A
	SBC	HL,DE
	JR	NZ,OU_04A
	LD	A,C
	CALL	PUTFILE
OU_04A	INC	BC
	JR	OU_04
;
OU_05	LD	HL,(_I)
	INC	HL
	LD	(_I),HL
	JR	OU_03
;
OU_06
	LD	A,8
	LD	(BITSLEFT),A
;
OU_07				;do {
	CALL	GETFILE
	LD	L,A
	LD	H,0
	JR	Z,OU_08
	LD	HL,256
OU_08	LD	(_C),HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,BITS
	ADD	HL,DE
	LD	DE,MASK
	LD	BC,4
	LDIR			;mask=bits(c)<<bitsleft
;
	LD	A,(BITSLEFT)
	LD	B,A
OU_09	LD	A,B
	OR	A
	JR	Z,OU_09A
	LD	HL,MASK
	CALL	LONG_SL
	DJNZ	OU_09
OU_09A
;
	LD	A,1
	LD	(Q),A
;
	LD	A,(BITSLEFT)
	CP	8
	JR	NZ,OU_10
	XOR	A
	LD	(OUTP),A
OU_10	LD	A,(OUTP)
	LD	HL,MASK+3	;high order
	OR	(HL)
	LD	(OUTP),A
;
	LD	HL,(_C)
	LD	DE,LENGTH
	ADD	HL,DE
	LD	E,(HL)
	LD	A,(BITSLEFT)
	SUB	E
	LD	(BITSLEFT),A
;
OU_11	LD	A,(BITSLEFT)
	BIT	7,A		;test if <0
	JR	Z,OU_12
	ADD	A,8
	LD	(BITSLEFT),A
	LD	A,(OUTP)
	CALL	PUTFILE
	LD	HL,Q
	LD	E,(HL)
	INC	(HL)
	LD	D,0
	LD	HL,MASK+3
	OR	A
	SBC	HL,DE
	LD	A,(HL)
	LD	(OUTP),A
	JR	OU_11
;
OU_12
	LD	HL,(_C)		;while (c!=256);
	LD	DE,256
	OR	A
	SBC	HL,DE
	JP	NZ,OU_07
;
	LD	A,(BITSLEFT)
	CP	8
	LD	A,(OUTP)
	CALL	C,PUTFILE
;
;Done! Packed!
	RET
;
;heapify(i) makes a heap out of heap(i)...heap(n)
HEAPIFY
;on init, BC=i.
	PUSH	BC
	POP	HL
	LD	(_I2),HL
	ADD	HL,HL
	ADD	HL,BC
	ADD	HL,HL
	LD	DE,HEAP
	ADD	HL,DE		;&heap(i)
	LD	DE,HEAPSUBI
	LD	BC,6
	LDIR			;move heap(i)->heapsubi
;
	LD	HL,(N)
	SRL	H
	RR	L
	LD	(LASTPARENT),HL	;lastparent=n/2;
;
HE_01	LD	HL,(LASTPARENT)
	LD	DE,(_I2)
	OR	A
	SBC	HL,DE
	JR	C,HE_03
;
	EX	DE,HL
	ADD	HL,HL
	LD	(K),HL
;
	PUSH	HL
	ADD	HL,HL
	POP	DE
	ADD	HL,DE
	ADD	HL,HL
	LD	DE,HEAP
	ADD	HL,DE		;&heap(k).count
	LD	DE,6
	PUSH	HL
	ADD	HL,DE
	POP	DE		;de=h(k), hl=h(k+1)
	EX	DE,HL
	CALL	LONG_CMP
	JR	NC,HE_02
	LD	HL,(K)
	OR	A
	LD	DE,(N)
	SBC	HL,DE
	JR	NC,HE_02
	LD	HL,(K)
	INC	HL
	LD	(K),HL
HE_02	LD	DE,HEAPSUBI
	LD	HL,(K)
	PUSH	HL
	POP	BC
	ADD	HL,HL
	ADD	HL,BC
	ADD	HL,HL
	LD	BC,HEAP
	ADD	HL,BC		;&heap(k)
	CALL	LONG_CMP
	JR	C,HE_03
;
	LD	HL,(_I2)
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	LD	DE,HEAP
	ADD	HL,DE
	EX	DE,HL		;&heap(i)
	LD	BC,(K)
	PUSH	BC
	POP	HL
	ADD	HL,HL
	ADD	HL,BC
	ADD	HL,HL
	LD	BC,HEAP
	ADD	HL,BC
	LD	BC,6
	LDIR
;
	LD	HL,(K)
	LD	(_I2),HL
;
	JR	HE_01
;
HE_03
	LD	HL,(_I2)
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	LD	DE,HEAP
	ADD	HL,DE
	EX	DE,HL		;&heap(i)
	LD	HL,HEAPSUBI
	LD	BC,6
	LDIR
;
	RET
;
;*******************************************************
;
LONGMOVE
	PUSH	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
	POP	HL
	RET
;
LONG_SR
	INC	HL
	INC	HL
	INC	HL
	SRL	(HL)
	DEC	HL
	RR	(HL)
	DEC	HL
	RR	(HL)
	DEC	HL
	RR	(HL)
	RET
;
LONG_SL
	PUSH	HL
	SLA	(HL)
	INC	HL
	RL	(HL)
	INC	HL
	RL	(HL)
	INC	HL
	RL	(HL)
	POP	HL
	RET
;
STR_CPY_WORD
	LD	A,(HL)
	LD	(DE),A
	CP	CR
	JR	Z,SCW_1
	OR	A
	JR	Z,SCW_1
	CP	' '
	JR	Z,SCW_1
	INC	HL
	INC	DE
	JR	STR_CPY_WORD
SCW_1	XOR	A
	LD	(DE),A
	RET
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS
;
PUTFILE
	PUSH	HL
	PUSH	DE
	LD	HL,(BUFF_POS)
	LD	DE,256*BUFF_LEN+BUFF_ST
	OR	A
	SBC	HL,DE
	CALL	Z,FLUSH
	LD	HL,(BUFF_POS)
	LD	(HL),A
	INC	HL
	LD	(BUFF_POS),HL
	POP	DE
	POP	HL
	RET
;
FLUSH
	PUSH	AF
	LD	B,BUFF_LEN
	LD	HL,BUFF_ST
FLUSH_1	LD	DE,BUF_OUT
	PUSH	BC
	LD	BC,256
	LDIR
	PUSH	HL
	LD	DE,FCB_OUT
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	POP	HL
	POP	BC
	DJNZ	FLUSH_1
	LD	HL,BUFF_ST
	LD	(BUFF_POS),HL
	POP	AF
	RET
;
BFLUSH
	LD	HL,BUFF_ST
BFLUSH_1
	PUSH	HL
	LD	DE,(BUFF_POS)
	OR	A
	SBC	HL,DE
	POP	HL
	RET	Z
	LD	A,(HL)
	INC	HL
	LD	DE,FCB_OUT
	CALL	$PUT
	JP	NZ,ERROR
	JR	BFLUSH_1
;
GETFILE	PUSH	DE
	LD	DE,FCB_IN
	CALL	$GET
	POP	DE
	RET	Z
	CP	1CH
	JR	Z,GF_01
	CP	1DH
	JP	NZ,ERROR
GF_01	LD	A,255
	OR	A
	RET
;
NOPACK	LD	HL,M_NOPACK
	CALL	MESS
	JP	DOS_NOERROR
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	DOS_NOERROR
;
USAGE	LD	HL,M_USAGE
	CALL	MESS
	JP	DOS_NOERROR
;
LONG_CMP
	PUSH	HL
	PUSH	DE
	INC	HL
	INC	HL
	INC	HL
	INC	DE
	INC	DE
	INC	DE
	LD	A,(DE)
	CP	(HL)
	JR	NZ,LCP_1
	DEC	DE
	DEC	HL
	LD	A,(DE)
	CP	(HL)
	JR	NZ,LCP_1
	DEC	DE
	DEC	HL
	LD	A,(DE)
	CP	(HL)
	JR	NZ,LCP_1
	DEC	DE
	DEC	HL
	LD	A,(DE)
	CP	(HL)
;
LCP_1	POP	DE
	POP	HL
	RET
;
;********************************************************
;Data ....
;
COUNT		DEFS	257*4	;long
COUNT2		DEFS	4
INSIZE		DEFS	4
OUTSIZE		DEFS	4
DICTSIZE	DEFS	4
BITS		DEFS	257*4
INC		DEFS	4
INC2		DEFS	4
LEVCOUNT	DEFS	25*2
PARENT		DEFS	513*2
LENGTH		DEFS	257
MASK		DEFS	4
HEAP		DEFS	258*6
HEAPSUBI	DEFS	6
;
DIFFBYTES	DEFW	0
MAXLEV		DEFW	0
LASTNODE	DEFW	0
N		DEFW	0
_I		DEFW	0
_I2		DEFW	0
_C		DEFW	0
K		DEFW	0
Q		DEFB	0
OUTP		DEFB	0
BITSOUT		DEFS	4
BITSLEFT	DEFB	0
LASTPARENT	DEFW	0
;
BUFF_POS	DEFW	BUFF_ST
;
M_PACK	DEFM	'pack: ',0
M_COLON	DEFM	' : ',0
M_USAGE	DEFM	'usage: pack infile outfile',CR,0
M_TRIVIAL	DEFM	': trivial file',CR,0
M_PACKED	DEFM	': packed',CR,0
M_LEVELS	DEFM	': too many levels',CR,0
M_NOPACK	DEFM	': was not packed',CR,0
;
INFILE	DEFS	80
;
FCB_IN	DEFS	32
FCB_OUT	DEFS	32
BUF_IN	DEFS	256
BUF_OUT	DEFS	256
;
BUFF_ST	DEFS	BUFF_LEN*256
;
	END	START
