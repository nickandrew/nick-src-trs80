;Syscrip/asm: Patches to Scripsit to allow use
; on a basic System-80 (port mapped printer).
; For Scripsit Version 1.15 only??
; Version 1.0 changed to /asm on 27-Aug-84.
;
PORT	EQU	0FDH	;Sys-80 printer port.
;
	ORG	5244H
	OUT	(PORT),A
	NOP
;
	ORG	5F63H
	IN	A,(PORT)
	NOP
;
	ORG	663FH
	IN	A,(PORT)
	NOP
;
	ORG	6650H
	IN	A,(PORT)
	NOP
;
	ORG	665EH
	OUT	(PORT),A
	NOP
;
	ORG	6722H
	OUT	(PORT),A
	NOP
;
	ORG	7A97H
	OUT	(PORT),A
	NOP
;
	ORG	7AA8H
	OUT	(PORT),A
	NOP
;
	ORG	7AC7H
	OUT	(PORT),A
	NOP
;
	END	5200H	;Scripsit start addr.
