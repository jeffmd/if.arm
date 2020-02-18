@ number.S

@ ( -- a-addr )
@ location of the cell containing the number conversion radix
Forthword_ BASE, 0, "base#"
  user_ USER_BASE
  end_

@ ( n -- )
@ save base
Forthword_ BASESTORE, 0, "base="
  y_w_
  user_ USER_BASE
  hmw_y_
  end_

@ ( -- n )
@ load base
Forthword_ BASEFETCH, 0, "base"
  user_ USER_BASE
  hmw_
  end_

@ ( -- )
@ set base for number conversion to 2
Forthword_ BIN, 0, "bin"
  lit_ 2
  end_do_ BASESTORE

@ ( -- )
@ set base for numeric conversion to 8
Forthword_ OCT, 0, "oct"
  lit_ 8
  end_do_ BASESTORE


@ ( -- )
@ set base for numeric conversion to 10
Forthword_ DEC, 0, "dec"
  lit_ 10
  end_do_ BASESTORE

@ ( -- )
@ set base for number conversion to 16
Forthword_ HEX, 0, "hex"
  lit_ 16
  end_do_ BASESTORE

@ ( -- n )
@ load decimal point
Forthword_ DECPNT, 0, "decpnt"
  user_ USER_DECPNT
  mw_
  end_

@ ( -- )
@ start decimal point
Forthword_ DECPNT_SET, 0, "decpnt.set"
  user_ USER_DECPNT
  lit_y_ 1
  mw_y_
  end_

@ ( -- )
@ start decimal point
Forthword_ DECPNT_CLR, 0, "decpnt.clr"
  user_ USER_DECPNT
  y_0_
  mw_y_
  end_

@ ( -- )
@ update decimal point
Forthword_ DECPNTPLUS, 0, "decpnt+"
  do_ BASEFETCH
  y_w_
  user_ USER_DECPNT
  x_w_
  mw_
  iszero_
  ifz_ DECPNTPLUS_END
    w_mul_y_
    mx_w_

DECPNTPLUS_END:
  end_

@ ( c -- c|0 )
@ if c is . then decpnt is set and c becomes 0
Forthword_ DECPNT_CHK, 0, "decpnt?"
  push_lr_
  cmp wreg, #'.
  ifnz_ DECPNTCHK_END
    do_ DECPNT_SET
    zero_
DECPNTCHK_END:
  end_

@ ( n decpnt -- f )
@ convert scaler int to float using vfp
Forthword_ ITOF, 0, "itof"
  do_ WIF
  x_w_
  w_d_
  do_ WIF
  do_ FDIV  
  end_

@ ( n decpnt -- n|f )
@ decpnt is divisor for digits to right of decimal point
@ if decpnt is 1000 then there will be 3 digits to right of decimal point
@ convert n to a float if decpnt > 0
Forthword_ ITOF_CHK, 0, "itof?"
  push_lr_
  iszero_
  ifz_ DECPNTF_END
    do_ ITOF
    exit_

DECPNTF_END:
  w_d_
  end_

@ ( c -- (number|) flag )
@ tries to convert a character to a number, set flag accordingly
Forthword_ DIGITQ, 0, "digit?"
  subs wreg, #0x30    @ ( c' )
  cmp wreg, #10
  blo.n DIGITQ0
  subs wreg, #7       @ ( c' )
  cmp wreg, #10
  bge.n DIGITQ0

  zero_               @ ( 0 )
  exit_

DIGITQ0:
  d_w_                @ ( n n )
  d_w_                @ ( n n n )
  do_ BASEFETCH       @ ( n n base )
  do_ UGREATEREQUAL   @ ( n flag )
  iszero_
  ifz_ PFA_DIGITQ_DONE
  zero_               @ ( n 0 )
  d_m1_               @ ( 0 )
  exit_

PFA_DIGITQ_DONE:
  true_               @ ( n true )
  end_

@ (c -- ) Numeric IO
@ R( -- )
@ set the BASE value depending on the character
forthword_ SETBASE, 0, "setbase"
  push_lr_
  do_ DECPNT_CHK
  ifnz_ PFA_SETBASE_DEC
  exit_

PFA_SETBASE_DEC:
  cmp wreg, #'#
  ifnz_ PFA_SETBASE_HEX
  exit_do_ DEC

PFA_SETBASE_HEX:
  cmp wreg, #'$
  ifnz_ PFA_SETBASE_BIN
  exit_do_ HEX

PFA_SETBASE_BIN:
  cmp wreg, #'%
  ifnz_ PFA_SETBASE_OCT
  exit_do_ BIN

PFA_SETBASE_OCT:
  cmp wreg, #'&
  ifnz_ PFA_SETBASE_BAD
  exit_do_ OCT

PFA_SETBASE_BAD:        @ ( error)
  do_ EMIT
  slit_ " Bad Base!"
  do_ THROW
  end_

@ ( addr len -- addr' len' )
@ skip a numeric prefix character
forthword_ PRAEFIX, 0, "praefix"
  d_w_             @ ( addr len len )
  d1_              @ ( addr len addr )
  cmw_             @ ( addr len c )
  cmp wreg, #0x30
  blo.n PFA_PRAEFIX0
  @ no praefix
  w_d_             @ ( addr len )
  exit_

PFA_PRAEFIX0:
  do_ SETBASE      @ ( addr len c )
  lit_ 1           @ ( addr len 1 )
  end_do_ SLASHSTRING  @ ( addr' len' )

@ (addr len -- addr len flag) Numeric IO
@ check for - sign
forthword_ NUMBERSIGN, 0, "#-"
  d_w_           @ ( addr len len )
  d1_            @ ( addr len addr )
  cmw_           @ ( addr len char )
  cmp wreg, #'-
  ifz_ NUMBERSIGN_HASSIGN
    zero_
    exit_

NUMBERSIGN_HASSIGN:
  push_lr_
  r_w_             @ ( addr len char ) (R: retaddr char )
  lit_ 1           @ ( addr len 1 )
  do_ SLASHSTRING  @ ( addr len )
  d_w_             @ ( addr len len )
  w_r_             @ ( addr len char ) (R: retaddr )
  end_

@ ( u1 c-addr1 len1 -- u2 c-addr2 len2 )
@ convert a string to a number  c-addr2/u2 is the unconverted string
Forthword_ TO_NUMBER, 0, ">num"
  push_lr_
TO_NUMBER_AGAIN:
  iszero_
  ifz_ TO_NUMBER_END
    d_w_                 @ ( u addr len len )
    d1_                  @ ( u addr len addr )
    cmw_                 @ ( u addr len char )
    do_ DECPNT_CHK       @ ( u addr len char )
    iszero_
    ifz_ TO_NUMBER_CONT
    do_ DIGITQ           @ ( u adr len digit flag)
    iszero_
    w_d_                 @ ( u adr len [digit] )
    ifnz_ TO_NUMBER_CONV
      @ character is not a recognized number
      exit_

TO_NUMBER_CONV:
  y_d2_                  @ ( u adr len digit ) Y: u
  x_w_                   @ ( u adr len digit ) X: digit
  do_ BASEFETCH          @ ( u adr len base)
  w_mul_y_               @ ( u adr len u*base )
  w_plus_x_              @ ( u adr len u'' )
  d2_w_                  @ ( u'' adr len u'' )
  do_ DECPNTPLUS

TO_NUMBER_CONT:
  lit_ 1                 @ ( u'' adr len 1 )
  do_ SLASHSTRING        @ ( u'' adr' len' )
  goto_ TO_NUMBER_AGAIN

TO_NUMBER_END:
  end_

@ (addr len -- [n] f)
@ convert a string at addr to a number
Forthword_ NUMBER, 0, "num"
  push_lr_
  d_w_                    @ ( addr len len )
  do_ DECPNT_CLR
  do_ BASEFETCH           @ ( addr len base )
  r_w_                    @ ( addr len base ) (R: base)
  w_d_                    @ ( addr len )
  do_ NUMBERSIGN          @ ( addr len flag )
  r_w_                    @ ( addr len flag ) (R: base flagsign)
  w_d_                    @ ( addr len )
  do_ PRAEFIX             @ ( addr' len' )
  do_ NUMBERSIGN          @ ( addr len flagsign2 )
  y_r0_                   @ ( addr len flagsign2 Y:flagsign ) (R: base flagsign)
  w_or_y_                 @ ( addr len flagsign' )
  r0_w_                   @ ( addr len flagsign' ) (R: base flagsign')
  x_d0_                   @ ( addr len flagsign' ) X: len
  y_d1_                   @ ( addr len flagsign' ) Y: addr
  zero_                   @ ( addr len 0 )
  d1_w_                   @ ( 0 len 0 )
  d0_y_                   @ ( 0 addr 0 )
  x_                      @ ( 0 addr len )
  do_ TO_NUMBER           @ ( n addr' len' )
  @ check length of the remaining string.
  @ if zero: a single cell number is entered
  iszero_
  w_d_                    @ ( n addr' )
  ifz_ PFA_NUMBER_SIGN

  @ error in string to number conversion
  d_m1_                   @ ( addr' )  (R: base flagsign' )
  r_m1_                   @ ( addr' ) (R: base )
  zero_                   @ ( 0 ) (R: base )
  goto_ PFA_NUMBER_DONE

PFA_NUMBER_SIGN:
  @ incorporate sign into number
  w_r_                    @ ( n flagsign' ) (R: base )
  iszero_
  ifz_ PFA_NUMBER_TRUE
  d0_                     @ ( n n )
  neg_                    @ ( n -n )
  d0_w_                   @ ( -n -n )

PFA_NUMBER_TRUE:
  do_ DECPNT              @ ( n decpnt )
  do_ ITOF_CHK            @ ( n|f )
  d_w_                    @ ( n|f n )
  true_                   @ ( n true ) (R: base )

PFA_NUMBER_DONE:
  d_w_                    @ ( n flag flag )
  w_r_                    @ ( n flag base ) (R: )
  do_ BASESTORE           @ ( n flag ? )
  w_d_                    @ ( n flag )
  end_
