@ interpret.S


@ ( r-addr r-len f-addr f-len --  f)
@ compares string in RAM with string in flash
Forthword_ MCMP, 0, "mcmp"
    push {lr}
    tob_                     @ ( r-addr r-len f-addr)  B: f-len
    over_                    @ ( r-addr r-len f-addr r-len)
    @getb_                    @ ( r-addr r-len f-addr r-len f-len )
    @ check if strings are same length
    eors wreg, breg            @ ( r-addr r-len f-addr flag )
    @ if
    zerosense_               @ ( r-addr r-len f-addr )
    beq.n MCMP_SAMELEN

    @ strings are not the same length
    dnip_
    zerotos_                 @ ( 0 )
    pop {pc}

    @ then
MCMP_SAMELEN:
    @twostar_                @ ( r-addr len f-addr*2 )
    toa_                     @ ( r-addr len ) A: f-addr
    oneplus_                 @ ( r-addr len+1 )
    twoslash_                @ ( r-addr (len+1)/2 )

    @ begin
MCMP_LOOP:
    copytob_                 @ ( r-addr len ) B: len
    @ while
    zerosense_               @ ( r-addr )
    beq.n MCMP_DONE

    push_                     @ ( r-addr r-addr )
    hfetch_                  @ ( r-addr r-cc )
    ahfetch_                 @ ( r-addr r-cc f-cc )
    ahplus_
    @ flash strings are zero-padded at the last cell
    @ that means: if the flash cell is less $0100, than mask the
    @ high byte in the ram cell
    push_                     @ ( r-addr r-cc f-cc f-cc )
    push_
    movs wreg, #80             @ ( r-addr r-cc f-cc f-cc 0x100 )
    adds wreg, wreg
    bl ULESS                 @ ( r-addr r-cc f-cc flag)
    @ if
    zerosense_
    beq.n MCMP_LASTCELL
    swap_                    @ ( r-addr f-cc r-cc)
    movs r0, #255
    ands wreg, r0              @ ( r-addr f-cc 0:r-cc)
    @ then
MCMP_LASTCELL:
    xor_                     @ ( r-addr flag)
    @ if
    zerosense_               @ ( r-addr )
    beq.n MCMP_NEXTLOOP

    @ strings don't match
    zerotos_                 @ ( 0 )
    pop {pc}

    @ then
MCMP_NEXTLOOP:
    twoplus_                 @ ( r-addr+2 )
    getb_                    @ ( r-addr+2 len )
    oneminus_                @ ( r-addr+2 len-1 )

    @ repeat
    b.n MCMP_LOOP

MCMP_DONE:
    @ strings are the same
    pop_
    true_
    pop {pc}


@ ( addr1 n1 c -- n2 )
@ skips leading occurances in string at addr1 leaving n2 as an index
@ pointing to the 1st non-c character
@ n1 is max number of characters to search
Forthword_ CSKIP, 0, "cskip"
    tob_                 @ ( addr1 n1 ) B: c
    niptoa_              @ ( n1 ) A: addr1
    push_                 @ ( n1 n1 )
PFA_CSKIP1:
    dupzerosense_        @ ( n1 n')
    beq.n PFA_CSKIP2
    acfetch_             @ ( n1 n' c' )
    acplus_
    cmp wreg, breg        @ ( n1 n' c' )
    pop_                @ ( n1 n' )
    bne.n PFA_CSKIP2
    oneminus_
    b.n PFA_CSKIP1

PFA_CSKIP2:
    minus_               @ ( n1-n' )
    bx lr

@ ( addr1 n1 c -- addr1 n2 )
@ Scan string at addr1 for the first occurance of c, leaving addr1 n2,
@ n1 is max number of characters to search
@ char at n2 is first c character
Forthword_ CSCAN, 0, "cscan"
    tob_                 @ ( addr1 n1 ) B: c
    over_                @ ( addr1 n1 addr1 )
    toa_                 @ ( addr1 n1 ) A: addr1
    push_                 @ ( addr1 n1 n1 )
PFA_CSCAN1:
    dupzerosense_        @ ( addr1 n1 n')
    beq.n PFA_CSCAN2
    acfetch_             @ ( addr1 n1 n' c' )
    acplus_
    cmp wreg, breg        @ ( addr1 n1 n' c' )
    pop_                @ ( addr1 n1 n' )
    beq.n PFA_CSCAN2
    oneminus_
    b.n PFA_CSCAN1

PFA_CSCAN2:
    minus_               @ ( addr1 n1-n' )
    bx lr

@ ( -- srcaddr len  )
@ Adjust the source addr using >in.
Forthword_ SRCIN, 0, "srcin"
    push {lr}
    bl STIB            @ ( srcaddr len )
    bl G_IN            @ ( srcaddr len ginaddr )
    hfetch_            @ ( srcaddr len gin)
    pop_lr_
    b SLASHSTRING     @ ( srcaddr' len' )


@ ( -- )
@ skip space in input source.
Forthword_ SKIPBL, 0, "skipbl"
    push {lr}
    bl SRCIN             @ ( srcaddr len )
    bl_                  @ ( srcaddr' len' c )
    bl CSKIP             @ ( n2 )

    @ adjust >IN
    bl G_IN              @ ( n2 ginaddr )
    pop_lr_
    b PLUSHSTORE        @ (  )

@ ( char "ccc<char>" -- c-addr u )
@ in input buffer parse ccc delimited string by the delimiter char.
Forthword_ PARSE, 0, "parse"
    push {lr}
    bl SRCIN         @ ( -- c addr len)
    bl ROT           @ ( -- addr' len' c)
    bl CSCAN         @ ( -- len'')
    push_             @ ( -- addr' len'' len'')
    oneplus_         @ ( -- addr' len'' len''+1 )
    bl G_IN          @ ( -- addr' len'' len''+1 >in)
    pop_lr_
    b PLUSHSTORE    @ ( -- addr' len'')


@ ( "<name>" -- c-addr len )
@ In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.
Forthword_ PNAME, 0, "pname"
    push {lr}
    bl SKIPBL
    bl_
    pop_lr_
    b PARSE


@ ( addr len -- [n] [addr len] f )
@ recognizer for integer numbers
Forthword_ REC_NUM, 0, "rec#"
    push {lr}
    bl TWOOVER
    to_r_
    to_r_
    @ try converting to a number
    bl NUMBER              @ ( [n] f )
    zerosense_
    beq.n REC_NONUMBER

      bl STATEFETCH        @ ( n state )
      zerosense_
      beq.n REC_NUMBER_OK
        bl LIT

REC_NUMBER_OK:
      r_drop_
      r_drop_
      true_                @ ( n true )
      pop {pc}

REC_NONUMBER:
    r_from_
    r_from_
    zero_                  @ ( 0 )
    pop {pc}


@ ( addr len -- ** [addr len] f )
@ recognize a word in the dictionary
Forthword_ REC_WORD, 0, "recw"
    push {lr}
    bl TWOOVER
    to_r_
    to_r_
    bl FINDW
    dupzerosense_
    bne.n REC_WORD_FOUND
      r_from_
      r_from_
      pop_lr_
      b ROT

REC_WORD_FOUND:
    r_drop_
    r_drop_
    bl NFATOXTF
    @ check if compile only word
    @sbrc tosh, COMPILE_ONLY_FB
    @    rjmp CHECK_IMMEDIATE

@CHECK_COMPILE_ONLY:
@    bl STATEFETCH
@    zerosense_
@    bne.n CHECK_IMMEDIATE
        @ word can only be used in compile state
        @jmp THROW


@CHECK_IMMEDIATE:
  @ either compile or EXEC the XT
    @ check if word is immediate: bit 15 is clear if immediate
  @sbrs tosh, IMMEDIATE_EN_FB @ skip next instruction if bit 7 is set: not immediate word
  movs r0, #IMMEDIATE_EN
  lsls r0, #8
  tst wreg, r0
  @ flag is 0: always EXEC
  beq.n REC_WORD_EXECUTE

REC_WORD_CHECKSTATE:
        @ check state
      bl STATEFETCH
      zerosense_
      beq.n REC_WORD_EXECUTE
        @ in compile mode so compile xt
      bl COMPILEXT
      true_
      pop {pc}

REC_WORD_EXECUTE:
    pop_
    @ state is zero, EXEC xt
    bl EXEC
REC_WORD_OK:
    true_
    pop {pc}



@ ( addr len -- )
@ recognize and execute name of word in ram using recognizer list.
Forthword_ RECX, 0, "recx"
    push {lr}
    @ test if its a word
    bl REC_WORD           @ ( flag ) ( R: len addr )
    @ <if>
    zerosense_            @ ( addr len )
    bne.n RECX_DONE
    @ test if its a number
    bl REC_NUM            @ ( flag ) ( R: len addr )
    zerosense_            @ ( addr len )
    bne.n RECX_DONE
    @ not recognized so throw
    bl CR
    @ print unrecognized word
    bl TYPE
    @doliteral_ 0xBAD
    
    $lit_ " Unknown!"
    bl THROW

RECX_DONE:
    pop {pc}


@ ( -- ) (R: i*x - j*x )
@ interpret input word by word.
Forthword_ INTERPRET, 0, "interp"
    push {lr}
INTERPRET_DO:
    @ begin
    bl PNAME            @ ( -- addr len )

    @ ?while
    dupzerosense_       @ ( -- addr len )
    beq.n INTERPRET_END

    bl RECX             @ ( )
    bl QSTACK           @ ( )

    @ repeat
    b.n INTERPRET_DO

INTERPRET_END:
    ddrop_
    pop {pc}

@ ( -- )
@ interpret what is in the input buffer
Forthword_ DOINTERPRET, 0, "(interp)"
  push {lr}
  @ input buffer has something so try to interpret it
  @ setup exception handling in case of error
  dolit32_ INTERPRET
  bl CATCH
  @ check to make sure no throws
  bl QDUP
  @ <if>
  zerosense_
  beq.n DOINTERPRET_ok
    bl PROMPTERROR
    bl QUIT

  @ <then>
DOINTERPRET_ok:
  @ make sure in buf pointer is not at zero
  bl G_IN               @ ( 1 >inaddr )
  bl ONEPLUSHSTORE      @ ( )
  pop_lr_
  b PROMPTOK


