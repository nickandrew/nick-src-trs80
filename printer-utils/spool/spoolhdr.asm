;Spoolhdr: Header file for spooler. Model I.
;(C) 1986, Zeta Microcomputer Software.
;
QUEUE_PTR	EQU	0FE00H
QUEUE		EQU	0FDFFH
;
MAX_QUEUE	EQU	16
;max_queue*32 + 0fe00h = 10000H ie. top of memory.
;
