@ dictionary.S

@ dictionary structure:
@ length | flags : word: highbyte is flags, lowbyte is string length
@ name : string is variable length
@ previouse word: 32 bit pointer to previousely defined word
@ code: 32 bit pointer to executable code

@ ( -- addr )
@ current vocabulary for new words
Forthword_ CURRENT, 0, "current"
    douser_ ram_CURRENT

@ ( -- addr )
@ context vocabulary for searching
@ array of wordlists
Forthword_ CONTEXT, 0, "context"
    douser_ ram_CONTEXT

@ ( nfa -- lfa )
@ get the link field address from the name field address
Forthword_ NFA2LFA, 0, "nfa>lfa"
    push {lr}                   @ ( nfa )
    bl STRINGLEN                @ ( nfa+2 len+flags )
    @ mask out flags in len, allow up to 31 characters
    movs r0, #31
    ands wreg, r0                 @ ( nfa+2 len )
    bl WALIGN
    plus_
    pop {pc}

@ ( nfa -- [ 0 ] | [ xt xtflags] )
@ convert name field address to xt and xtflags
Forthword_ NFATOXTF, 0, "nfa>xtf"
    push {lr}
    dupzerosense_               @ ( n )
    beq.n NFATOXTF_EXIT

    push_                        @ ( nfa nfa )
    hfetch_                     @ ( nfa xtflags )
    to_r_                       @ ( nfa ) (R: xtflags)
    bl NFA2LFA                  @ ( lfa )
    fourplus_   @ lfa>xt        @ ( xt )
    r_from_                     @ ( xt xtflags )

NFATOXTF_EXIT:
    pop {pc}

@ ( c-addr len wid -- [ 0 | nfa ] )
@ find a word in the dictionary
@ 0 if word not found in dictionary
@ nfa if word is found
Forthword_ FINDNFA, 0, "findnfa"
    push {lr}
    dupzerosense_
    bne.n FINDNFA_
      @ terminating, wid is empty
      dnip_
      pop {pc}
FINDNFA_:
    fetch_                      @ ( c-addr len nfa )

    @ <begin>
FINDNFA_BEGIN:
    @ <while>
    dupzerosense_               @ ( c-addr len nfa )
    bne.n FINDNFA_CHECK
      @ terminating, 0 found
      dnip_                     @ ( 0 )
      pop {pc}

FINDNFA_CHECK:
    to_r_                       @ ( c-addr len ) (R: nfa )
    bl TWOOVER                  @ ( c-addr len c-addr len )
    r_fetch_                    @ ( c-addr len c-addr len nfa )
    bl STRINGLEN                @ ( c-addr len c-addr len f-addr len )
    movs r0, #31
    ands wreg, r0                 @ ( c-addr len c-addr len f-addr 0:len )
    bl MCMP                     @ ( c-addr len flag )
    @ <if>
    zerosense_
    beq.n FINDNFA_NEXT
      @ we found the string
      ddrop_                    @ ( )
      r_from_                   @ ( nfa )
      pop {pc}
    @ <then>
FINDNFA_NEXT:
      @ next try
      r_from_
      bl NFA2LFA
      fetch_
      @ <repeat>
      b.n FINDNFA_BEGIN


@ ( addr len --  0 | nfa )
@ search root wordlists for the name from string addr/len
Forthword_ FINDROOT, 0, "froot"
    push {lr}
    @ put root wid on stack
    dolit32_ VE_COLD
    b.n FINDNFA_BEGIN

@ ( addr len idx -- 0 | nfa )
FINDWI:
      push {lr}
      fourstar_          @ ( addr len idx*4)
      bl CONTEXT         @ ( addr len idx*4 context )
      plus_              @ ( addr len context' )
      fetch_             @ ( addr len wid )
      pop_lr_
      b FINDNFA         @ ( nfa)

FINDLAST:
      pop_
      pop_lr_
      b FINDROOT

@ ( addr len --  0 | nfa )
@ search wordlists for the name from string addr/len
Forthword_ FINDW, 0, "findw"
    push {lr}
    @ loop through context slots to find a word
    @ start with last slot
    bl CONTEXT          @ ( addr len context )
    @ get context index and use as counter
    twominus_           @ ( addr len context-2 )
    hfetch_             @ ( addr len idx )
FINDW_BEGIN:
    dupzerosense_
    bmi.n FINDLAST        @ ( addr len idx )
      to_r_             @ ( addr len ) ( R: idx )
      bl TWOOVER        @ ( addr len addr len ) ( R: idx )
      @ get next wordlist in array
      r_fetch_          @ ( addr len addr len idx ) ( R: idx)
      bl FINDWI
      r_from_           @ ( addr len nfa idx ) ( R: )
      swap_             @ ( addr len idx nfa )
      dupzerosense_
      @ end loop if word found
      beq.n FINDW_NEXT
        dnip_           @ ( addr nfa )
        nip_            @ ( nfa )
        pop {pc}

FINDW_NEXT:
      pop_             @ ( addr len idx )
      @ decrement index
      oneminus_         @ ( addr len idx-1 )
      b.n FINDW_BEGIN

@ ( -- )
@ set the context and current to root forth vocabulary and remove
@ other vocabularies
Forthword_ ONLY, IMMEDIATE_EN, "only"
    push {lr}
    @ forth vocab always takes slot 0
    dolit32_ EE_FORTHWORDLIST
    push_
    bl CONTEXT
    bl STORE
    @ make current also forth vocab
    bl CURRENT
    bl STORE
    @ move index to next slot
    one_
    bl CONTEXT
    twominus_
    bl HSTORE
    @ make second slot have no vocab
    bl CONTEXT
    fourplus_
    pop_lr_
    b ZEROSTORE
