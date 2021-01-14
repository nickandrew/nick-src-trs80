;rs232.asm: Equates for the RS-232 interface
;Last updated: 05-Jan-88
;
RDSTAT	EQU	0F9H
WRSTAT	EQU	0F9H
RDDATA	EQU	0F8H
WRDATA	EQU	0F8H
;
DTR_BIT	EQU	1
RTS_BIT	EQU	5
CTS_BIT	EQU	0
DAV_BIT	EQU	1
DSR_BIT	EQU	7
;
DTR	EQU	1		;Data Terminal ready
RTS	EQU	5		;High=double baud rate
CTS	EQU	0		;Clear to send
DAV	EQU	1		;Data Available
DSR	EQU	7		;Carrier detect
;
EOT	EQU	04H
ACK	EQU	06H
NAK	EQU	15H
SYN	EQU	16H
SUB	EQU	1AH
;
TSYNC	EQU	0AEH
;
;End of rs232.asm
