;WAVEDATA for Game.
; 18-Dec-84.
;
WAVES
WAVE_1	WAVE
LBL_1	WREPT	10
	NEW	0,3,PAT_1
	REST
	WAIT	3
	WENDR	LBL_1
	WAIT	88
	WSYNC	0,_LBL_4
	WAIT	111
LBL_2	WREPT	10
	NEW	0,10,PAT_1
	REST
	WAIT	3
	WENDR	LBL_2
	WAIT	88
	WSYNC	0,_LBL_4
	FINISH
	WAIT	20
WAVE_2	WAVE
LBL_3	WREPT	10
	NEW	63,3,PAT_2
	REST
	REST
	REST
	REST
	WENDR	LBL_3
	WAIT	90
	WSYNC	0,_LBL_15
	FINISH
	WAIT	30
LBL_4	WREPT	10
	NEW	63,3,PAT_3
	REST
	REST
	REST
	REST
	WENDR	LBL_4
	WAIT	85
	WSYNC	0,_LBL_15
	WAIT	120
	WSYNC	2,_LBL_16
	WAIT	60
	KILLALL
	NEWMAN
	JMP	WAVE_1
;
;
;
PAT_1	REPTA	12
	DOWN
	ENDRA	PAT_1
_LBL_1	REPTA	60
	RIGHT
	ENDRA	_LBL_1
_LBL_2	REPTA	12
	UP
	ENDRA	_LBL_2
_LBL_3	REPTA	44
	LEFT
	ENDRA	_LBL_3
_LBL_31	DOWN
	JUMP	_LBL_31
_LBL_4	REPTA	4
	LEFT
	ENDRA	_LBL_4
_LBL_5	REPTA	8
	RIGHT
	ENDRA	_LBL_5
_LBL_6	REPTA	4
	LEFT
	ENDRA	_LBL_6
	JUMP	_LBL_4
;
PAT_2	REPTA	30
	DOWN
	ENDRA	PAT_2
_LBL_7	REPTA	31
	LEFT
	ENDRA	_LBL_7
_LBL_8	REPTA	27
	UP
	ENDRA	_LBL_8
_LBL_9	REPTA	50
	RIGHT
	ENDRA	_LBL_9
_LBL_10	DOWN
	JUMP	_LBL_10
;
PAT_3	REPTA	30
	DOWN
	ENDRA	PAT_3
_LBL_11	REPTA	25
	RIGHT
	ENDRA	_LBL_11
_LBL_12	REPTA	27
	UP
	ENDRA	_LBL_12
_LBL_13	REPTA	50
	LEFT
	ENDRA	_LBL_13
_LBL_14	DOWN
	JUMP	_LBL_14
;
_LBL_15	RIGHT
	DOWN
	RIGHT
	UP
	RIGHT
	UP
	LEFT
	UP
	LEFT
	DOWN
	LEFT
	DOWN
	JUMP	_LBL_15
;
_LBL_16	RIGHT
	JUMP	_LBL_16
;