;DATA for game1
; 18-Dec-84
;
*LIST	OFF
ALIENDAT	MACRO	#STATUS,#XPOS,#YPOS,#PROGRAM
	DEFB	#STATUS,#XPOS,#YPOS
	DEFW	#PROGRAM
	ENDM
;
MEN_LEFT	DEFB	0
SC_OV	DEFB	0
SCORE	DEFM	'00000'
POINTS	DEFM	'00010'
HI_NAME	DC	16,0
_COUNTER	DEFB	0
TITLE_1	DEFW	16
	DEFM	'Game #1.........'
DEAD	DEFB	0
;
	DEFM	's_vdu>'
S_VDU	DC	1024,0
	DEFM	's_grx>'
S_GRX	DC	1024,0
	DC	128,80H		;s_grx overflow area
;
	DEFM	'temp>'
_TEMPB	DEFB	0
_TEMPW	DEFW	0
;
	DEFM	'Posn>'
MAN_POSN	DEFB	0
NUM_ALIEN	DEFB	0
	DEFM	'chars>'
MAN_CH_1	DEFB	10010110B
MAN_CH_2	DEFB	10101001B
AL_CH_1	DEFB	10011001B
AL_CH_2	DEFB	10100110B
SH_CH_1	DEFB	10001000B
SH_CH_2	DEFB	10000100B
AL_SH_1	DEFB	10100100B
AL_SH_2	DEFB	10011000B
_AL_CTR	DEFB	0
	DEFM	'Alien Table>'
AL_TAB	DC	MAX_ALIEN*5,0
_TABST	DEFW	0
_POS_CTR	DEFW	0
;
	DEFM	'Man Shots>'
SHOT_FIRED	DEFB	0
SHOT_X	DEFB	0
SHOT_Y	DEFB	0
;
;Alien's shots fired data.
AL_SHOT	DC	MAX_ALIEN*3,0
;
	DEFM	'_Tabend>'
_TABEND	DEFW	0
LOOP_PTR	DEFW	0
CALL_PTR	DEFW	0
	DEFM	'Loop Stack>'
LOOP_ALWD	EQU	4
LOOP_STK	DC	MAX_ALIEN*LOOP_ALWD,0
	DEFM	'Call Stack>'
CALL_STK	DC	MAX_ALIEN*5,0
	DEFM	'_Insaddr>'
_INSADDR	DEFW	0
ALIEN	DEFB	0
WAVE_PC	DEFW	0
WAVE_CTR	DEFB	0
WAVE_DELAY	DEFW	0
;
ALIEN_NO	DEFB	0
SYNC_TAB	DC	3,0
SYNC_FLAG	DEFB	0
WAVE_START	DEFW	0
;
MANDATA_1	DEFB	10010110B,10101001B,10000000B
MANDATA_2	DEFB	10101000B,10000011B,10010100B
;
SHDATA	DEFB	10000010B,10000001B
	DEFB	10000000B,10000011B
	DEFB	10001000B,10000100B
	DEFB	10000000B,10001100B
	DEFB	10100000B,10010000B
	DEFB	10000000B,10110000B
;
WX	DEFB	0
WY	DEFB	0
PX	DEFB	0
YMOD3	DEFB	0
YDIV3	DEFB	0
XMOD2	DEFB	0
WXWY	DEFB	0
;
BMDATA	DEFB	10100100B,10011000B,10000000B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10001000B,10110000B,10000100B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10010000B,10100000B,10000000B
	DEFB	10000010B,10000001B,10000000B
	DEFB	10100000B,10000000B,10010000B
	DEFB	10000000B,10000011B,10000000B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10001001B,10000110B,10000000B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10000010B,10001100B,10000001B
;
ALDATA	DEFB	10011001B,10100110B,10000000B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10100010B,10001100B,10010001B
	DEFB	10000000B,10000000B,10000000B
	DEFB	10100100B,10011000B,10000000B
	DEFB	10000001B,10000010B,10000000B
	DEFB	10001000B,10110000B,10000100B
	DEFB	10000010B,10000000B,10000001B
	DEFB	10010000B,10100000B,10000000B
	DEFB	10000110B,10001001B,10000000B
	DEFB	10100000B,10000000B,10010000B
	DEFB	10001000B,10000011B,10000100B
;
LOOP_A	DC	MAX_ALIEN,0
LOOP_B	DC	MAX_ALIEN,0
;
TOP_ALIEN	DEFB	0
;
*LIST	ON
