@ number.S

@ ( -- a-addr )
@ location of the cell containing the number conversion radix
Forthword_ BASE, 0, "base"
    douser_ USER_BASE

@ ( n -- )
@ save base
Forthword_ BASESTORE, 0, "base!"
    push {lr}
    bl BASE
    pop_lr_
    b HSTORE

@ ( n -- )
@ load base
Forthword_ BASEFETCH, 0, "base@"
    push {lr}
    bl BASE
    hfetch_
    pop {pc}

@ ( -- )
@ set base for number conversion to 2
Forthword_ BIN, 0, "bin"
    two_
    b.n BASESTORE


@ ( -- )
@ set base for numeric conversion to 10
Forthword_ DECIMAL, 0, "decimal"
    ten_
    b.n BASESTORE

@ ( -- )
@ set base for number conversion to 16
Forthword_ HEX, 0, "hex"
    dolit8_ 16
    b.n BASESTORE




@ ( c -- (number|) flag )
@ tries to convert a character to a number, set flag accordingly
Forthword_ DIGITQ, 0, "digit?"
    subs wreg, #0x30
    cmp wreg, #10
    blo.n DIGITQ0
    subs wreg, #7
    cmp wreg, #10
    bge.n DIGITQ0

    zerotos_
    bx lr

DIGITQ0:
    push_
    push {lr}
    bl BASEFETCH
    bl UGREATEREQUAL
    zerosense_
    beq.n PFA_DIGITQ2
    zerotos_
    pop {pc}

PFA_DIGITQ2:
    true_
    pop {pc}



@ (c -- ) Numeric IO
@ R( -- )
@ set the BASE value depending on the character
@forthword_ SETBASE, 0, "setbase"
SETBASE:        @ ( c -- )
    mov r0, wreg
    pop_
    cmp r0, #'$
    bne.n PFA_SETBASE0
    b.n HEX

PFA_SETBASE0:
    cmp r0, #'%
    bne.n PFA_SETBASE1
    b.n BIN

PFA_SETBASE1:
    cmp r0, #'&
    bne.n PFA_SETBASE2
    b.n DECIMAL

PFA_SETBASE2:        @ ( error)
    push_
    mov wreg, r0
    bl EMIT
    $lit_ " Bad Base!"
    bl THROW

@ ( addr len -- addr' len' )
@ skip a numeric prefix character
@forthword_ PRAEFIX, 0, "praefix"
PRAEFIX:        @ ( adr1 len1 -- adr2 len2 )
    push {lr}
    over_
    cfetch_
    cmp wreg, #0x30
    blo.n PFA_PRAEFIX0
    @ no praefix
    pop_
    pop {pc}

PFA_PRAEFIX0:
    bl SETBASE
    one_
    bl SLASHSTRING
    pop {pc}

@ (addr len -- addr len flag) Numeric IO
@ check for - sign
@ forthword_ NUMBERSIGN, 0, "#-"
NUMBERSIGN:        @ ( addr len -- )
    over_          @ ( addr len addr )
    cfetch_        @ ( addr len char )
    cmp wreg, #'-
    beq.n NUMBERSIGN_HASSIGN
      zerotos_
      bx lr

NUMBERSIGN_HASSIGN:
      push {lr}
      to_r_
      one_
      bl SLASHSTRING
      r_from_
      pop {pc}

@ ( u1 c-addr1 len1 -- u2 c-addr2 len2 )
@ convert a string to a number  c-addr2/u2 is the unconverted string
Forthword_ TO_NUMBER, 0, ">num"
    push {lr}
TO_NUMBER_AGAIN:
    dupzerosense_
    beq.n TO_NUMBER_END
        over_                @ ( u adr len adr)
        cfetch_              @ ( u adr len char)
        bl DIGITQ            @ ( u adr len digit flag)
        zerosense_
        bne.n TO_NUMBER_CONV
            @ character is not a recognized number
            pop {pc}

TO_NUMBER_CONV:
        tob_                 @ ( u adr len) B: digit
        bl ROT               @ ( adr len u)
        bl BASEFETCH         @ ( adr len u base)
        @bl STAR             @ ( adr len u*base)
        mov r0, wreg
        pop_
        muls wreg, r0
        getb_                @ ( adr len u' digit)
        plus_                @ ( adr len u')
        bl RROT              @ ( u' adr len )
        one_
        bl SLASHSTRING
        b.n TO_NUMBER_AGAIN

TO_NUMBER_END:
    pop {pc}

@ (addr len -- [n] f)
@ convert a string at addr to a number
Forthword_ NUMBER, 0, "num"
  push {lr}
  bl BASEFETCH
  to_r_                   @ ( addr len ) (R: base)
  bl NUMBERSIGN
  to_r_                   @ ( addr len ) (R: base flagsign)
  bl PRAEFIX
  bl NUMBERSIGN           @ ( addr len flagsign2 )
  r_from_                 @ ( addr len flagsign2 flagsign ) (R: base )
  or_                     @ ( addr len flagsign' )
  to_r_                   @ ( addr len ) (R: base flagsign')
  zero_                   @ ( addr len 0 ) starting value
  bl RROT                 @ ( 0 addr len )
  bl TO_NUMBER            @ ( n addr' len' )
  @ check length of the remaining string.
  @ if zero: a single cell number is entered
  zerosense_
  beq.n PFA_NUMBER1

  @ error in string to number conversion
PFA_NUMBER2:
  nip_                    @ ( addr' )  (R: base flagsign' )
  r_drop_                 @ ( addr' ) (R: base )
  zerotos_                @ ( 0 ) (R: base )
  b.n PFA_NUMBER5

PFA_NUMBER1:
  pop_                   @ ( n )  (R: base flagsign' )
  @ incorporate sign into number
  r_from_                 @ ( n flagsign' ) (R: base )
  zerosense_
  beq.n PFA_NUMBER4
  neg_

PFA_NUMBER4:
  true_                   @ ( n true ) (R: base )

PFA_NUMBER5:
  r_from_                 @ ( n true base ) (R: )
  pop_lr_
  b BASESTORE            @ ( n true )

