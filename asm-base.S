@ asm-base.S - words that generate inline assembly ie arm thumb instructions

@ ( -- )
@ compile assembler pop {pc}
Forthword_ POPPC_C, 0, "poppc,"
  lit_ 0xbd00
  end_do_ COMMA

@ ( -- )
@ compile assembler push {lr}
Forthword_ PUSHLR_C, 0, "pushlr,"
  lit_ 0xb500
  end_do_ COMMA

@ ( -- )
@ compile assembler bx lr
Forthword_ BXLR_C, 0, "bxlr,"
  push_lr_
  lit_ 0x4770
  do_ COMMA
  end_do_ CLRCACHE

@ calc relative distance in half word alignment
@ ( dest start  -- distance )
Forthword_ RELDST, 0, "reldst"
  @ calculate relative distance in half words from start to dest
  @ rel dist = dest - start
  @ account for 3 stage pipeline
  fourplus_            @ ( dest start+4 )
  y_w_                 @ ( dest start+4 ) Y:start+4
  pop_                 @ ( dest )
  w_minus_y_           @ ( dest-start+4 ) 
  twoslash_            @ ( dist/2 )
  end_

@ build assembler instruction b - unconditional short branch
@ ( reldist -- branchinst )
@ reldist: relative distance as 2's compliment
Forthword_ BRANCH, 0, "b.n"
  @ 1110 0XXX XXXX XXXX
  movs r1, #7
  lsls r1, #8
  adds r1, #0xFF
  ands wreg, r1
  movs r1, #0x07
  lsls r1, #13
  orrs wreg, r1
  end_

@ compile assembler instruction unconditional branch
@ ( reldist -- )
@ reldist: relative distance as 2's compliment
Forthword_ GOTOC, 0, "goto,"
  do_ BRANCH
  end_do_ COMMA

@ compile branch at start address
@ ( start dest -- )
Forthword_ PGOTO, 0, "pgoto"
  push_                @ ( start dest dest )
  d1_                  @ ( start dest start )
  do_ RELDST           @ ( start reldst )
  do_ BRANCH           @ ( start branchinst )
  popy_                @ ( branchinst ) Y:start
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
  push_                    @ ( dist dist )
  @ get top 11 bits
  asrs wreg, #11           @ ( dist xxxdist )
  @ make high address bl instruction mask
  movs r1, #0xF0
  lsls r1, #8
  orrs wreg, r1             @ ( dist 0xFxdist )
  movs r1, #0x8
  lsls r1,#8
  bics wreg, r1             @ ( dist 0xF0dist )
  do_ COMMA                 @ ( dist ?)
  pop_                      @ ( dist )
  @ make low address bl instruction mask
  movs r1, #0xF8
  lsls r1, #8
  orrs wreg, r1             @ ( 0xF8dist )
  end_do_ COMMA

@ compile rcall to xt at the current dictionary position (DP) if relative distance is in range
@ otherwise do long call to xt.  If word flag indicates inlining then the word is inlined.
@ ( xt flags -- )
Forthword_ COMPILEXT, 0, "cxt"
  push_lr_
  movs r1, #INLINE_OPT
  lsls r1, #8
  tst wreg, r1
  @ if bit 0 of high byte flag is 0 then word is to be inlinned
  if_not_0_ COMPILEXT_DO
    pop_           @ ( xt )
    exit_do_ INLINE

COMPILEXT_DO:
  @ calculate relative distance in words from start to dest
  do_ CP                @ ( xt dp )
  do_ RELDST            @ ( distance )
  end_do_ DOC

@ branch 1 word if not zero
@ ( -- )
Forthword_ IFN0_COMPILE, 0, "ifn0,"
  push_
  @compile bne #00 : 0xD100
  lit_ 0xD1
  lsls wreg, #8
  end_do_ COMMA

@ compile value as inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ DOLIT, 0, "(lit,)"
  @ compile xt -> W_MI
  do_ NFATOXTF             @ ( n xt flags )
  do_ COMPILEXT            @ ( n ? )
  pop_                     @ ( n )
  @ store 32 bit val from wreg
  end_do_ DCOMMA

@ compile top of stack as inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ WLIT_C, 0, "w=,"
  push_                    @ ( n n )
  lit32_ VE_W_MI           @ ( n VE_W_MI )
  end_do_ DOLIT

@ compile Y register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ YLIT_C, 0, "y=,"
  push_                    @ ( n n )
  lit32_ VE_Y_MI           @ ( n VE_Y_MI )
  end_do_ DOLIT

@ compile X register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ XLIT_C, 0, "x=,"
  push_                    @ ( n n )
  lit32_ VE_X_MI           @ ( n VE_X_MI )
  end_do_ DOLIT

@ compile A register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ ALIT_C, 0, "a=,"
  push_                    @ ( n n )
  lit32_ VE_A_MI           @ ( n VE_A_MI )
  end_do_ DOLIT

@ compile B register load inlinned immediate 32 bit constant
@ ( n -- )
Forthword_ BLIT_C, 0, "b=,"
  push_                    @ ( n n )
  lit32_ VE_B_MI           @ ( n VE_B_MI )
  end_do_ DOLIT
