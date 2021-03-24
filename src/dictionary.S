@ dictionary.S

@ word in dictionary structure:
@ NFA: flags | length : half word: highbyte is flags, lowbyte is string length
@ NAME: string is variable length
@ LINK: 32 bit pointer to previousely defined WID
@ CODE: 32 bit pointer to executable code

@ ( -- addr )
@ current vocabulary for new words
@ pointer to WID structure
Forthword_ CURRENT_ADDR, 0, "current#"
  user_ ram_CURRENT
  end_
  
@ ( -- addr )
@ context vocabulary for searching
@ pointer to first element in array of wordlist (WID) pointers
Forthword_ CONTEXT_ADDR, 0, "context#"
  user_ ram_CONTEXT
  end_

@ ( wid -- lfa )
@ get the link field address from a wid structure
Forthword_ WID_LFA, 0, "wid.lfa"
                              @ ( nfa )
  do_ STRINGLEN               @ ( nfa+2 len+flags )
  @ mask out flags in len, allow up to 31 characters
  movs tmp1, #31
  y_d_                        @ ( len+flags ) Y:nfa+2
  ands wreg, tmp1             @ ( len )
  add_y_                      @ ( nfa+2+len )
  @ align to half word boundry
  end_do_ HALIGN

@ ( wid -- [ 0 ] | [ xt xtflags] )
@ convert wid structure address to xt and xtflags
Forthword_ WID_XTF, 0, "wid.xtf"
  push_lr_
  iszero_                     @ ( n )
  ifz_ NFATOXTF_EXIT

  y_hmw_                      @ ( nfa Y:xtflags )
  r_y_                        @ ( nfa ) (R: xtflags)
  do_ WID_LFA                 @ ( lfa )
  add_4_     @ wid.xt         @ ( xtlink )
  mw_                         @ ( xt )
  d_w_                        @ ( xt xt )
  r_                          @ ( xt xtflags )

NFATOXTF_EXIT:
  end_

@ ( addr len idx -- 0 | nfa )
FINDWI:
  mul_4_             @ ( addr len idx*4)
  y_w_               @ ( addr len idx*4 ) Y: idx*4
  do_ CONTEXT_ADDR   @ ( addr len context )
  add_y_             @ ( addr len context' )
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
  ifz_ FINDNFA_END

  @ <begin>
FINDNFA_BEGIN:
  mw_                         @ ( c-addr len nfa )
  @ <while>
FINDNFA_BEGIN1:
  iszero_                     @ ( c-addr len nfa )
  @ terminate if 0 found
  ifz_ FINDNFA_END
  r_w_                        @ ( c-addr len ) (R: nfa )
  y_d1_                       @ ( c-addr len nfa ) Y:c-addr
  x_d0_                       @ ( c-addr len nfa ) X:len
  d_y_                        @ ( c-addr len c-addr nfa )
  d_x_                        @ ( c-addr len c-addr len nfa )
  do_ STRINGLEN               @ ( c-addr len c-addr len f-addr len )
  movs tmp1, #31
  ands wreg, tmp1             @ ( c-addr len c-addr len f-addr 0:len )
  do_ MCMP                    @ ( c-addr len flag )

  iszero_
  r_                          @ ( c-addr len nfa ) (R: )
  @ match found if flag is > 0
  ifnz_ FINDNFA_END
    
  @ next try
  do_ WID_LFA                 @ ( c-addr len lfa )
  @ <repeat>
  goto_ FINDNFA_BEGIN

FINDNFA_END:
  @ we found the string
  d_sub_2_                    @ ( nfa )
  end_


@ ( addr len --  0 | nfa )
@ search root wordlists for the name from string addr/len
Forthword_ FINDROOT, 0, "froot"
  @ put root wid on stack
  push_lr_
  d_w_                      @ ( addr len len ) 
  lit32_ VE_WIPE            @ ( addr len VE_WIPE )
  end_goto_ FINDNFA_BEGIN1

@ ( -- idx )
@ get context index
Forthword_ CONTIDX_FETCH, 0 "contidx"
  user_ ram_CONTEXTidx @ ( context )
  @ get context index
  y_w_                @ ( contidx ) Y:contidx
  hmw_                @ ( idx )
  x_w_            
  d_w_                @ ( idx idx ) X:idx
  lit_ (MAX_CONTEXTS - 1) @ ( idx max )
  do_ GREATER         @ ( flag )
  iszero_
  ifz_ 1f
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
  d_w_                @ ( addr len len )
  do_ CONTIDX_FETCH   @ ( addr len idx )
  @ get context index and use as counter
  d_w_                @ ( addr len idx idx )

FINDW_BEGIN:
  iszero_
  bmi.n FINDW_LAST    @ ( addr len idx idx )
    y_d2_
    x_d1_
    d_y_
    d_x_              @ ( addr len idx addr len idx )
    do_ FINDWI        @ ( addr len idx nfa )
    iszero_
    @ end loop if word found
    ifnz_ FINDW_END

  d0_                 @ ( addr len idx idx )
  @ decrement index
  _1_sub_             @ ( addr len idx idx-1 )
  d0_w_               @ ( addr len idx-1 idx-1 )
  goto_ FINDW_BEGIN

FINDW_LAST:
  d1_                 @ ( addr len idx len )
  d_sub_2_            @ ( addr len )
  exit_do_ FINDROOT

FINDW_END:
  d_sub_3_            @ ( nfa )
  end_

@ ( -- )
@ set the context and current to root forth vocabulary and remove
@ other vocabularies
Forthword_ ONLY, IMMEDIATE_EN, "only"
  @ forth vocab always takes slot 0
  lit32_y_ EE_FORTHWORDLIST    @ ( ? ) Y:EE_FORTHWORDLIST
  do_ CURRENT_ADDR             @ ( CURRENT )
  mw_y_                        @ ( CURRENT )
  @ make current also forth vocab
  do_ CONTEXT_ADDR             @ ( CONTEXT )
  mw_y_                        @ ( CONTEXT )
  @ move index to slot 1
  _2_sub_                      @ ( CONTEXT-2 )
  lit_y_ 1                     @ ( CONTEXT-2 Y:1 )
  hmw_y_                       @ ( CONTEXT-2 )
  @ make second slot have no vocab
  add_2_                       @ ( CONTEXT )
  y_0_
  add_4_                       @ ( CONTEXT+4 )
  mw_y_
  end_
