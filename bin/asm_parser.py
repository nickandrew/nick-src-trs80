#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Construct a parse tree of an ASM file."""

from lark import Lark, Transformer, v_args
from lark.lexer import Lexer, Token

grammar = """
    start: line+
    line: TABS? comment LF
        | label colon? TABS? comment? LF
        | label colon? TABS pseudo_op_defl TABS expression TABS? comment? LF
        | label TABS equ TABS expression TABS? comment? LF
        | get_line LF
        | "*LIST" TABS (on | off) LF
        | star_mod LF
        | std_line LF
        | TABS com TABS sq_string LF
        | TABS err TABS sq_string LF
        | TABS pseudo_op_else TABS? comment? LF
        | TABS pseudo_op_end TABS expression TABS? comment? LF
        | TABS pseudo_op_if TABS expression TABS? comment? LF
        | TABS pseudo_op_ifdef TABS symbol TABS? comment? LF
        | TABS pseudo_op_ifndef TABS symbol TABS? comment? LF
        | TABS pseudo_op_ifref TABS symbol TABS? comment? LF
        | TABS pseudo_op_page TABS? comment? LF
        | TABS pseudo_op_subttl TABS? /.+/ LF
        | TABS pseudo_op_title TABS? /.+/ LF
        | endif_line LF
        | LF

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
        | add_expr eop_gt mul_expr        // Not sure of precedence of .GT.
        | add_expr eop_shleft mul_expr    // Not sure of precedence of .SHL.

    mul_expr: unary_expr
        | mul_expr eop_times unary_expr
        | mul_expr eop_divide unary_expr

    unary_expr: eop_uminus primary_expr
        | eop_uplus primary_expr
        | eop_not primary_expr
        | primary_expr

    !primary_expr: hexnumber
        | chexnumber
        | binary_number
        | octal_number
        | number
        | symbol
        | "$"
        | "(" expression ")"
        | macro_arg
        | sq_string

    !instruction : org
        | op_adc TABS adc_args
        | op_add TABS add_args
        | op_and TABS op15
        | op_bit TABS bit_args
        | call_instruction
        | op_ccf
        | op_cp TABS op15
        | op_cpir
        | op_cpl
        | op_daa
        | pseudo_op_dc TABS expression "," expression
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
        | op_djnz TABS expression
        | op_ei
        | pseudo_op_endm                     // TODO
        | op_exx
        | op_ex TABS ex_args
        | op_halt
        | op_im TABS im_args
        | op_in TABS reg_a "," "(" expression ")"
        | op_inc TABS inc_args
        | op_jp TABS jp_args
        | op_jr TABS jr_args
        | op_ld TABS ld_args
        | op_lddr
        | op_ldir
        | pseudo_op_macro (TABS /.+/)?       // TODO
        | op_neg
        | op_nop
        | op_or TABS op15
        | op_out TABS out_args
        | pop_instruction
        | push_instruction
        | op_res TABS expression "," op10
        | op_ret (TABS flag)?
        | op_rst TABS expression
        | op_set TABS expression "," op10
        | op_sbc TABS sbc_args
        | op_rla
        | op_rlca
        | op_rlc TABS op10
        | op_rld
        | op_rl TABS op10
        | op_rra
        | op_rrca
        | op_rrc TABS op10
        | op_rr TABS op10
        | op_scf
        | op_sla TABS op10
        | op_sra TABS op10
        | op_srl TABS op10
        | op_sub TABS op15
        | op_xor TABS op15

    add_args: reg_a "," op15
        | (reg_hl | reg_ix | reg_iy) "," (reg_bc | reg_de | reg_sp)
        | reg_hl "," reg_hl
        | reg_ix "," reg_ix
        | reg_iy "," reg_iy

    org: pseudo_op_org TABS expression

    // ADC A,(A|B|C|D|E|H|L|IXH|IXL|IYH|IYL)
    // ADC A,int8
    // ADC A,(HL) or (IX+n) or (IY+n)
    // ADC HL,(BC|DE|HL|SP)
    adc_args: reg_a "," op15
        | reg_hl "," (reg_bc | reg_de | reg_hl | reg_sp)

    // ADD instruction is like ADC with this addition:
    // ADD (IX|IY),(BC|DE|HL|SP)

    // AND instruction has all the 2nd arguments of ADC, but the "A," is implicit

    // BIT instruction is BIT n,<2nd>
    // n is 0..7
    // 2nd is one of A|B|C|D|E|H|L or (HL) or (IX+n) or (IY+n) -- so no I[XY][HL]

    bit_args: expression "," op10

    call_instruction: op_call TABS (flag ",")? expression

    // CP arguments are identical to AND
    // SUB, AND, OR have identical arguments

    dec_instruction: op_dec TABS op14
        | op_dec TABS (reg_bc | reg_de | reg_hl | reg_sp | reg_ix | reg_iy)

    defb_args: expression

    defm_args: expression

    defw_args: expression

    ex_args: reg_af "," reg_afp
        | reg_de "," reg_hl
        | ind_sp "," (reg_hl | reg_ix | reg_iy)

    im_args: im_zero | im_one | im_two
    im_zero: "0"
    im_one:  "1"
    im_two:  "2"

    inc_args: op14
        | (reg_bc | reg_de | reg_hl | reg_sp | reg_ix | reg_iy)

    ?short_register: reg_a | reg_b | reg_c | reg_d | reg_e | reg_h | reg_l

    ?long_register: reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy | reg_sp

    ?register: short_register | long_register

    ?op10: reg_a | reg_b | reg_c | reg_d | reg_e | reg_h | reg_l
        | ind_hl
        | ind_index

    ?op14: op10
        | reg_ixh | reg_ixl | reg_iyh | reg_iyl

    ?op15: op14
        | expression

    colon: ":"
    equ:    "EQU" | equ_lc
    equ_lc:   "equ"
    on:     "ON" | on_lc
    on_lc:    "on"
    off:    "OFF" | off_lc
    off_lc:   "off"

    reg_a:      "A" | reg_a_lc
    reg_a_lc:     "a"
    reg_b:      "B" | reg_b_lc
    reg_b_lc:     "b"
    reg_c:      "C" | reg_c_lc
    reg_c_lc:     "c"
    reg_d:      "D" | reg_d_lc
    reg_d_lc:     "d"
    reg_e:      "E" | reg_e_lc
    reg_e_lc:     "e"
    reg_h:      "H" | reg_h_lc
    reg_h_lc:     "h"
    reg_l:      "L" | reg_l_lc
    reg_l_lc:     "l"
    reg_af:     "AF" | reg_af_lc
    reg_af_lc:    "af"
    reg_afp:    "AF'" | reg_afp_lc
    reg_afp_lc:   "af'"
    reg_bc:     "BC" | reg_bc_lc
    reg_bc_lc:    "bc"
    reg_de:     "DE" | reg_de_lc
    reg_de_lc:    "de"
    reg_hl:     "HL" | reg_hl_lc
    reg_hl_lc:    "hl"
    reg_sp:     "SP" | reg_sp_lc
    reg_sp_lc:    "sp"
    reg_ix:     "IX" | reg_ix_lc
    reg_ix_lc:    "ix"
    reg_iy:     "IY" | reg_iy_lc
    reg_iy_lc:    "iy"
    reg_ixh:    "IXH" | reg_ixh_lc
    reg_ixh_lc:   "ixh"
    reg_ixl:    "IXL" | reg_ixl_lc
    reg_ixl_lc:   "ixl"
    reg_iyh:    "IYH" | reg_iyh_lc
    reg_iyh_lc:   "iyh"
    reg_iyl:    "IYL" | reg_iyl_lc
    reg_iyl_lc:   "iyl"

    ind_bc:     "(BC)" | ind_bc_lc
    ind_bc_lc:    "(bc)"
    ind_de:     "(DE)" | ind_de_lc
    ind_de_lc:    "(de)"
    ind_hl:     "(HL)" | ind_hl_lc
    ind_hl_lc:    "(hl)"
    ind_ix:     "(IX)" | ind_ix_lc
    ind_ix_lc:    "(ix)"
    ind_iy:     "(IY)" | ind_iy_lc
    ind_iy_lc:    "(iy)"
    ind_sp:     "(SP)" | ind_sp_lc
    ind_sp_lc:    "(sp)"

    ind_index: "(" (reg_ix | reg_iy) ((eop_uplus | eop_uminus) expression)? ")"

    flag_z:     "Z" | flag_z_lc
    flag_z_lc:    "z"
    flag_nz:    "NZ" | flag_nz_lc
    flag_nz_lc:   "nz"
    flag_c:     "C" | flag_c_lc
    flag_c_lc:    "c"
    flag_nc:    "NC" | flag_nc_lc
    flag_nc_lc:   "nc"
    flag_m:     "M" | flag_m_lc
    flag_m_lc:    "m"
    flag_p:     "P" | flag_p_lc
    flag_p_lc:    "p"
    flag_pe:    "PE" | flag_pe_lc
    flag_pe_lc:   "pe"
    flag_po:    "PO" | flag_po_lc
    flag_po_lc:   "po"

    // Pseudo-Opcodes
    pseudo_op_db:        "DB" | pseudo_op_db_lc
    pseudo_op_db_lc:       "db"
    pseudo_op_dc:        "DC" | pseudo_op_dc_lc
    pseudo_op_dc_lc:       "dc"
    pseudo_op_defb:      "DEFB" | pseudo_op_defb_lc
    pseudo_op_defb_lc:     "defb"
    pseudo_op_defl:      "DEFL" | pseudo_op_defl_lc
    pseudo_op_defl_lc:     "defl"
    pseudo_op_defm:      "DEFM" | pseudo_op_defm_lc
    pseudo_op_defm_lc:     "defm"
    pseudo_op_defs:      "DEFS" | pseudo_op_defs_lc
    pseudo_op_defs_lc:     "defs"
    pseudo_op_defw:      "DEFW" | pseudo_op_defw_lc
    pseudo_op_defw_lc:     "defw"
    pseudo_op_dm:        "DM" | pseudo_op_dm_lc
    pseudo_op_dm_lc:       "dm"
    pseudo_op_ds:        "DS" | pseudo_op_ds_lc
    pseudo_op_ds_lc:       "ds"
    pseudo_op_dw:        "DW" | pseudo_op_dw_lc
    pseudo_op_dw_lc:       "dw"
    pseudo_op_else:      "ELSE" | pseudo_op_else_lc
    pseudo_op_else_lc:     "else"
    pseudo_op_end:       "END" | pseudo_op_end_lc
    pseudo_op_end_lc:      "end"
    pseudo_op_endif:     "ENDIF" | pseudo_op_endif_lc
    pseudo_op_endif_lc:    "endif"
    pseudo_op_endm:      "ENDM" | pseudo_op_endm_lc
    pseudo_op_endm_lc:     "endm"
    pseudo_op_if:        "IF" | pseudo_op_if_lc
    pseudo_op_if_lc:       "if"
    pseudo_op_ifdef:     "IFDEF" | pseudo_op_ifdef_lc
    pseudo_op_ifdef_lc:    "ifdef"
    pseudo_op_ifndef:    "IFNDEF" | pseudo_op_ifndef_lc
    pseudo_op_ifndef_lc:   "ifndef"
    pseudo_op_ifref:     "IFREF" | pseudo_op_ifref_lc
    pseudo_op_ifref_lc:    "ifref"
    pseudo_op_macro:     "MACRO" | pseudo_op_macro_lc
    pseudo_op_macro_lc:    "macro"
    pseudo_op_org:       "ORG" | pseudo_op_org_lc
    pseudo_op_org_lc:      "org"
    pseudo_op_page:      "PAGE" | pseudo_op_page_lc
    pseudo_op_page_lc:     "page"
    pseudo_op_subttl:    "SUBTTL" | pseudo_op_subttl_lc
    pseudo_op_subttl_lc:   "subttl"
    pseudo_op_title:     "TITLE" | pseudo_op_title_lc
    pseudo_op_title_lc:    "title"

    // Opcodes
    op_adc:     "ADC" | op_adc_lc
    op_adc_lc:    "adc"
    op_add:     "ADD" | op_add_lc
    op_add_lc:    "add"
    op_and:     "AND" | op_and_lc
    op_and_lc:    "and"
    op_bit:     "BIT" | op_bit_lc
    op_bit_lc:    "bit"
    op_call:    "CALL" | op_call_lc
    op_call_lc:   "call"
    op_ccf:     "CCF" | op_ccf_lc
    op_ccf_lc:    "ccf"
    op_cp:      "CP" | op_cp_lc
    op_cp_lc:     "cp"
    op_cpir:    "CPIR" | op_cpir_lc
    op_cpir_lc:   "cpir"
    op_cpl:     "CPL" | op_cpl_lc
    op_cpl_lc:    "cpl"
    op_daa:     "DAA" | op_daa_lc
    op_daa_lc:    "daa"
    op_dec:     "DEC" | op_dec_lc
    op_dec_lc:    "dec"
    op_di:      "DI" | op_di_lc
    op_di_lc:     "di"
    op_djnz:    "DJNZ" | op_djnz_lc
    op_djnz_lc:   "djnz"
    op_ei:      "EI" | op_ei_lc
    op_ei_lc:     "ei"
    op_ex:      "EX" | op_ex_lc
    op_ex_lc:     "ex"
    op_exx:     "EXX" | op_exx_lc
    op_exx_lc:    "exx"
    op_halt:    "HALT" | op_halt_lc
    op_halt_lc:   "halt"
    op_im:      "IM" | op_im_lc
    op_im_lc:     "im"
    op_in:      "IN" | op_in_lc
    op_in_lc:     "in"
    op_inc:     "INC" | op_inc_lc
    op_inc_lc:    "inc"
    op_jp:      "JP" | op_jp_lc
    op_jp_lc:     "jp"
    op_jr:      "JR" | op_jr_lc
    op_jr_lc:     "jr"
    op_ld:      "LD" | op_ld_lc
    op_ld_lc:     "ld"
    op_lddr:    "LDDR" | op_lddr_lc
    op_lddr_lc:   "lddr"
    op_ldir:    "LDIR" | op_ldir_lc
    op_ldir_lc:   "ldir"
    op_neg:     "NEG" | op_neg_lc
    op_neg_lc:    "neg"
    op_nop:     "NOP" | op_nop_lc
    op_nop_lc:    "nop"
    op_or:      "OR" | op_or_lc
    op_or_lc:     "or"
    op_out:     "OUT" | op_out_lc
    op_out_lc:    "out"
    op_pop:     "POP" | op_pop_lc
    op_pop_lc:    "pop"
    op_push:    "PUSH" | op_push_lc
    op_push_lc:   "push"
    op_res:     "RES" | op_res_lc
    op_res_lc:    "res"
    op_ret:     "RET" | op_ret_lc
    op_ret_lc:    "ret"
    op_rl:      "RL" | op_rl_lc
    op_rl_lc:     "rl"
    op_rla:     "RLA" | op_rla_lc
    op_rla_lc:    "rla"
    op_rlc:     "RLC" | op_rlc_lc
    op_rlc_lc:    "rlc"
    op_rlca:    "RLCA" | op_rlca_lc
    op_rlca_lc:   "rlca"
    op_rld:     "RLD" | op_rld_lc
    op_rld_lc:    "rld"
    op_rr:      "RR" | op_rr_lc
    op_rr_lc:     "rr"
    op_rra:     "RRA" | op_rra_lc
    op_rra_lc:    "rra"
    op_rrc:     "RRC" | op_rrc_lc
    op_rrc_lc:    "rrc"
    op_rrca:    "RRCA" | op_rrca_lc
    op_rrca_lc:   "rrca"
    op_rst:     "RST" | op_rst_lc
    op_rst_lc:    "rst"
    op_sbc:     "SBC" | op_sbc_lc
    op_sbc_lc:    "sbc"
    op_scf:     "SCF" | op_scf_lc
    op_scf_lc:    "scf"
    op_set:     "SET" | op_set_lc
    op_set_lc:    "set"
    op_sla:     "SLA" | op_sla_lc
    op_sla_lc:    "sla"
    op_sra:     "SRA" | op_sra_lc
    op_sra_lc:    "sra"
    op_srl:     "SRL" | op_srl_lc
    op_srl_lc:    "srl"
    op_sub:     "SUB" | op_sub_lc
    op_sub_lc:    "sub"
    op_xor:     "XOR" | op_xor_lc
    op_xor_lc:    "xor"

    // Expression operations
    eop_and:       ".AND." | eop_and_lc
    eop_and_lc:      ".and."
    eop_divide:     "/"
    eop_eq:        ".EQ." | eop_eq_lc
    eop_eq_lc:       ".eq."
    eop_gt:        ".GT." | eop_gt_lc
    eop_gt_lc:       ".gt."
    eop_minus:     "-"
    eop_not:       ".NOT." | eop_not_lc
    eop_not_lc:      ".not."
    eop_plus:      "+"
    eop_shleft:    ".SHL." | eop_shleft_lc
    eop_shleft_lc:   ".shl."
    eop_times:     "*"
    eop_uminus:    "-"
    eop_uplus:     "+"
    eop_xor:       ".XOR." | eop_xor_lc
    eop_xor_lc:      ".xor."

    jp_args: (ind_hl | ind_ix | ind_iy)
        | (flag ",")? expression

    jr_args: (flag ",")? expression

    // ld_args needs a lot of work
    ld_args : register "," register
        | short_register "," (ind_hl | ind_index)
        | reg_a "," (ind_bc | ind_de)
        | (ind_bc | ind_de) "," reg_a
        | (ind_hl | ind_index) "," short_register
        | register "," expression
        | ind_hl "," expression
        | "(" expression ")" "," (reg_a | reg_bc | reg_hl | reg_de | reg_ix | reg_iy | reg_sp)
        | ind_index "," expression

    pop_instruction: op_pop TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)
    push_instruction: op_push TABS (reg_af | reg_bc | reg_de | reg_hl | reg_ix | reg_iy)

    // TODO Needs work
    sbc_args: reg_a "," op15
        | reg_hl "," (reg_bc | reg_de | reg_hl | reg_sp)

    out_args: "(" reg_c ")" "," short_register
        | "(" reg_c ")" "," "0"
        | "(" expression ")" "," reg_a

    contents_of: "(" long_register ")"
    comment: COMMENT
    label:    /[A-Z_$@][A-Z0-9_$@?]{0,45}/i     // A label cannot start with a number
    symbol:   /[A-Z_$@][A-Z0-9_$@?]{0,45}/i     // A symbol cannot start with a number

    filename:   /[A-Z0-9_$]+(\/[A-Z0-9_$]{1,3})?/i
    hexnumber: /[0-9A-F]{1,5}H/i
    chexnumber: /0x[0-9A-F]+/i
    binary_number: /[01]{8}B/i
    octal_number: /[0-7]{1,7}O/i
    number:  /-?[0-9]+/

    macro_arg:  /#[A-Z0-9_$]+/

    flag: flag_z | flag_nz | flag_c | flag_nc | flag_m | flag_p | flag_pe | flag_po

    com:         "COM" | com_lc
    com_lc:        "com"
    err:         "ERR" | err_lc
    err_lc:        "err"
    star_get:    "*GET" | star_get_lc
    star_get_lc:   "*get"
    star_mod:    "*MOD" | star_mod_lc
    star_mod_lc:   "*mod"

    sq_string: /'((?:''|[^'])*)'/

    // Terminals

    COMMENT: /;.*/
    TABS: /\t+/

    %import common.INT    -> INT
    %import common.LF -> LF

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
