@ interpret.S

@ ( -- )
@ ignore remaining text to end of line
Forthword_ COMMENT, IMMEDIATE_EN, "\\"
  push_      @ preserve WR
  do_ STIB
  y_w_
  nip_
  do_ G_IN  @ skip to end of input buffer
  hmw_y_
  pop_      
  end_

@ ( r-addr r-len f-addr f-len --  f)
@ compares string in data RAM with string in program RAM
@ flag is true if strings match
Forthword_ MCMP, 0, "mcmp"
  y_d1_                    @ ( r-addr r-len f-addr f-len )  Y: r-len
  @ check if strings are same length
  w_xor_y_                 @ ( r-addr r-len f-addr flag )
  if_0_ MCMP_SAMELEN

  @ strings are not the same length
  nip3_                    @ ( ? )
  zero_                    @ ( 0 )
  exit_

MCMP_SAMELEN:
  rpusha_                  @ ( ? ) (R: a)
  rpushb_                  @ ( ? ) (R: a b)
  popa_                    @ ( r-addr r-len flag ) A: f-addr
  nip_                     @ ( r-addr flag ) 
  popb_                    @ ( flag ) B:r-addr

MCMP_LOOP:
  y_iszero_                @ ( ? )
  if_0_ MCMP_DONE

  hma_                     @ ( f-cc )
  x_w_                     @ ( f-cc ) X:f-cc 
  hmb_                     @ ( r-cc )
  y_minus1_                @ ( f-cc ) Y:Y-1
  @ program strings could be zero-padded at the last cell for 16bit alignment
  @ if count is even or > 1 then continue
  if_not_0_ MCMP_CHECK
    @ length of string is odd 
    @ only allow low byte of W
    movs r1, #255
    ands wreg, r1            @ ( 0:r-cc )
    @ count was at 1
    @ count in Y is now at zero so add 1 to prevent underflow
    @ so that loop can end properly
    y_plus1_                 @ ( 0:r-cc ) Y:Y+1

  @ then
MCMP_CHECK:
  w_xor_x_                 @ ( flag )
  if_not_0_ MCMP_NOMATCH

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
  rpopb_                   @ ( ) B:b ( R: a)
  rpopa_                   @ ( ) B:b ( R: a)
  end_

@ ( addr1 n1 c -- n2 )
@ skips leading occurances in string at addr1 leaving n2 as an index
@ pointing to the 1st non-c character
@ n1 is max number of characters to search
Forthword_ CSKIP, 0, "cskip"
  rpusha_
  rpushb_
  b_w_                   @ ( addr1 n1 c ) B: c
  a_d1_                  @ ( addr1 n1 c ) A: addr1
  d0_                    @ ( addr1 n1 n1 )
  y_w_                   @ ( addr1 n1 n1 ) Y: n1
  x_w_                   @ ( addr1 n1 n1 ) X: n1
  nip2_                  @ ( n1 )
  goto_ PFA_CSKIP2

PFA_CSKIP1:
  cma_                   @ ( c' )
  a_plus1_
  cmp wreg, breg         @ ( c' )
  if_not_0_ PFA_CSKIP3
  y_minus1_              @ ( c' ) Y-1
PFA_CSKIP2:
  y_iszero_              @ ( c' )
  if_not_0_ PFA_CSKIP1

PFA_CSKIP3:
  rpopb_
  rpopa_
  x_                     @ ( n1 )
  w_minus_y_             @ ( n1-n' )
  end_

@ ( addr1 n1 c -- addr1 n2 )
@ Scan string at addr1 for the first occurance of c, leaving addr1 n2,
@ n1 is max number of characters to search
@ char at n2 is first c character
Forthword_ CSCAN, 0, "cscan"
  rpusha_
  rpushb_
  b_w_                 @ ( addr1 n1 c ) B: c
  a_d1_                @ ( addr1 n1 c ) A: addr1
  d0_                  @ ( addr1 n1 n1 )
  y_w_                 @ ( addr1 n1 n1 ) Y: n1 
  x_w_                 @ ( addr1 n1 n1 ) X: n1
  nip_                 @ ( addr1 n1 )
  goto_ PFA_CSCAN2

PFA_CSCAN1:
  cma_                 @ ( addr1 c' )
  a_plus1_
  cmp wreg, breg       @ ( addr1 n1 n' c' )
  if_0_ PFA_CSCAN3
  y_minus1_            @ ( addr1 c' ) Y-1

PFA_CSCAN2:
  y_iszero_            @ ( addr1 c' )
  if_not_0_ PFA_CSCAN1

PFA_CSCAN3:
  rpopb_
  rpopa_
  x_                   @ ( addr1 n1 )
  w_minus_y_           @ ( addr1 n1-n' )
  end_

@ ( -- srcaddr len  )
@ Adjust the source addr using >in.
Forthword_ SRCIN, 0, "srcin"
  do_ STIB             @ ( srcaddr len )
  push_                @ ( srcaddr len len)
  do_ G_IN             @ ( srcaddr len ginaddr )
  hmw_                 @ ( srcaddr len gin)
  end_do_ SLASHSTRING  @ ( srcaddr' len' )

@ ( n -- ginaddr Y:n )
@ update position in input source.
Forthword_ UPDIN, 0, "updin"
  y_w_                 @ ( n2 Y:n2 )
  do_ G_IN             @ ( n2 ginaddr )
  x_hmw_               @ ( ginaddr X:inidx)
  x_plus_y_            @ ( ginaddr )
  hmw_x_
  end_

@ ( -- )
@ skip space in input source.
Forthword_ SKIPBL, 0, "skipbl"
  do_ SRCIN            @ ( srcaddr len )
  push_                @ ( srcaddr len len )
  bl_                  @ ( srcaddr len c )
  do_ CSKIP            @ ( n2 )

  @ adjust >IN
  end_do_ UPDIN

@ ( char -- c-addr len ) "ccc<char>"
@ in input buffer parse ccc delimited string by the delimiter char.
Forthword_ PARSE, 0, "parse"
  push_lr_
  rpush_           @ ( c ) (R: c )
  do_ SRCIN        @ ( addr len )
  push_            @ ( addr len len )
  rpop_            @ ( addr len c ) (R: )
  do_ CSCAN        @ ( addr' len'' )
  oneplus_         @ ( addr' len''+1 )
  # skip terminating delimeter in input buffer
  do_ UPDIN
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
  push_                @ ( xt xt xt)
  user_ WR             @ ( xt xt WR )
  y_mw_                @ ( xt xt WR ) Y:w
  d1_y_                @ ( w xt WR )
  fourplus_            @ ( w xt RA )
  a_mw_                @ ( w xt RA ) A:a
  fourplus_            @ ( w xt RB )
  b_mw_                @ ( w xt RB ) B:b
  fourplus_            @ ( w xt RX )
  x_mw_                @ ( w xt RX ) X:x
  fourplus_            @ ( w xt RY )
  y_mw_                @ ( w xt RY ) Y:y
  pop_                 @ ( w xt )
  end_

@ save registers W, A, B, X, Y
@ ( n -- )
forthword_ REGS, 0, "regs"
  pushy_               @ ( Y n )
  y_w_                 @ ( Y n ) Y:n
  user_ WR             @ ( Y WR )
  mw_y_
  fourplus_            @ ( Y RA )
  mw_a_
  fourplus_            @ ( Y RB )
  mw_b_
  fourplus_            @ ( Y RX )
  mw_x_
  fourplus_            @ ( Y RY )
  popy_                @ ( RY )
  mw_y_
  end_

@ ( addr len -- ** [addr len] f )
@ recognize a word in the dictionary
Forthword_ REC_WORD, 0, "recw"
  rpush_              @ ( addr len ) (R: len )
  y_d0_               @ ( addr len Y:addr )
  rpushy_             @ ( addr len ) (R: len addr )
  do_ FINDW
  iszero_
  if_not_0_ REC_WORD_FOUND
    rpop_             @ ( addr ) (R: len )
    push_             @ ( addr addr ) (R: len )
    rpop_             @ ( addr len ) (R: ) 
    push_             @ ( addr len len )
    zero_             @ ( addr len 0 )
    exit_

REC_WORD_FOUND:
  rnip2_            @ ( nfa ) (R: )
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
  if_0_ REC_WORD_EXECUTE

REC_WORD_CHECKSTATE:
    @ check state
    push_              @ ( xt flag flag )
    do_ STATE          @ ( xt flag state )
    iszero_
    pop_               @ ( xt flag )
    if_0_ REC_WORD_EXECUTE
.if BUILD_LEVEL > 9
      @ in compile mode so compile xt
      do_ COMPILEXT      @ ( ? )
.endif
      true_
      exit_

REC_WORD_EXECUTE:
    @ state is zero, EXEC xt
  do_ REGL
  do_ EXEC
  do_ REGS

  true_
  end_

@ ( addr len -- )
@ recognize and execute name of word in ram using recognizer list.
Forthword_ RECX, 0, "recx"
  @ test if its a word
  do_ REC_WORD            @ ( [addr len] flag )
  iszero_                 @ ( [addr len] flag )
  if_0_ RECX_DONE

.if BUILD_LEVEL > 3
  @ test if its a number
  pop_                   @ ( addr len )
  do_ REC_NUM            @ ( [addr len] flag )
  iszero_                @ ( [addr len] flag )
  if_not_0_ RECX_DONE
.endif

  @ not recognized so throw
  do_ CR                 @ ( addr len ? )
  pop_                   @ ( addr len )
  @ print unrecognized word
  do_ TYPE               @ ( ? )
    
  slit_ " Unknown!"
  do_ THROW

RECX_DONE:
  end_


@ ( -- )
@ interpret input word by word.
Forthword_ INTERPRET, 0, "interp"
  end_
  push_lr_
INTERPRET_DO:
  @ begin
  do_ PNAME           @ ( addr len )

  @ ?while
  iszero_             @ ( addr len )
  if_0_ INTERPRET_END

  do_ RECX            @ ( ? )
  do_ QSTACK          @ ( ? )

  @ repeat
  goto_ INTERPRET_DO

INTERPRET_END:
  pop_                @ ( addr )
  end_

@ ( -- )
@ interpret what is in the input buffer
Forthword_ DOINTERPRET, 0, "(interp)"
  @ input buffer has something so try to interpret it
  @ setup exception handling in case of error
  push_
  lit32_ INTERPRET
  do_ CATCH
  @ check to make sure no throws
  @ <if>
  iszero_
  if_0_ DOINTERPRET_ok
    do_ PROMPTERROR
    exit_do_ QUIT

  @ <then>
DOINTERPRET_ok:
  @ make sure in buf pointer is not at zero
  do_ G_IN              @ ( >inaddr )
  y_hmw_                @ ( )
  y_plus1_
  hmw_y_
  end_do_ PROMPTOK


