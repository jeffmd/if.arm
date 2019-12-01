@ dictionary.S

@ dictionary structure:
@ length | flags : word: highbyte is flags, lowbyte is string length
@ name : string is variable length
@ previouse word: 32 bit pointer to previousely defined word
@ code: 32 bit pointer to executable code

@ ( -- addr )
@ current vocabulary for new words
Forthword_ CURRENT, 0, "current"
  user_ ram_CURRENT
  end_
  
@ ( -- addr )
@ context vocabulary for searching
@ array of wordlists
Forthword_ CONTEXT, 0, "context"
  user_ ram_CONTEXT
  end_

@ ( nfa -- lfa )
@ get the link field address from the name field address
Forthword_ NFA2LFA, 0, "nfa>lfa"
                              @ ( nfa )
  do_ STRINGLEN               @ ( nfa+2 len+flags )
  @ mask out flags in len, allow up to 31 characters
  movs r1, #31
  popy_                       @ ( len+flags ) Y:nfa+2
  ands wreg, r1               @ ( len )
  w_plus_y_                   @ ( nfa+2+len )
  @ align to half word boundry
  end_do_ HALIGN

@ ( nfa -- [ 0 ] | [ xt xtflags] )
@ convert name field address to xt and xtflags
Forthword_ NFATOXTF, 0, "nfa>xtf"
  push_lr_
  iszero_                     @ ( n )
  beq.n NFATOXTF_EXIT

  y_hmw_                      @ ( nfa Y:xtflags )
  rpushy_                     @ ( nfa ) (R: xtflags)
  do_ NFA2LFA                 @ ( lfa )
  fourplus_   @ lfa>xt        @ ( xtlink )
  mw_                         @ ( xt )
  push_                       @ ( xt xt )
  rpop_                       @ ( xt xtflags )

NFATOXTF_EXIT:
  end_

@ ( addr len idx -- 0 | nfa )
FINDWI:
  fourstar_          @ ( addr len idx*4)
  y_w_               @ ( addr len idx*4 ) Y: idx*4
  do_ CONTEXT        @ ( addr len context )
  w_plus_y_          @ ( addr len context' )
  mw_                @ ( addr len wid )
  end_next_

@ ( c-addr len wid -- 0 | nfa )
@ find a word in the dictionary
@ 0 if word not found in dictionary
@ nfa if word is found
Forthword_ FINDNFA, 0, "findnfa"
  push_lr_
  iszero_
  @ terminate if wid is empty
  if_0_ FINDNFA_END

  @ <begin>
FINDNFA_BEGIN:
  mw_                         @ ( c-addr len nfa )
  @ <while>
FINDNFA_BEGIN1:
  iszero_                     @ ( c-addr len nfa )
  @ terminate if 0 found
  if_0_ FINDNFA_END
  rpush_                      @ ( c-addr len ) (R: nfa )
  y_d1_                       @ ( c-addr len nfa ) Y:c-addr
  x_d0_                       @ ( c-addr len nfa ) X:len
  pushy_                      @ ( c-addr len c-addr nfa )
  pushx_                      @ ( c-addr len c-addr len nfa )
  do_ STRINGLEN               @ ( c-addr len c-addr len f-addr len )
  movs r1, #31
  ands wreg, r1               @ ( c-addr len c-addr len f-addr 0:len )
  do_ MCMP                    @ ( c-addr len flag )

  iszero_
  rpop_                       @ ( c-addr len nfa ) (R: )
  @ match found if flag is > 0
  if_not_0_ FINDNFA_END
    
  @ next try
  do_ NFA2LFA                @ ( c-addr len lfa )
  @ <repeat>
  goto_ FINDNFA_BEGIN

FINDNFA_END:
  @ we found the string
  nip2_                     @ ( nfa )
  end_


@ ( addr len --  0 | nfa )
@ search root wordlists for the name from string addr/len
Forthword_ FINDROOT, 0, "froot"
  @ put root wid on stack
  push_                     @ ( addr len len ) 
  lit32_ VE_WIPE            @ ( addr len VE_WIPE )
  end_goto_ FINDNFA_BEGIN1

@ ( -- idx )
@ get context index
Forthword_ CONTIDX_FETCH, 0 "contidx@"
  do_ CONTEXT         @ ( context )
  @ get context index
  twominus_           @ ( context-2 )
  y_w_                @ ( contidx ) Y:contidx
  hmw_                @ ( idx )
  x_w_            
  push_               @ ( idx idx ) X:idx
  lit_ (MAX_CONTEXTS - 1) @ ( idx max )
  do_ GREATER         @ ( flag )
  iszero_
  if_0_ 1f
    lit_ (MAX_CONTEXTS - 1)  @ ( max )
    hmy_w_
    exit_
1:
  x_                  @ ( idx )
  end_


@ ( addr len --  0 | nfa )
@ search wordlists for the name from string addr/len
Forthword_ FINDW, 0, "findw"
  @ loop through context slots to find a word
  @ start with last slot
  push_               @ ( addr len len )
  do_ CONTIDX_FETCH   @ ( addr len idx )
  @ get context index and use as counter
  push_               @ ( addr len idx idx )

FINDW_BEGIN:
  iszero_
  bmi.n FINDW_LAST      @ ( addr len idx idx )
    y_d2_
    x_d1_
    pushy_
    pushx_            @ ( addr len idx addr len idx )
    do_ FINDWI        @ ( addr len idx nfa )
    iszero_
    @ end loop if word found
    if_not_0_ FINDW_END

  d0_                 @ ( addr len idx idx )
  @ decrement index
  oneminus_           @ ( addr len idx idx-1 )
  d0_w_               @ ( addr len idx-1 idx-1 )
  goto_ FINDW_BEGIN

FINDW_LAST:
  d1_                       @ ( addr len idx len )
  nip2_                     @ ( addr len )
  exit_do_ FINDROOT

FINDW_END:
  nip3_               @ ( nfa )
  end_

@ ( -- )
@ set the context and current to root forth vocabulary and remove
@ other vocabularies
Forthword_ ONLY, IMMEDIATE_EN, "only"
  @ forth vocab always takes slot 0
  lit32_y_ EE_FORTHWORDLIST    @ ( ? ) Y:EE_FORTHWORDLIST
  do_ CURRENT                  @ ( CURRENT )
  mw_y_                        @ ( CURRENT )
  @ make current also forth vocab
  do_ CONTEXT                  @ ( CONTEXT )
  mw_y_                        @ ( CONTEXT )
  @ move index to slot 1
  twominus_                    @ ( CONTEXT-2 )
  lit_y_ 1                     @ ( CONTEXT-2 Y:1 )
  hmw_y_                       @ ( CONTEXT-2 )
  @ make second slot have no vocab
  twoplus_                     @ ( CONTEXT )
  y_0_
  fourplus_                    @ ( CONTEXT+4 )
  mw_y_
  end_
    
