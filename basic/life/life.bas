00010   REM ********************************************
00020   REM * LIFE (C) COPYRIGHT NICK ANDREW, 28/3/82. *
00030   REM *      77 WINDSOR ROAD VINEYARD 2765.      *
00040   REM ********************************************
00050   CLS : DIM A(1,61,16)
00060   MX = 32:LX = 26:MY = 12:LY = 8
00070   A(1,31,9) = 1:A(1,31,10) = 1:A(1,31,11) = 1:A(1,30,9) = 1:A(1,29,9) = 1:A(1,28,10) = 1:A(1,27,11) = 1
00080   D = NOT D AND 1
00090   FOR Y = LY TO MY: FOR X = LX TO MX:S = 0: FOR X1 = X - 1 TO X + 1: FOR Y1 = Y - 1 TO Y + 1
00100   S = S + A(D,X1,Y1): NEXT Y1,X1
00110   S = S - A(D,X,Y)
00120   IF A(D,X,Y) = 1 THEN PRINT @X + 64 * Y,"*";:: ELSE PRINT @X + 64 * Y," ";
00130   IF S = 2 THEN B = A(D,X,Y) : ELSE IF S = 3 THEN B = 1 : ELSE B = 0
00140   A(NOT D AND 1,X,Y) = B
00150   IF B = 0 THEN 170 : ELSE IF X>= MX THEN MX = X + 1 : ELSE IF X < = LX THEN LX = X - 1
00160   IF Y>= MY THEN MY = Y + 1: ELSE IF Y < = LY THEN LY = Y - 1
00170   NEXT X,Y
00180   G = G + 1: PRINT @0,"GENERATION";G;
00190   GOTO 80
