#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Construct a parse tree of an ASM file."""

from lark import Lark, Transformer, v_args
from lark.lexer import Lexer, Token

grammar = """
    start: (line? LF)+
    line: TABS? comment
        | label colon? TABS? comment?
        | label colon? TABS "DEFL" TABS expression TABS? comment?
        | label TABS equ TABS expression TABS? comment?
        | get_line
        | "*LIST" TABS (on | off)
        | std_line
        | TABS com TABS sq_string
        | TABS pseudo_op_if TABS symbol TABS? comment?
        | TABS pseudo_op_ifref TABS symbol TABS? comment?
        | ifdef_line
        | endif_line

    std_line : (label colon?)? TABS instruction TABS? comment?
    get_line: star_get TABS filename comment?
    ifdef_line: TABS pseudo_op_ifdef TABS symbol TABS? comment?
    endif_line: TABS pseudo_op_endif TABS? comment?

    expression: add_expr

    add_expr: mul_expr
        | add_expr eop_plus mul_expr
        | add_expr eop_minus mul_expr

    mul_expr: primary_expr
        | mul_expr eop_times primary_expr
        | mul_expr eop_divide primary_expr

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

    add_instruction: "ADD" TABS reg_a "," op15
        | "ADD" TABS (reg_hl | reg_ix | reg_iy) "," (reg_bc | reg_de | reg_sp)
        | "ADD" TABS reg_hl "," reg_hl
        | "ADD" TABS reg_ix "," reg_ix
        | "ADD" TABS reg_iy "," reg_iy

    org: "ORG" TABS expression

    // ADC A,(A|B|C|D|E|H|L|IXH|IXL|IYH|IYL)
    // ADC A,int8
    // ADC A,(HL) or (IX+n) or (IY+n)
    // ADC HL,(BC|DE|HL|SP)
    adc_instruction: op_adc TABS adc_args
    adc_args: reg_a "," reg_a
        | reg_a "," reg_c

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
        | "DEC" TABS (reg_bc | reg_de | reg_hl | reg_sp )

    defb_instruction: "DEFB" TABS expression

    defm_instruction: "DEFM" TABS defm_args ("," defm_args)*
    defm_args: sq_string
        | expression
        | character_string

    defw_instruction: "DEFW" TABS expression

    ex_instruction: "EX" TABS ("DE,HL" | "AF,AF'")
        | "EX" TABS "(SP)" "," (reg_hl | reg_ix | reg_iy)

    inc_instruction: "INC" TABS op14
        | "INC" TABS (reg_bc | reg_de | reg_hl | reg_sp )

    !op10: reg_a | reg_b | reg_c | reg_d | reg_e | reg_h | reg_l
        | ind_hl
        | "(" reg_ix (("+" | "-") expression)? ")"
        | "(" reg_iy (("+" | "-") expression)? ")"

    !op14: "A" | "B" | "C" | "D" | "E" | "H" | "L"
        | reg_ixh | reg_ixl | reg_iyh | reg_iyl
        | ind_hl
        | "(" reg_ix (("+" | "-") expression)? ")"
        | "(" reg_iy (("+" | "-") expression)? ")"

    !op15: op14
        | expression
        | character_string

    colon: ":"
    equ: "EQU"
    on: "ON"
    off: "OFF"
    reg_a: "A"
    reg_b: "B"
    reg_c: "C"
    reg_d: "D"
    reg_e: "E"
    reg_h: "H"
    reg_l: "L"
    reg_af: "AF"
    reg_bc: "BC"
    reg_de: "DE"
    reg_hl: "HL"
    reg_sp: "SP"
    reg_ix: "IX"
    reg_iy: "IY"
    reg_ixh: "IXH"
    reg_ixl: "IXL"
    reg_iyh: "IYH"
    reg_iyl: "IYL"
    ind_hl: "(HL)"

    flag_z:  "Z"
    flag_nz: "NZ"
    flag_c:  "C"
    flag_nc: "NC"
    flag_m:  "M"
    flag_p:  "P"
    flag_pe: "PE"
    flag_po: "PO"

    // Pseudo-Opcodes
    pseudo_op_endif: "ENDIF"
    pseudo_op_if:    "IF"
    pseudo_op_ifdef: "IFDEF"
    pseudo_op_ifref: "IFREF"

    // Opcodes
    op_adc:  "ADC"
    op_jr:   "JR"
    op_jp:   "JP"
    op_ld:   "LD"

    // Expression operations
    eop_plus:   "+"
    eop_minus:  "-"
    eop_times:  "*"
    eop_divide: "/"

    // character_string belongs as part of expression
    // What about:   'A'+20H
    // Does it assemble?
    character_string: /'.'/

    jump_instruction: op_jp TABS (flag ",")? expression
        | op_jr TABS (flag ",")? expression

    // load_instruction needs a lot of work
    load_instruction : op_ld TABS register "," register
        | op_ld TABS register "," expression
        | op_ld TABS ind_hl "," expression
        | op_ld TABS "(" expression ")" "," (reg_a | reg_bc | reg_hl | reg_de)
        | op_ld TABS "(" ("IX" | "IY") (("+" | "-") expression)? ")" "," expression

    pop_instruction: "POP" TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)
    push_instruction: "PUSH" TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)

    // TODO Needs work
    sbc_args: reg_hl "," reg_de
        | reg_hl "," reg_bc

    contents_of: "(" long_register ")"
    comment: COMMENT
    symbol: label

    filename:   /[A-Z0-9_$]+/
    hexnumber: /[0-9A-F]{1,5}H/
    number:  /-?[0-9]+/
    label:   /[A-Z0-9_$]+/
        | /@[A-Z0-9_$]+/           // LDOS @RAMDIR

    macro_arg:  /#[A-Z0-9_$]+/

    flag: flag_z | flag_nz | flag_c | flag_nc | flag_m | flag_p | flag_pe | flag_po

    short_register: reg_a | reg_b | reg_c | reg_d | reg_e | reg_h | reg_l

    long_register: reg_af
        | reg_bc
        | reg_de
        | reg_hl
        | reg_ix
        | reg_iy
        | reg_sp

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

class ASMParser(object):
    def __init__(self):
        self.parser = Lark(grammar, parser='earley', maybe_placeholders=False)
        self.tree = None

    def parse(self, data: str):
        self.tree = self.parser.parse(data)

        return self.tree

    def lex(self, data: str):
        tokens = self.parser.lex(data)

        return tokens
