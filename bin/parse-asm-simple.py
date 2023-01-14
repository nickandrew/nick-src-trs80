#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Construct a parse tree of an ASM file."""

import argparse

from lark import Lark, Transformer, v_args
from lark.lexer import Lexer, Token

class TypeLexer(Lexer):
    def __init__(self, lexer_conf):
        pass

    def lex(self, filename):
        with open(filename, 'r') as in_f:
            for line in in_f:
                yield line

grammar = """
    start: (line? LF)+
    line: TABS? comment
        | label TABS? comment?
        | label TABS "DEFL" TABS expression TABS? comment?
        | label TABS "EQU" TABS expression TABS? comment?
        | get_line
        | "*LIST" TABS ("OFF" | "ON")
        | std_line
        | TABS com TABS sq_string
        | TABS "IF" TABS symbol TABS? comment?
        | TABS "IFREF" TABS symbol TABS? comment?
        | ifdef_line
        | endif_line

    std_line : label? TABS instruction TABS? comment?
    get_line: star_get TABS filename comment?
    ifdef_line: TABS "IFDEF" TABS symbol TABS? comment?
    endif_line: TABS "ENDIF" TABS? comment?

    expression: add_expr

    add_expr: mul_expr
        | add_expr "+" mul_expr
        | add_expr "-" mul_expr

    mul_expr: primary_expr
        | mul_expr "*" primary_expr
        | mul_expr "/" primary_expr

    !primary_expr: hexnumber
        | number
        | label
        | "$"
        | "(" expression ")"
        | macro_arg
        | character_string

    !instruction : "LDIR"
        | org
        | adc_instruction
        | add_instruction
        | "AND" TABS op15
        | bit_instruction
        | call_instruction
        | "CCF"
        | "CP" TABS op15
        | "DC" TABS expression "," expression
        | dec_instruction
        | defb_instruction
        | defm_instruction
        | defw_instruction
        | "DEFS" TABS expression
        | "DJNZ" TABS expression
        | "ENDM"                     // TODO
        | ex_instruction
        | inc_instruction
        | jump_instruction
        | load_instruction
        | "MACRO" (TABS /.+/)?       // TODO
        | "OR" TABS op15
        | pop_instruction
        | push_instruction
        | "RES" TABS expression "," op10
        | "RET" (TABS flag)?
        | "SET" TABS expression "," op10
        | "SBC" TABS sbc_args
        | "SUB" TABS op15
        | "XOR" TABS op15

    add_instruction: "ADD" TABS "A" "," op15
        | "ADD" TABS ("HL" | "IX" | "IY") "," ("BC" | "DE" | "SP")
        | "ADD" TABS "HL" "," "HL"
        | "ADD" TABS "IX" "," "IX"
        | "ADD" TABS "IY" "," "IY"

    org: "ORG" TABS expression

    // ADC A,(A|B|C|D|E|H|L|IXH|IXL|IYH|IYL)
    // ADC A,int8
    // ADC A,(HL) or (IX+n) or (IY+n)
    // ADC HL,(BC|DE|HL|SP)
    adc_instruction: "ADC" TABS adc_args
    adc_args: "A,A"
        | "A,C"

    // ADD instruction is like ADC with this addition:
    // ADD (IX|IY),(BC|DE|HL|SP)

    // AND instruction has all the 2nd arguments of ADC, but the "A," is implicit

    // BIT instruction is BIT n,<2nd>
    // n is 0..7
    // 2nd is one of A|B|C|D|E|H|L or (HL) or (IX+n) or (IY+n) -- so no I[XY][HL]

    bit_instruction: "BIT" TABS expression "," op10

    call_instruction: "CALL" TABS (flag ",")? expression

    // CP arguments are identical to AND
    // SUB, AND, OR have identical arguments

    dec_instruction: "DEC" TABS op14
        | "DEC" TABS ("BC" | "DE" | "HL" | "SP" )

    defb_instruction: "DEFB" TABS expression

    defm_instruction: "DEFM" TABS defm_args ("," defm_args)*
    defm_args: sq_string
        | expression
        | character_string

    defw_instruction: "DEFW" TABS expression

    ex_instruction: "EX" TABS ("DE,HL" | "AF,AF'")
        | "EX" TABS "(SP)" "," ("HL" | "IX" | "IY")

    inc_instruction: "INC" TABS op14
        | "INC" TABS ("BC" | "DE" | "HL" | "SP" )

    !op10: "A" | "B" | "C" | "D" | "E" | "H" | "L"
        | "(HL)"
        | "(" "IX" (("+" | "-") expression)? ")"
        | "(" "IY" (("+" | "-") expression)? ")"

    !op14: "A" | "B" | "C" | "D" | "E" | "H" | "L"
        | "IXH" | "IXL" | "IYH" | "IYL"
        | "(HL)"
        | "(" "IX" (("+" | "-") expression)? ")"
        | "(" "IY" (("+" | "-") expression)? ")"

    !op15: op14
        | expression
        | character_string

    // character_string belongs as part of expression
    // What about:   'A'+20H
    // Does it assemble?
    character_string: /'.'/

    jump_instruction: "JP" TABS (flag ",")? expression
        | "JR" TABS (flag ",")? expression

    // load_instruction needs a lot of work
    load_instruction : ld_opcode TABS register "," register
        | ld_opcode TABS register "," expression
        | ld_opcode TABS "(HL)" "," (expression | character_string)
        | ld_opcode TABS "(" expression ")" "," ("A" | "BC" | "HL" | "DE")
        | ld_opcode TABS "(" ("IX" | "IY") (("+" | "-") expression)? ")" "," (expression | character_string)

    pop_instruction: "POP" TABS ("AF" | "BC" | "DE" | "HL" | "IX" | "IY")
    push_instruction: "PUSH" TABS ("AF" | "BC" | "DE" | "HL" | "IX" | "IY")

    // TODO Needs work
    sbc_args: "HL,DE"
        | "HL,BC"

    contents_of: "(" long_register ")"
    comment: COMMENT
    symbol: label

    ld_opcode: "LD"
    filename:   /[A-Z0-9_$]+/
    hexnumber: /[0-9A-F]{1,5}H/
    number:  /-?[0-9]+/
    label:   /[A-Z0-9_$]+/ ":"?
        | /@[A-Z0-9_$]+/ ":"?           // LDOS @RAMDIR

    macro_arg:  /#[A-Z0-9_$]+/

    flag: "Z"
        | "NZ"
        | "C"
        | "NC"
        | "M"
        | "P"
        | "PE"
        | "PO"

    short_register: "A"
        | "B"
        | "C"
        | "D"
        | "E"
        | "H"
        | "L"

    long_register: "AF"
        | "BC"
        | "DE"
        | "HL"
        | "IX"
        | "IY"
        | "SP"

    register: short_register
        | long_register

    com: "COM"
    sq_string: /'[^']*'/
    defw: "DEFW"
    ldir: "LDIR"
    star_get: "*GET"

    // Terminals

    COMMENT: /;.*/
    TABS: /\t+/

    %import common.INT    -> INT
    %import common.LF -> LF

    // %import common.WS
    // %ignore WS

"""

def lex_file(filename):
    """Just run the lexical analyser on the file. No grammar."""
    parser = Lark(grammar, parser='earley')
    with open(filename, 'r') as in_f:
        print('Lexing only')
        lexer = parser.lex(in_f.read())

    for token in lexer:
        print(f'{repr(token)}')

def parse_file(filename):
    parser = Lark(grammar, parser='earley')
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())
    print(tree.pretty())

def parse_args():
    p = argparse.ArgumentParser(description='Parse ASM source files')
    p.add_argument('--lex', action='store_true', help='Do lexical analysis only')
    p.add_argument('filename', help='Filename to parse')
    return p.parse_args()

def main():
    args = parse_args()
    if args.filename:
        if args.lex:
            lex_file(args.filename)
        else:
            parse_file(args.filename)

if __name__ == '__main__':
    main()
