00100   : REM ' REMINDER/BAS: REMINDS USER ABOUT MESSAGES
00110   CLS : CLEAR 6000
00120   GOSUB 1000:: REM ' OPEN MESSAGE FILES AND FIELD
00130   GOSUB 2000:: REM ' CLS AND PRINT TITLE WITH BORDER
00140   GOSUB 3000:: REM ' READ IN ALL REMINDER RECORDS
00150   GOSUB 4000:: REM ' INPUT TIME AND DATE AND TURN ON CLOCK
00160   GOSUB 5000:: REM ' GET TIME AND DATE AND PRINT
00170   POKE 15360 + 51, ASC("*")
00180   GOSUB 7000:: REM ' WAIT FOR EVEN MINUTE
00190   POKE 15360 + 51,32
00200   GOSUB 8000:: REM ' CHECK BULLETIN BOARD
00210   GOTO 170
00990   CLOSE : END
01000   : REM ' OPEN MESSAGE FILES AND FIELD
01010   F1$ = "REMIND1/DAT":L1 = 41:F2$ = "REMIND2/DAT":L2 = 64
01020   OPEN "R",1,F1$,L1: OPEN "R",2,F2$,L2
01030   FIELD 1,1ASMN$,8ASMI$,3ASHR$,1ASDA$,7ASD1$,7ASD2$,7ASD3$,7ASD4$
01040   FIELD 2,63 AS M$
01050   RETURN
02000   : REM ' CLS AND PRINT TITLE WITH BORDER
02010   TITLE$ = "REMINDER":LE = LEN(TITLE$)
02020   PRINT @96 - LE / 2,TITLE$
02030   T1 = 62 - LE:T2 = 66 + LE
02040   FOR T = T1 TO T2: SET(T,1): SET(T,6): NEXT T
02050   FOR T = 2 TO 5: SET(T1,T): SET(T2,T): NEXT T
02060   RETURN
03000   : REM ' READ IN ALL REMINDER RECORDS
03010   R1 = LOF(1):R2 = LOF(2)
03020   DIM M$(R2),MI$(R1),HR$(R1),DA$(R1),D1$(R1),D2$(R1),D3$(R1)
03030   DIM D4$(R1),MN$(R1),ND$(7),T(12)
03040   FOR T = 1 TO R1
03050   GET 1,T
03060   MI$(T) = MI$:HR$(T) = HR$:DA$(T) = DA$:D1$(T) = D1$
03070   D2$(T) = D2$:D3$(T) = D3$:D4$(T) = D4$:MN$(T) = MN$
03080   NEXT T
03090   FOR T = 1 TO R2
03100   GET 2,T
03110   M$(T) = M$
03120   NEXT T
03130   CLOSE 1: CLOSE 2
03140   RETURN
04000   : REM ' INPUT TIME AND DATE AND TURN ON CLOCK
04010   PRINT "TIME AT NEXT MINUTE: ";: LINE INPUT A$
04020   PRINT "DATE: ";: LINE INPUT A1$
04030   CMD "TIME " + A$
04040   CMD "DATE " + A1$
04050   CMD "CLOCK Y"
04060   PRINT "HIT <SPACE> WHEN SEC=00"
04070   IF PEEK(14400) <> 128 THEN GOTO 4070
04080   POKE 16449,0: POKE 16448,39
04090   RETURN
05000   : REM ' GET TIME AND DATE AND PRINT
05010   A$ = TIME$
05020   FOR I = 1 TO 12: READ T(I): NEXT
05030   FOR I = 1 TO 7: READ ND$(I): NEXT
05040   DATA 0,3,3,6,1,4,6,2,5,0,3,5
05050   DATA SUNDAY,MONDAY,TUESDAY,WEDNESDAY
05060   DATA THURSDAY,FRIDAY,SATURDAY
05070   GOSUB 6000:: REM ' GET DAY OF WEEK IN B$
05080   PRINT B$;" ";A$
05090   RETURN
06000   : REM ' GET DAY OF WEEK IN B$
06010   A5$ = LEFT$(A$,8)
06020   X1 = VAL(MID$(A5$,4,2)):: REM ' DAY NUMBER
06030   X2 = VAL(MID$(A5$,1,2)):: REM ' MONTH
06040   X3 = VAL(MID$(A5$,7,2)):: REM ' YEAR
06050   IF X2> 2 THEN L1 = INT(X3 / 4) : ELSE L1 = INT((X3 - 1) / 4)
06060   D1 = L1 + T(X2) + X3 + X1
06070   D2 = INT(D1 / 7)
06080   D3 = D1 - D2 * 7
06090   DN = D3 + 1
06100   B$ = ND$(DN)
06110   RETURN
07000   : REM ' WAIT FOR EVEN MINUTE
07010   IF PEEK(16449) <> 0 THEN 7010
07020   A$ = TIME$
07030   IF PEEK(16449) = 0 THEN 7030
07040   TI$ = A$
07050   GOSUB 6000
07060   RETURN
08000   : REM ' CHECK BULLETIN BOARD
08010   MI = VAL(MID$(TI$,13,2))
08020   M1 = INT(MI / 8)
08030   M2 = MI - M1 * 8
08040   M3 = 2 ^ M2
08050   F2 = 0
08060   FOR T = 1 TO R1
08070   FL = 0
08080   M4 = ASC(MID$(MI$(T),M1 + 1,1))
08090   M5 = M4 AND M3
08100   IF M5 <> 0 THEN GOTO 8140:: REM ' NEXT CHECK HOUR
08110   NEXT T
08120   FL = 0
08130   RETURN
08140   : REM ' NEXT CHECK HOUR
08150   H1 = VAL(MID$(TI$,10,2))
08160   H2 = INT(H1 / 8)
08170   H3 = H1 - H2 * 8
08180   H4 = 2 ^ H3
08190   H5 = ASC(MID$(HR$(T),H2 + 1,1))
08200   H6 = H5 AND H4
08210   IF H6 = 0 THEN GOTO 8110
08220   : REM ' CHECK DAY OF WEEK ALLOWED
08230   D1 = ASC(DA$(T))
08240   D2 = 2 ^ DN
08250   D3 = D1 AND D2
08260   IF D3 = 0 THEN GOTO 8110
08270   : REM ' CHECK DATE
08280   DU$ = D1$(T)
08290   GOSUB 9000:: REM ' CHECK COMPLETE DATE
08300   DU$ = D2$(T)
08310   GOSUB 9000:: REM ' CHECK COMPLETE DATE
08320   DU$ = D3$(T)
08330   GOSUB 9000:: REM ' CHECK COMPLETE DATE
08340   DU$ = D4$(T)
08350   GOSUB 9000
08360   IF FL = 0 THEN GOTO 8110
08370   : REM ' DATE OK: PRINT MESSAGE
08380   IF F2 = 0 THEN A$ = TI$: GOSUB 6000: PRINT "BULLETIN: ";B$;" ";TI$
08390   MN = ASC(MN$(T))
08400   PRINT M$(MN)
08410   IF F2 = 1 THEN GOTO 8110
08420   FOR T2 = 1 TO 10
08430   FOR T3 = 1 TO 20: OUT 255,1: OUT 255,0: OUT 255,1: OUT 255,0: NEXT T3
08440   FOR T3 = 1 TO 20: OUT 200,1: OUT 200,0: OUT 200,1: OUT 200,0: NEXT T3
08450   NEXT T2
08460   F2 = 1
08470   GOTO 8110
09000   Y1 = ASC(MID$(DU$,1,1))
09010   IF Y1 = 0 THEN FL = 1: RETURN
09020   YE = VAL(MID$(TI$,7,2))
09030   Y2 = ASC(MID$(DU$,4,1))
09040   IF YE < Y1 THEN RETURN
09050   IF YE> Y2 THEN RETURN
09060   A3$ = LEFT$(TI$,8)
09070   CMD "J",A3$,A4$
09080   D = VAL(A4$)
09090   E1 = CVI(MID$(DU$,2,2))
09100   E2 = CVI(MID$(DU$,5,2))
09110   IF YE = Y1 AND D < E1 THEN RETURN
09120   IF YE = Y2 AND D> E2 THEN RETURN
09130   X = VAL(MID$(DU$,7,1)):: REM ' INCREMENT
09140   : REM ' FORGET INCREMENT
09150   FL = 1
09160   RETURN
