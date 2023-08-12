;
;int     sargc;
	COM	'<small c compiler output>'
*MOD
_SARGC:
	DC	2,0
;char    **sargv;
_SARGV:
	DC	2,0
;
;main(argc, argv)
;int     argc, *argv;
_MAIN:
	DEBUG	'main'
;        {
;
;        parse();
	CALL	_PARSE
;        outside();
	CALL	_OUTSIDE
;        trailer();
	CALL	_TRAILER
;}
	RET
;
;/*
;**      process all input text
;**
;**      At this level, only static declarations,
;**      defines, includes and function definitions
;**      are legal...
;*/
;
;parse()
;        {
_PARSE:
	DEBUG	'parse'
;
;}
	RET
;
	END
