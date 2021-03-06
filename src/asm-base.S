@ asm-base.S - words that generate inline assembly ie arm thumb instructions

@ ( -- )
@ compile assembler pop {pc}
Forthword_ POPPC, 0, "_poppc"
  lit_ 0xbd00
  end_

@ ( -- )
@ compile assembler push {lr}
Forthword_ PUSHLR, 0, "_pushlr"
  lit_ 0xb500
  end_

@ ( -- )
@ compile assembler bx lr
Forthword_ BXLR, 0, "_bxlr"
  lit_ 0x4770
  end_

@ no operation
@ ( -- )
Forthword_ NOP, 0, "_nop"
  @compile nop : 0x46C0
  lit_ 0x46C0
  end_

@ calc relative distance in half word alignment
@ ( dest start  -- distance )
Forthword_ RELDST, 0, "reldst"
  @ calculate relative distance in half words from start to dest
  @ rel dist = dest - start
  @ account for 3 stage pipeline
  add_4_               @ ( dest start+4 )
  y_w_                 @ ( dest start+4 ) Y:start+4
  d_                   @ ( dest )
  sub_y_               @ ( dest-start+4 ) 
  div_2_               @ ( dist/2 )
  end_

@ build assembler instruction b - unconditional short branch
@ ( reldist -- branchinst )
@ reldist: relative distance as 2's compliment
Forthword_ BRANCH, 0, "_b.n"
  @ 1110 0XXX XXXX XXXX
  movs tmp1, #7
  lsls tmp1, #8
  adds tmp1, #0xFF
  ands wreg, tmp1
  movs tmp1, #0x07
  lsls tmp1, #13
  orrs wreg, tmp1
  end_

@ compile assembler instruction unconditional branch
@ ( reldist -- )
@ reldist: relative distance as 2's compliment
Forthword_ GOTOC, 0, "goto,"
  do_ BRANCH
  end_do_ COMMA

@ compile branch at start address
@ ( start dest -- )
Forthword_ GOTOS, 0, "gotos"
  d_w_                 @ ( start dest dest )
  d1_                  @ ( start dest start )
  do_ RELDST           @ ( start reldst )
  do_ BRANCH           @ ( start branchinst )
  y_d_                 @ ( branchinst ) Y:start
  hmy_w_
  end_                 @ ( branchinst )

@ compile call at start address
@ ( dist -- )
@ dist: 2's compliment half word offset
Forthword_ DOC, 0, "do,"
  @ bl is a 32 bit instruction done as two 16 bit instructions in thumb
  @ bit pattern:
  @ 11110xxxxxx - upper half
  @ 11111xxxxxx - lower half
  @ split the 23-bit two’s complement half-word offset specifed by the
  @ label into two 11-bit halves, ignoring bit 0 (which must be 0),
  @ and creates two THUMB instructions
  d_w_                     @ ( dist dist )
  @ get top 11 bits
  asrs wreg, #11           @ ( dist xxxdist )
  @ make high address bl instruction mask
  movs tmp1, #0xF0
  lsls tmp1, #8
  orrs wreg, tmp1          @ ( dist 0xFxdist )
  movs tmp1, #0x8
  lsls tmp1,#8
  bics wreg, tmp1          @ ( dist 0xF0dist )
  do_ COMMA                @ ( dist ?)
  d_                       @ ( dist )
  @ make low address bl instruction mask
  movs tmp1, #0xF8
  lsls tmp1, #8
  orrs wreg, tmp1           @ ( 0xF8dist )
  end_do_ COMMA

@ compile rcall to xt at the current dictionary position (DP) if relative distance is in range
@ otherwise do long call to xt.  If word flag indicates inlining then the word is inlined.
@ ( xt flags -- )
Forthword_ XT_C, 0, "xt,"
  push_lr_
  movs tmp1, #INLINE_OPT
  lsls tmp1, #8
  tst wreg, tmp1
  @ if bit 0 of high byte flag is 0 then word is to be inlinned
  ifnz_ COMPILEXT_DO
    d_             @ ( xt )
    exit_do_ INLINE

COMPILEXT_DO:
  @ calculate relative distance in words from start to dest
  do_ CP                @ ( xt cp )
  do_ RELDST            @ ( distance )
  end_do_ DOC

@ ( val reg -- mvi )
@ make instruction for move immediate into register
Forthword_ MVI, 0, "mvi"
@ make 16 bit thumb instruction
@ movs reg, val
@       reg    val
@ 0010 0xxx xxxxxxxx 
  y_d_             @ ( reg Y:val)
  movs tmp1, #255
  ands yreg, tmp1  @ ( Y:bxxxxxxxx )
  movs tmp1, #7
  ands wreg, tmp1  @ ( b00000xxx )
  movs tmp1, #0b00100000
  orrs wreg, tmp1  @ ( b00100xxx )
  movs tmp1, #8
  lsls wreg, tmp1  @ ( b00100xxx00000000 )
  adds wreg, yreg  @ ( b00100xxxxxxxxxxx )
  end_


@ make instruction load register using [pc]
@ reg is the register number
@ offset is number of words to offset to pc
@ ( reg offset -- ldr= )
Forthword_ LDREQ, 0, "ldr="
@ make 16 bit thumb instruction
@ ldr reg, [pc, offset]
@       reg  offset
@ 0100 1xxx xxxxxxxx
  y_w_            @ ( reg offset Y:offset) 
  d_              @ ( reg )
  movs tmp1, #7
  ands wreg, tmp1 @ ( b00000xxx )
  movs tmp1, #0b01001000
  orrs wreg, tmp1 @ ( b01001xxx )
  movs tmp1, #8
  lsls wreg, tmp1   @ ( b01001xxx00000000 )
  movs tmp1, #0xff
  ands yreg, tmp1
  adds wreg, yreg @ ( b01001xxxxxxxxxxx )
  end_

@ compile 32 bit litteral
@ ( n reg -- )
Forthword_ LIT32_C, 0, "lit32,"
  d_w_           @ ( n reg reg )
  @ check if CP is word aligned
  do_ CPWA       @ ( n reg flag )
  ifz_ LIT_C_LDR
  @ not word aligned
    do_ NOP      @ ( n reg ? )
    do_ COMMA
LIT_C_LDR:
  zero_          @ ( n reg 0 )
  do_ LDREQ      @ ( n ldr= )
  do_ COMMA      @ ( n ? )
  lit_ 1         @ ( n 1 )
  do_ GOTOC      @ ( n ? )
  d_             @ ( n )
LIT_C_END:
  end_do_ DCOMMA

@ compile litteral
@ ( n reg -- )
Forthword_ LIT_C, 0, "lit,"
  push_lr_
  y_d0_          @ ( n reg Y:n )
  cmp yreg, #255
  bgt LIT_C_32
    do_ MVI
    exit_do_ COMMA
LIT_C_32:
  end_do_ LIT32_C

@ branch 1 word if not zero
@ ( -- )
Forthword_ IFNZ, 0, "_ifnz"
  @compile bne.n #00 : 0xD100
  lit_ 0xD100
  end_

@ branch 1 word if zero
@ ( -- )
Forthword_ IFZ, 0, "_ifz"
  @compile beq.n #00 : 0xD000
  lit_ 0xD000
  end_

@ compile top of stack as inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ WLIT_C, 0, "#,"
  d_w_                    @ ( n n )
  zero_
  end_do_ LIT_C

@ compile X register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ XLIT_C, 0, "x#,"
  d_w_                     @ ( n n )
  lit_ 1                   @ ( n xreg )
  end_do_ LIT_C

@ compile Y register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ YLIT_C, 0, "y#,"
  d_w_                     @ ( n n )
  lit_ 2                   @ ( n yreg )
  end_do_ LIT_C

@ compile A register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ ALIT_C, 0, "a#,"
  d_w_                     @ ( n n )
  lit_ 5                   @ ( n areg )
  end_do_ LIT_C

@ compile B register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ BLIT_C, 0, "b#,"
  d_w_                     @ ( n n )
  lit_ 6                   @ ( n breg )
  end_do_ LIT_C
