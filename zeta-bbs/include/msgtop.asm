;msgtop.hdr: Format of MSGTOP.ZMS file.
;Last updated 21-Jun-86.
;
STATS_REC
;
NUM_MSG		DEFW	0	;Total # of msgs
NUM_KLD_MSG	DEFW	0	;# of killed messages
EOF_RBA		DEFB	0,0,0	;TXT file eof.
		DC	9,0
;
;End of msgtop/hdr.
