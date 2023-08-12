;int	x,y;
	COM	'<small c compiler output>'
*MOD
_X:
	DC	2,0
_Y:
	DC	2,0
;int	*ip;
_IP:
	DC	2,0
;char	c,d;
_C:
	DC	1,0
_D:
	DC	1,0
;char	*cp;
_CP:
	DC	2,0
;
;main() {
_MAIN:
	DEBUG	'main'
;	x = *ip;
	LD	HL,(_IP)
	CALL	CCGINT
	LD	(_X),HL
;
;	ip = &x;
	LD	HL,_X
	LD	(_IP),HL
;
;	x = -y;
	LD	HL,(_Y)
	CALL	CCNEG
	LD	(_X),HL
;
;	x = !y;
	LD	HL,(_Y)
	CALL	CCLNEG
	LD	(_X),HL
;
;	x = ~y;
	LD	HL,(_Y)
	CALL	CCCOM
	LD	(_X),HL
;
;	x = ++y;
	LD	HL,(_Y)
	INC	HL
	LD	(_Y),HL
	LD	(_X),HL
;
;	x = --y;
	LD	HL,(_Y)
	DEC	HL
	LD	(_Y),HL
	LD	(_X),HL
;
;	x = y++;
	LD	HL,(_Y)
	INC	HL
	LD	(_Y),HL
	DEC	HL
	LD	(_X),HL
;
;	x = y--;
	LD	HL,(_Y)
	DEC	HL
	LD	(_Y),HL
	INC	HL
	LD	(_X),HL
;
;	x = x * y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCMULT
	LD	(_X),HL
;
;	x = x / y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCDIV
	LD	(_X),HL
;
;	x = x % y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCDIV
	EX	DE,HL
	LD	(_X),HL
;
;	x = x + y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	ADD	HL,DE
	LD	(_X),HL
;
;	x = x - y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCSUB
	LD	(_X),HL
;
;	x = y << 1;
	LD	HL,(_Y)
	PUSH	HL
	LD	HL,1
	POP	DE
	CALL	CCASL
	LD	(_X),HL
;
;	x = y >> 1;
	LD	HL,(_Y)
	PUSH	HL
	LD	HL,1
	POP	DE
	CALL	CCASR
	LD	(_X),HL
;
;	x = x < y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCLT
	LD	(_X),HL
;
;	x = x > y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCGT
	LD	(_X),HL
;
;	x = x <= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCLE
	LD	(_X),HL
;
;	x = x >= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCGE
	LD	(_X),HL
;
;	x = x == y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCEQ
	LD	(_X),HL
;
;	x = x != y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCNE
	LD	(_X),HL
;
;	x = x & y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCAND
	LD	(_X),HL
;
;	x = x ^ y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCXOR
	LD	(_X),HL
;
;	x = x | y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCOR
	LD	(_X),HL
;
;	x = x && y;
	LD	HL,(_X)
	LD	A,H
	OR	L
	JP	Z,$?2
	LD	HL,(_Y)
	LD	A,H
	OR	L
	JP	Z,$?2
	LD	HL,1
	JP	$?3
$?2:
	LD	HL,0
$?3:
	LD	(_X),HL
;
;	x = x || y;
	LD	HL,(_X)
	LD	A,H
	OR	L
	JP	NZ,$?4
	LD	HL,(_Y)
	LD	A,H
	OR	L
	JP	NZ,$?4
	LD	HL,0
	JP	$?5
$?4:
	LD	HL,1
$?5:
	LD	(_X),HL
;
;	x = 1;
	LD	HL,1
	LD	(_X),HL
;
;	x += 1;
	LD	HL,(_X)
	LD	DE,1
	ADD	HL,DE
	LD	(_X),HL
;
;	x -= 1;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,1
	POP	DE
	CALL	CCSUB
	LD	(_X),HL
;
;	x *= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCMULT
	LD	(_X),HL
;
;	x /= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCDIV
	LD	(_X),HL
;
;	x %= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCDIV
	EX	DE,HL
	LD	(_X),HL
;
;	x >>= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCASR
	LD	(_X),HL
;
;	x <<= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCASL
	LD	(_X),HL
;
;	x &= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCAND
	LD	(_X),HL
;
;	x ^= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCXOR
	LD	(_X),HL
;
;	x |= y;
	LD	HL,(_X)
	PUSH	HL
	LD	HL,(_Y)
	POP	DE
	CALL	CCOR
	LD	(_X),HL
;
;}
	RET
;
	END
