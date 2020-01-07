@ interpret_number.S

@ ( c -- )
@ fetch the lit vector and EXEC it. Will interpret a litteral for one of the registers
Forthword_ LIT_INTERP, 0, "lit.interp"
  d_w_
  user_  Lit_Interpret
  mw_
  end_do_ EXEC

@ ( c -- )
@ fetch the lit vector and EXEC it. Will compile a litteral for one of the registers
Forthword_ LIT_COMP, 0, "lit.comp"
  d_w_
  user_  Lit_Compile
  mw_
  end_do_ EXEC

@ ( xtc xti -- )
@ Select register for literal
Forthword_ REGSET, IMMEDIATE_EN, "regset"
  r_y_
  y_w_
  user_ Lit_Interpret
  mw_y_
  y_d0_
  user_ Lit_Compile
  mw_y_
  d1_
  d_m2_
  y_r_
  end_

.if BUILD_LEVEL < ASM_BASE
WLIT_C:
ALIT_C:
BLIT_C:
XLIT_C:
YLIT_C:
  end_
.endif

@ ( -- )
@ Select W register for literal
Forthword_ WSET, IMMEDIATE_EN, "w:"
  d_w_
  lit32_ WLIT_C
  d_w_
  lit32_ WLIT_INTERP
  end_do_ REGSET
  
@ ( -- )
@ Select A register for literal
Forthword_ ASET, IMMEDIATE_EN, "a:"
  d_w_
  lit32_ ALIT_C
  d_w_
  lit32_ ALIT_INTERP
  end_do_ REGSET

@ ( -- )
@ Select B register for literal
Forthword_ BSET, IMMEDIATE_EN, "b:"
  d_w_
  lit32_ BLIT_C
  d_w_
  lit32_ BLIT_INTERP
  end_do_ REGSET

@ ( -- )
@ Select X register for literal
Forthword_ XSET, IMMEDIATE_EN, "x:"
  d_w_
  lit32_ XLIT_C
  d_w_
  lit32_ XLIT_INTERP
  end_do_ REGSET

@ ( -- )
@ Select Y register for literal
Forthword_ YSET, IMMEDIATE_EN, "y:"
  d_w_
  lit32_ YLIT_C
  d_w_
  lit32_ YLIT_INTERP
  end_do_ REGSET

@ ( n -- )
@ store n in WR
Forthword_ WLIT_INTERP, IMMEDIATE_EN, "[w:]"
  y_w_
  user_ WR
  mw_y_
  end_

@ ( n -- )
@ store n in RY
Forthword_ YLIT_INTERP, IMMEDIATE_EN, "[y:]"
  y_w_
  user_ RY
  mw_y_
  end_

@ ( n -- )
@ store n in RX
Forthword_ XLIT_INTERP, IMMEDIATE_EN, "[x:]"
  y_w_
  user_ RX
  mw_y_
  end_

@ ( n -- )
@ store n in RA
Forthword_ ALIT_INTERP, IMMEDIATE_EN, "[a:]"
  y_w_
  user_ RA
  mw_y_
  end_

@ ( n -- )
@ store n in RB
Forthword_ BLIT_INTERP, IMMEDIATE_EN, "[b:]"
  y_w_
  user_ RB
  mw_y_
  end_

@ ( addr len -- [n] [addr len] f )
@ recognizer for integer numbers
Forthword_ REC_NUM, 0, "rec@"
  push_lr_
  r_w_                   @ ( addr len ) (R: retaddr len )
  y_d0_                  @ ( addr len Y:addr )
  r_y_                   @ ( addr len ) (R: retaddr len addr )
  @ try converting to a number
  do_ NUMBER             @ ( [n] f )
  iszero_
  ifz_ REC_NONUMBER
    r_m2_                @ ( n f ) (R: retaddr )
    do_ STATE            @ ( n state )
    iszero_
    w_d_                 @ ( n )
    ifz_ REC_NUMBER_OK
      do_ LIT_COMP
      goto_ REC_NUMBER_DONE

REC_NUMBER_OK:
      do_ LIT_INTERP
      
REC_NUMBER_DONE:
      do_ WSET
      true_               @ ( true ) (R: )
      exit_

REC_NONUMBER:
  y_r_                    @ ( 0 Y:addr ) (R: retaddr len )
  d_y_                    @ ( addr 0 ) (R: retaddr len )
  y_r_                    @ ( addr 0 Y:len ) (R: retaddr )
  d_y_                    @ ( addr len 0 )
  end_

