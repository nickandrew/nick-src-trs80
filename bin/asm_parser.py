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
        | "*MOD"
        | std_line
        | TABS com TABS sq_string
        | TABS err TABS sq_string
        | TABS pseudo_op_else TABS? comment?
        | TABS pseudo_op_end TABS symbol TABS? comment?
        | TABS pseudo_op_if TABS expression TABS? comment?
        | TABS pseudo_op_ifdef TABS symbol TABS? comment?
        | TABS pseudo_op_ifndef TABS symbol TABS? comment?
        | TABS pseudo_op_ifref TABS symbol TABS? comment?
        | endif_line

    std_line : (label colon?)? TABS instruction TABS? comment?
    get_line: star_get TABS filename TABS? comment?
    endif_line: TABS pseudo_op_endif TABS? comment?

    expression: add_expr

    add_expr: mul_expr
        | add_expr eop_plus mul_expr
        | add_expr eop_minus mul_expr
        | add_expr eop_xor mul_expr       // Not sure of precedence of .XOR.
        | add_expr eop_and mul_expr       // Not sure of precedence of .AND.
        | add_expr eop_eq mul_expr        // Not sure of precedence of .EQ.

    mul_expr: unary_expr
        | mul_expr eop_times unary_expr
        | mul_expr eop_divide unary_expr

    unary_expr: eop_uminus primary_expr
        | eop_uplus primary_expr
        | eop_not primary_expr
        | primary_expr

    !primary_expr: hexnumber
        | number
        | symbol
        | "$"
        | "(" expression ")"
        | macro_arg
        | character_string

    !instruction : org
        | adc_instruction
        | add_instruction
        | "AND" TABS op15
        | bit_instruction
        | call_instruction
        | "CCF"
        | op_cp TABS op15
        | op_cpir
        | op_cpl
        | op_daa
        | "DC" TABS expression "," expression
        | dec_instruction
        | pseudo_op_db TABS defb_args ("," defb_args)*
        | pseudo_op_defb TABS defb_args ("," defb_args)*
        | pseudo_op_defm TABS defm_args ("," defm_args)*
        | pseudo_op_dm TABS defm_args ("," defm_args)*
        | pseudo_op_defw TABS defw_args ("," defw_args)*
        | pseudo_op_dw TABS defw_args ("," defw_args)*
        | pseudo_op_defs TABS expression
        | pseudo_op_ds TABS expression
        | op_di
        | "DJNZ" TABS expression
        | op_ei
        | "ENDM"                     // TODO
        | op_exx
        | op_ex TABS ex_args
        | op_halt
        | op_im TABS im_args
        | op_in TABS reg_a "," "(" expression ")"
        | inc_instruction
        | jump_instruction
        | load_instruction
        | op_lddr
        | op_ldir
        | "MACRO" (TABS /.+/)?       // TODO
        | op_neg
        | op_nop
        | "OR" TABS op15
        | op_out TABS out_args
        | pop_instruction
        | push_instruction
        | "RES" TABS expression "," op10
        | "RET" (TABS flag)?
        | op_rst TABS expression
        | "SET" TABS expression "," op10
        | "SBC" TABS sbc_args
        | op_rla
        | op_rlca
        | op_rlc TABS op10
        | op_rl TABS op10
        | op_rra
        | op_rrca
        | op_rrc TABS op10
        | op_rr TABS op10
        | op_scf
        | op_sla TABS op10
        | op_sra TABS op10
        | op_srl TABS op10
        | "SUB" TABS op15
        | "XOR" TABS op15

    add_instruction: op_add TABS reg_a "," op15
        | op_add TABS (reg_hl | reg_ix | reg_iy) "," (reg_bc | reg_de | reg_sp)
        | op_add TABS reg_hl "," reg_hl
        | op_add TABS reg_ix "," reg_ix
        | op_add TABS reg_iy "," reg_iy

    org: "ORG" TABS expression

    // ADC A,(A|B|C|D|E|H|L|IXH|IXL|IYH|IYL)
    // ADC A,int8
    // ADC A,(HL) or (IX+n) or (IY+n)
    // ADC HL,(BC|DE|HL|SP)
    adc_instruction: op_adc TABS reg_a "," op15
        | op_adc TABS reg_hl "," (reg_bc | reg_de | reg_hl | reg_sp)

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

    dec_instruction: op_dec TABS op14
        | op_dec TABS (reg_bc | reg_de | reg_hl | reg_sp | reg_ix | reg_iy)

    defb_args: sq_string
        | expression
        | character_string

    defm_args: sq_string
        | expression
        | character_string

    defw_args: expression

    ex_args: reg_af "," reg_afp
        | reg_de "," reg_hl
        | ind_sp "," (reg_hl | reg_ix | reg_iy)

    im_args: im_zero | im_one | im_two
    im_zero: "0"
    im_one:  "1"
    im_two:  "2"

    inc_instruction: op_inc TABS op14
        | op_inc TABS (reg_bc | reg_de | reg_hl | reg_sp | reg_ix | reg_iy)

    !op10: reg_a | reg_b | reg_c | reg_d | reg_e | reg_h | reg_l
        | ind_hl
        | ind_index

    !op14: op10
        | reg_ixh | reg_ixl | reg_iyh | reg_iyl

    !op15: op14
        | expression

    colon: ":"
    equ: "EQU"
    on: "ON"
    off: "OFF"

    reg_a:   "A"
    reg_b:   "B"
    reg_c:   "C"
    reg_d:   "D"
    reg_e:   "E"
    reg_h:   "H"
    reg_l:   "L"
    reg_af:  "AF"
    reg_afp: "AF'"
    reg_bc:  "BC"
    reg_de:  "DE"
    reg_hl:  "HL"
    reg_sp:  "SP"
    reg_ix:  "IX"
    reg_iy:  "IY"
    reg_ixh: "IXH"
    reg_ixl: "IXL"
    reg_iyh: "IYH"
    reg_iyl: "IYL"

    ind_bc: "(BC)"
    ind_de: "(DE)"
    ind_hl: "(HL)"
    ind_sp: "(SP)"
    ind_index: "(" (reg_ix | reg_iy) ((eop_uplus | eop_uminus) expression)? ")"

    flag_z:  "Z"
    flag_nz: "NZ"
    flag_c:  "C"
    flag_nc: "NC"
    flag_m:  "M"
    flag_p:  "P"
    flag_pe: "PE"
    flag_po: "PO"

    // Pseudo-Opcodes
    pseudo_op_db:     "DB"
    pseudo_op_defb:   "DEFB"
    pseudo_op_defm:   "DEFM"
    pseudo_op_defs:   "DEFS"
    pseudo_op_defw:   "DEFW"
    pseudo_op_dm:     "DM"
    pseudo_op_ds:     "DS"
    pseudo_op_dw:     "DW"
    pseudo_op_else:   "ELSE"
    pseudo_op_end:    "END"
    pseudo_op_endif:  "ENDIF"
    pseudo_op_if:     "IF"
    pseudo_op_ifdef:  "IFDEF"
    pseudo_op_ifndef: "IFNDEF"
    pseudo_op_ifref:  "IFREF"

    // Opcodes
    op_adc:  "ADC"
    op_add:  "ADD"
    op_cp:   "CP"
    op_cpir: "CPIR"
    op_cpl:  "CPL"
    op_daa:  "DAA"
    op_dec:  "DEC"
    op_di:   "DI"
    op_ei:   "EI"
    op_ex:   "EX"
    op_exx:  "EXX"
    op_halt: "HALT"
    op_im:   "IM"
    op_in:   "IN"
    op_inc:  "INC"
    op_jp:   "JP"
    op_jr:   "JR"
    op_lddr: "LDDR"
    op_ldir: "LDIR"
    op_ld:   "LD"
    op_neg:  "NEG"
    op_nop:  "NOP"
    op_out:  "OUT"
    op_rla:  "RLA"
    op_rlca: "RLCA"
    op_rlc:  "RLC"
    op_rl:   "RL"
    op_rra:  "RRA"
    op_rrca: "RRCA"
    op_rrc:  "RRC"
    op_rst:  "RST"
    op_rr:   "RR"
    op_scf:  "SCF"
    op_sla:  "SLA"
    op_sra:  "SRA"
    op_srl:  "SRL"

    // Expression operations
    eop_and:    ".AND."
    eop_divide: "/"
    eop_eq:     ".EQ."
    eop_minus:  "-"
    eop_not:    ".NOT."
    eop_plus:   "+"
    eop_times:  "*"
    eop_uminus: "-"
    eop_uplus:  "+"
    eop_xor:    ".XOR."

    // character_string belongs as part of expression
    // What about:   'A'+20H
    // Does it assemble?
    character_string: /'.'/

    jump_instruction: op_jp TABS (flag ",")? expression
        | op_jr TABS (flag ",")? expression

    // load_instruction needs a lot of work
    load_instruction : op_ld TABS register "," register
        | op_ld TABS short_register "," (ind_hl | ind_index)
        | op_ld TABS reg_a "," (ind_bc | ind_de)
        | op_ld TABS register "," expression
        | op_ld TABS ind_hl "," short_register
        | op_ld TABS ind_hl "," expression
        | op_ld TABS "(" expression ")" "," (reg_a | reg_bc | reg_hl | reg_de | reg_sp)
        | op_ld TABS ind_index "," short_register
        | op_ld TABS ind_index "," expression

    pop_instruction: "POP" TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)
    push_instruction: "PUSH" TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)

    // TODO Needs work
    sbc_args: reg_hl "," reg_de
        | reg_hl "," reg_bc
        | reg_a "," expression

    out_args: "(" expression ")" "," reg_a
        | "(" reg_c ")" "," short_register
        | "(" reg_c ")" "," "0"

    contents_of: "(" long_register ")"
    comment: COMMENT
    symbol:   /[A-Z0-9_$]+/
        | /@[A-Z0-9_$]+/           // LDOS @RAMDIR

    filename:   /[A-Z0-9_$]+(\/[A-Z0-9_$]{1,3})?/
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
    err: "ERR"
    sq_string: /'[^']*'/
    defw: "DEFW"
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
