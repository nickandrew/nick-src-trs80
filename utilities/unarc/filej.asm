; @(#) filej.asm - Messages - 06 May 89
	PAGE
;
E_FLAG	DEFB	0		;1=extract data
T_FLAG	DEFB	0		;1=type to vdu.
L_FLAG	DEFB	0		;1=List index
X_FLAG	DEFB	0		;1=Extract files
H_FLAG	DEFB	0		;1=Print help info
O_FLAG	DEFB	0		;1=Overwrite existing output file
WARNFLAG	DEFB	0	;File had wrong CRC / bad length
;
;
	SUBTTL	Messages and Initialized Data
PABMSG:	DB	'Paborted',0
WRNMSG:	DB	'Warnings issued!',0
ABOMSG:	DB	'UNARC aborted!',0
NOROOM:	DB	'Not enough memory',0
NAMERR:	DB	'Ambiguous archive file name',0
OPNERR:	DB	'Cannot find archive file',0
FMTERR:	DB	'Invalid archive file format',0
HDRERR:	DB	'Warning: Bad archive file header, bytes skipped = '
HDRSKP:	DB	'00000',0
EOFERR:	DB	'Unexpected end of archive file',0
NOFILS:	DB	'No matching file(s) in archive',0
BADIDR:	DB	'Invalid archive file drive',0
BADODR:	DB	'Invalid output drive',0
ARCMSG:	DB	'Archive File = '
ARCNAM:	DB	'FILENAME.ARC',0
	DC	32-13,0
OUTMSG:	DB	'Output Drive = '
OUTDRV:	DB	'A:',0
BADVER:	DB	'Cannot extract file (need newer version of UNARC?)',0
EXISTS:	DB	'Output file already exists.',CR,0
DSKFUL:	DB	'Disk full',0
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
TITLES:	DB	'Name           Length  Stowage  Ver  Stored Save'
	DB	'd   Date'
	DB	CR
TITLE1:	DB	'============  =======  ======== === ======= ===='
	DB	'= ========='
	DB	0
TOTALS:	DB	'        ====  =======               =======  ==='
	DB	CR
	DB	'Total  '	; (LINE must follow!)
LINE:	DS	LINLEN+1	; Listing line buffer (follow TOTALS!)
;
