@ interpret.S

@ ( -- )
@ ignore remaining text to end of line
Forthword_ COMMENT, IMMEDIATE_EN, "\\"
  d_w_         @ ( ? ? )
  do_ WIB      @ ( ? wib )
  do_ RIB_STR  @ ( ? ? )
  w_d_         @ ( ? )
  end_

@ ( r-addr r-len f-addr f-len --  f)
@ compares string in data RAM with string in program RAM
@ flag is true if strings match
Forthword_ MCMP, 0, "mcmp"
  y_d1_                    @ ( r-addr r-len f-addr f-len )  Y: r-len
  @ check if strings are same length
  w_xor_y_                 @ ( r-addr r-len f-addr flag )
  ifz_ MCMP_SAMELEN

  @ strings are not the same length
  d_m3_                    @ ( ? )
  zero_                    @ ( 0 )
  exit_

MCMP_SAMELEN:
  r_a_                     @ ( ? ) (R: a)
  r_b_                     @ ( ? ) (R: a b)
  a_d_                     @ ( r-addr r-len flag ) A: f-addr
  d_m1_                    @ ( r-addr flag ) 
  b_d_                     @ ( flag ) B:r-addr

MCMP_LOOP:
  y_iszero_                @ ( ? )
  ifz_ MCMP_DONE

  hma_                     @ ( f-cc )
  x_w_                     @ ( f-cc ) X:f-cc 
  hmb_                     @ ( r-cc )
  y_minus1_                @ ( f-cc ) Y:Y-1
  @ program strings could be zero-padded at the last cell for 16bit alignment
  @ if count is even or > 1 then continue
  ifnz_ MCMP_CHECK
    movs r1, #255
    @ count was at 1
    @ count in Y is now at zero so add 1 to prevent underflow
    @ so that loop can end properly
    y_plus1_                 @ ( 0:r-cc ) Y:Y+1
    @ length of string is odd 
    @ only allow low byte of W
    ands wreg, r1            @ ( 0:r-cc )

  @ then
MCMP_CHECK:
  w_xor_x_                 @ ( flag )
  ifnz_ MCMP_NOMATCH

  b_plus2_                 @ (  0 B:B+2 )
  a_plus2_                 @ (  0 A:B+2 )
  y_minus1_                @ (  0 Y:len-1 )
  goto_ MCMP_LOOP

MCMP_NOMATCH:
  @ strings don't match
  zero_                    @ ( 0 )
  not_                     @ ( true )

MCMP_DONE:
  @ strings are the same
  not_                     @ ( ! )
  b_r_                     @ ( ) B:b ( R: a)
  a_r_                     @ ( ) B:b ( R: a)
  end_

@ ( addr1 n1 c -- n2 )
@ skips leading occurances in string at addr1 leaving n2 as an index
@ pointing to the 1st non-c character
@ n1 is max number of characters to search
Forthword_ CSKIP, 0, "cskip"
  r_a_
  r_b_
  b_w_                   @ ( addr1 n1 c ) B: c
  a_d1_                  @ ( addr1 n1 c ) A: addr1
  d0_                    @ ( addr1 n1 n1 )
  y_w_                   @ ( addr1 n1 n1 ) Y: n1
  x_w_                   @ ( addr1 n1 n1 ) X: n1
  d_m2_                  @ ( n1 )
  goto_ CSKIP_CHECK

CSKIP_LOOP:
  cma_                   @ ( c' )
  a_plus1_
  cmp wreg, breg         @ ( c' )
  ifnz_ CSKIP_DONE
  y_minus1_              @ ( c' ) Y-1
CSKIP_CHECK:
  y_iszero_              @ ( c' )
  ifnz_ CSKIP_LOOP

CSKIP_DONE:
  b_r_
  a_r_
  x_                     @ ( n1 )
  w_minus_y_             @ ( n1-n' )
  end_

@ ( addr1 n1 c -- addr1 n2 )
@ Scan string at addr1 for the first occurance of c, leaving addr1 n2,
@ n1 is max number of characters to search
@ char at n2 is first c character
Forthword_ CSCAN, 0, "cscan"
  r_a_
  r_b_
  b_w_                 @ ( addr1 n1 c ) B: c
  a_d1_                @ ( addr1 n1 c ) A: addr1
  d0_                  @ ( addr1 n1 n1 )
  y_w_                 @ ( addr1 n1 n1 ) Y: n1 
  x_w_                 @ ( addr1 n1 n1 ) X: n1
  d_m1_                @ ( addr1 n1 )
  goto_ CSCAN_CHECK

CSCAN_LOOP:
  cma_                 @ ( addr1 c' )
  a_plus1_
  cmp wreg, breg       @ ( addr1 n1 n' c' )
  ifz_ CSCAN_DONE
  y_minus1_            @ ( addr1 c' ) Y-1

CSCAN_CHECK:
  y_iszero_            @ ( addr1 c' )
  ifnz_ CSCAN_LOOP

CSCAN_DONE:
  b_r_
  a_r_
  x_                   @ ( addr1 n1 )
  w_minus_y_           @ ( addr1 n1-n' )
  end_

@ ( -- srcaddr len  )
@ Adjust the source addr using rib.
Forthword_ SRCIN, 0, "srcin"
  do_ STIB             @ ( srcaddr len )
  d_w_                 @ ( srcaddr len len)
  do_ RIB              @ ( srcaddr len rib )
  end_do_ SLASHSTRING  @ ( srcaddr' len' )

@ ( -- )
@ skip space in input source.
Forthword_ SKIPBL, 0, "skipbl"
  do_ SRCIN            @ ( srcaddr len )
  d_w_                 @ ( srcaddr len len )
  bl_                  @ ( srcaddr len c )
  do_ CSKIP            @ ( n2 )

  @ adjust >IN
  end_do_ RIB_PLUS_STR

@ ( char -- c-addr len ) "ccc<char>"
@ in input buffer parse ccc delimited string by the delimiter char.
Forthword_ PARSE, 0, "parse"
  push_lr_
  r_w_             @ ( c ) (R: c )
  do_ SRCIN        @ ( addr len )
  d_w_             @ ( addr len len )
  w_r_             @ ( addr len c ) (R: )
  do_ CSCAN        @ ( addr' len'' )
  # skip terminating delimeter in input buffer
  oneplus_         @ ( addr' len''+1 )
  do_ RIB_PLUS_STR
  y_               @ ( addr' len''+1)
  oneminus_        @ ( addr' len'')
  end_


@ ( "<name>" -- c-addr len )
@ In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.
Forthword_ PNAME, 0, "pname"
  do_ SKIPBL
  bl_
  end_do_ PARSE

@ load registers W, A, B, X, Y from user storage area
@ ( xt * -- w xt )
forthword_ REGL, 0, "regl"
  d0_                  @ ( xt xt )
  d_w_                 @ ( xt xt xt)
  user_ WR             @ ( xt xt WR )
  y_mw_                @ ( xt xt WR ) Y:[WR]
  d1_y_                @ ( w xt WR )
  fourplus_            @ ( w xt RA )
  a_mw_                @ ( w xt RA ) A:[RA]
  fourplus_            @ ( w xt RB )
  b_mw_                @ ( w xt RB ) B:[RB]
  fourplus_            @ ( w xt RX )
  x_mw_                @ ( w xt RX ) X:[RX]
  fourplus_            @ ( w xt RY )
  y_mw_                @ ( w xt RY ) Y:[RY]
  w_d_                 @ ( w xt )
  end_

@ save registers W, A, B, X, Y
@ ( n -- )
forthword_ REGS, 0, "regs"
  d_y_                 @ ( y n )
  y_w_                 @ ( y n ) Y:n
  user_ WR             @ ( y WR )
  mw_y_                @ [WR]=n
  fourplus_            @ ( y RA )
  mw_a_                @ [RA]=a
  fourplus_            @ ( y RB )
  mw_b_                @ [RB]=b
  fourplus_            @ ( y RX )
  mw_x_                @ [RB]=x
  fourplus_            @ ( y RY )
  y_d_                 @ ( RY )
  mw_y_                @ [RY]=y
  end_

@ ( addr len -- ** [addr len] f )
@ recognize a word in the dictionary
Forthword_ REC_WORD, 0, "recw"
  push_lr_            @ ( addr len ) (R: retaddr )
  r_w_                @ ( addr len ) (R: retaddr len )
  y_d0_               @ ( addr len Y:addr )
  r_y_                @ ( addr len ) (R: retaddr len addr )
  do_ FINDW           @ ( 0 | nfa )
  iszero_
  ifnz_ REC_WORD_FOUND
    y_r_              @ ( 0 ) Y:addr (R: retaddr len )
    d_y_              @ ( addr 0 ) (R: retaddr len )
    y_r_              @ ( addr 0 ) Y:len (R: retaddr ) 
    d_y_              @ ( addr len 0 )
    exit_

REC_WORD_FOUND:
  r_m2_             @ ( nfa ) (R: retaddr )
  do_ NFATOXTF      @ ( xt flag )
  @ check if compile only word
  @sbrc tosh, COMPILE_ONLY_FB
  @    rjmp CHECK_IMMEDIATE

@CHECK_COMPILE_ONLY:
@    bl STATEFETCH
@    zerosense_
@    bne.n CHECK_IMMEDIATE
        @ word can only be used in compile state
        @jmp THROW


CHECK_IMMEDIATE:
  @ either compile or EXEC the XT
    @ check if word is immediate: bit 15 is clear if immediate
  @sbrs tosh, IMMEDIATE_EN_FB @ skip next instruction if bit 7 is set: not immediate word
  movs r1, #IMMEDIATE_EN
  lsls r1, #8
  tst wreg, r1
  @ flag is 0: always EXEC
  ifz_ REC_WORD_EXECUTE

REC_WORD_CHECKSTATE:
    @ check state
    d_w_               @ ( xt flag flag )
    do_ STATE          @ ( xt flag state )
    iszero_
    w_d_               @ ( xt flag )
    ifz_ REC_WORD_EXECUTE
.if BUILD_LEVEL >= ASM_BASE
      @ in compile mode so compile xt
      do_ XT_C         @ ( ? )
.endif
      true_
      exit_

REC_WORD_EXECUTE:
    @ state is zero, EXEC xt
  do_ REGL             @ ( w xt )
  do_ EXEC             @ ( * )
  do_ REGS             @ ( ? )

  true_
  end_

@ ( addr len -- )
@ recognize and execute name of word in ram using recognizer list.
Forthword_ RECX, 0, "recx"
  @ test if its a word
  do_ REC_WORD            @ ( [addr len] flag )
  iszero_                 @ ( [addr len] flag )
  ifnz_ RECX_DONE

.if BUILD_LEVEL > 4
  @ test if its a number
  w_d_                   @ ( addr len )
  do_ REC_NUM            @ ( [addr len] flag )
  iszero_                @ ( [addr len] flag )
  ifnz_ RECX_DONE
.endif

  @ not recognized so throw
  do_ CR                 @ ( addr len ? )
  w_d_                   @ ( addr len )
  @ print unrecognized word
  do_ TYPE               @ ( ? )
    
  slit_ " Unknown!"
  do_ THROW

RECX_DONE:
  end_


@ ( -- )
@ interpret input word by word.
Forthword_ INTERPRET, 0, "interp"
  push_lr_
INTERPRET_DO:
  @ begin
  do_ PNAME           @ ( addr len )

  @ ?while
  iszero_             @ ( addr len )
  ifz_ INTERPRET_END

  do_ RECX            @ ( ? )
  do_ QSTACK          @ ( ? )

  @ repeat
  goto_ INTERPRET_DO

INTERPRET_END:
  w_d_                @ ( addr )
  end_

@ ( -- )
@ interpret what is in the input buffer
Forthword_ DOINTERPRET, 0, "(interp)"
  @ input buffer has something so try to interpret it
  @ setup exception handling in case of error
  d_w_
  lit32_ INTERPRET
  do_ CATCH
  @ check to make sure no throws
  @ <if>
  iszero_
  ifz_ DOINTERPRET_ok
    do_ PROMPTERROR
    exit_do_ QUIT

  @ <then>
DOINTERPRET_ok:
  @ make sure in buf pointer is not at zero
  lit_ 1
  do_ RIB_PLUS_STR      @ ( ribaddr )
  end_do_ PROMPTOK
