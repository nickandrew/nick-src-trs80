/*
** ceval ... C expression evaluator
** uses an operator precedence algorithm
** ref dragon book, Sec 4.6
*/

#include <stdio.h>
#include <stdlib.h>

#define EOS        0
#define PLUS       1
#define MINUS      2
#define TIMES      3
#define DIVIDE     4
#define PAREN_O    5
#define PAREN_C    6

#define NONE       0
#define RIGH       1
#define LEFT       2
#define EQUA       3

/* Function declarations */
void outline(char *s, int n);
void push1(int n);
void push2(int n);
int pop1(void);
int pop2(void);
void exprval(void);
void eval(int tok);
void advance(void);

int rel[25] = {                 /* 5 x row + column */
/*               $     +     -     *     /            */
/* $ */ NONE, LEFT, LEFT, LEFT, LEFT,
/* + */ RIGH, RIGH, RIGH, LEFT, LEFT,
/* - */ RIGH, RIGH, RIGH, LEFT, LEFT,
/* * */ RIGH, RIGH, RIGH, RIGH, RIGH,
/* / */ RIGH, RIGH, RIGH, RIGH, RIGH
};

int stack1[20], stack2[20];
int *sp1, *sp2;

int string[20] = { 3, -PLUS, 2, -TIMES, 4, -PLUS, 6, -EOS };

int *ip;
int token;

int main()
{
    sp1 = stack1;
    sp2 = stack2;
    ip = string;
    push1(-3);
    push2(EOS);
    exprval();
    if (*ip != EOS)
        fputs("Invalid expression (1)\n", stdout);
    outline("Result is ", pop1());
    return 0;
}

void outline(char *s, int n)
{
    char buff[8];
    fputs(s, stdout);
    itoa(n, buff);
    fputs(buff, stdout);
    fputs("\n", stdout);
}

void push1(int n)
{
    outline("Pushing to value stack: ", n);
    *(++sp1) = n;
}

void push2(int n)
{
    outline("Pushing to operator stack: ", n);
    *(++sp2) = n;
}

int pop1(void)
{
    outline("Popping from value stack: ", *sp1);
    return *(sp1--);
}

int pop2(void)
{
    outline("Popping from operator stack: ", *sp2);
    return *(sp2--);
}

void exprval(void)
{
    int relate;
    while (1) {
        token = *ip;
        if (token > 0) {
            /* number */
            push1(token);
            advance();
            continue;
        }

        if (token == PAREN_O) {
            push2(EOS);
            advance();
            exprval();
            if (pop2() != EOS)
                fputs("Inv (2)\n", stdout);
            if (*ip != PAREN_C)
                fputs("Inv (2a)\n", stdout);
            advance();
            continue;
        }

        if (token == PAREN_C) {
            return;
        }

        if (token == EOS && *sp2 == EOS)
            return;

        token = -token;
        if (5 * (*sp2) + token > 24)
            fputs("Inv (3)\n", stdout);
        relate = rel[5 * *sp2 + token];
        if (relate == NONE) {
            fputs("Inv (4)\n", stdout);
            return;
        }
        if (relate != RIGH) {
            push2(token);
            advance();
        } else {
            do {
                token = pop2();
                eval(token);
            } while (!(rel[5 * *sp2 + token] == LEFT));
        }
    }
}

void eval(int tok)
{
    int x1;
    outline("Evaluating ", tok);
    switch (tok) {
    case EOS:
        fputs("Evaluate end of string?\n", stdout);
        return;
    case PLUS:
        push1(pop1() + pop1());
        return;
    case MINUS:
        x1 = pop1();
        push1(pop1() - x1);
        return;
    case TIMES:
        push1(pop1() * pop1());
        return;
    case DIVIDE:
        x1 = pop1();
        push1(pop1() / x1);
        return;
    default:
        outline("Cannot execute token ", tok);
    }
}

void advance(void)
{
    if (*ip == EOS) {
        fputs("Can't advance past EOS\n", stdout);
        return;
    }
    ++ip;
}
