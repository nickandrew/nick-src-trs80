;Filek/asm
CLSERR:	DB	'Cannot close output file',0
UCRERR:	DB	'Incompatible crunched file format',0
TYPERR:	DB	'Typeout line limit exceeded',0
WARN:	DB	'Warning: Extracted file has incorrect ',0
CRCERR:	DB	'CRC',0
LENERR:	DB	'length',0
MONTX:	DB	'???JanFebMarAprMayJunJulAugSepOctNovDec'
STOWTX:	DB	'Unpacked'
	DB	' Packed '
	DB	'Squeezed'
	DB	'Crunched'
	DB	'Unknown!'
TITLES:	DB	'Name           Length  Disk  Stowage  Ver  Stored Save'
	DB	'd   Date      Time   CRC'
	DB	CR
TITLE1:	DB	'============  =======  ====  ======== === ======= ===='
	DB	'= =========  ======  ===='
;LINLEN	EQU	$-TITLE1
	DB	0
TOTALS:	DB	'        ====  =======  ====               =======  ==='
	DB	CR
	DB	'Total  '	; (LINE must follow!)
	PAGE
	SUBTTL	Data Storage
; Unitialized data last (does not contribute to .COM file size)
LINE:	DS	LINLEN+1	; Listing line buffer (follow TOTALS!)
	DS	50*2		; Program stack (50 levels)
STACK	EQU	$		; (Too small will only garbage listing)
TOTS:				; Start of listing totals
TFILES:	DS	2		;  Total files processed
TLEN:	DS	4		;  Total uncompressed bytes
TDISK:	DS	2		;  Total 1K disk blocks
TSIZE:	DS	4		;  Total compressed bytes
LINCT:	DS	1		; Line count for file typeout
TOTC	EQU	$-TOTS		; Count of bytes to clear
GETPTR:	DS	2		; Input buffer pointer
LBLKSZ:	DS	1		; Disk allocation block size for listing
TNAME:	DS	11		; Test pattern for selecting file names
OFCB:	DS	32		; Output file FCB
IFCB:	DS	32		; Input file FCB
;
IFCB_BUF	DEFS	256	;Buffer for input
OFCB_BUF	DEFS	256	;Buffer for output
;
HDRBUF:				; Archive file header buffer...
VER:	DS	1		; Header version no. (stowage type)
NAME:	DS	13		; Name string (NUL-terminated)
SIZE:	DS	4		; Compressed bytes
DATE:	DS	2		; Creation date
TIME:	DS	2		; Creation time
CRC:	DS	2		; Cyclic check of uncompressed file
LEN:	DS	4		; Uncompressed bytes (version > 1)
HDRSIZ	EQU	$-HDRBUF	; Header size (4 less if version = 1)
MINMEM	EQU	$-1		; Min memory limit (no file output)
	PAGE
; Data for file output processing only
				; Following order required:
BUFPAG:	DS	1		;  Output buffer start page
BUFLIM:	DS	1		;  Output buffer limit page
				; Following order required:
CODES:	DS	1		;  Code count for crunched input
BITSAV:	DS	1		;  Bits save for crunched input
BITS:	DS	1		;  Bit count for crunched input
STRCT:	DS	2		; No. entries in crunched string table
; Tables and buffers for file output
; (All of the following must be page-aligned)
	ORG $+255.AND.0FF00H	; Align to page boundary
CRCTAB:	DS	256*2		; CRC lookup table (256 2-byte values)
BUFF	EQU	$		; Output buff for non-squeezed/crunched
				; or:
TREE	EQU	$		; Decoding tree for squeezed files
TREESZ	EQU	256*4		; (256 4-byte nodes)
BUFFSQ	EQU	TREE+TREESZ	; Output buffer for squeezed files
				; or:
STRT	EQU	$		; String table for crunched files
STRSZ	EQU	4096*3		; (4K 3-byte entries)
BUFFCR	EQU	STRT+STRSZ	; Output buffer for newer crunched files
				; plus (for old-style crunched files):
HSHT	EQU	BUFFCR		; Extra table for hash code chaining
HSHSZ	EQU	4096*2		; (4K 2-byte entries)
BUFFCX	EQU	HSHT+HSHSZ	; Output buffer for older crunched files
; That's all, folks!
;
	END	BEGIN
