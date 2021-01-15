;int	x;
	COM	'<small c compiler output>'
*MOD
_X:
	DC	2,0
;
;main() {
_MAIN:
	DEBUG	'main'
;
;	return;
	RET
;	x=100;
	LD	HL,100
	LD	(_X),HL
;	goto fred;
	JP	$?2
;
;	if (x) {
	LD	HL,(_X)
	LD	A,H
	OR	L
	JP	Z,$?3
;		x= 3;
	LD	HL,3
	LD	(_X),HL
;	}
;
;fred:	if (x) {
$?3:
$?2:
	LD	HL,(_X)
	LD	A,H
	OR	L
	JP	Z,$?4
;		x= 4;
	LD	HL,4
	LD	(_X),HL
;	} else {
	JP	$?5
$?4:
;		x= 5;
	LD	HL,5
	LD	(_X),HL
;	}
$?5:
;
;	for (3;3;3) {
	LD	HL,3
$?8:
	JP	$?9
$?6:
	LD	HL,3
	JP	$?8
$?9:
;		x= 6;
	LD	HL,6
	LD	(_X),HL
;	}
	JP	$?6
$?7:
;
;	do {
$?12:
;		x= 7;
	LD	HL,7
	LD	(_X),HL
;	} while (1);
$?10:
	JP	$?12
$?11:
;
;	while (1) {
$?13:
;		x= 8;
	LD	HL,8
	LD	(_X),HL
;	}
	JP	$?13
$?14:
;
;	switch(4) {
	LD	HL,4
	JP	$?17
;		case 1 : x= 9;
$?18:
	LD	HL,9
	LD	(_X),HL
;		case 2 : x= 10;
$?19:
	LD	HL,10
	LD	(_X),HL
;			 break;
	JP	$?16
;		default : x= 11;
$?20:
	LD	HL,11
	LD	(_X),HL
;			  break;
	JP	$?16
;	}
	JP	$?16
$?17:
	CALL	CCSWITCH
	DEFW	$?18,1
	DEFW	$?19,2
	DEFW	0
	JP	$?20
$?16:
;
;}
	RET
;
	END
