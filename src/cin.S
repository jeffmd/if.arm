@ cin.S - character input

@ ( -- n )
@ the number of characters (write position) in TIB
Forthword_ WIB, 0, "wib"
  user_ ram_wib
  hmw_
  end_

@ ( n -- Y:n )
@ set write index to current write position in input buffer
Forthword_ WIB_STR, 0, "wib="
  y_w_
  user_ ram_wib
  hmw_y_
  end_

@ ( -- )
@ decrement write index
Forthword_ WIB_DEC, 0, "wib--"
  user_ ram_wib
  y_hmw_
  y_sub_1_
  hmw_y_
  end_

@ ( -- )
@ increment write index
Forthword_ WIB_INC, 0, "wib++"
  user_ ram_wib
  y_hmw_
  y_add_1_
  hmw_y_
  end_

@ ( -- addr len )
@ address and current write position (length) in the input buffer
Forthword_ STIB, 0, "stib"
  user_  ram_tib
  d_w_
  user_ ram_wib
  hmw_
  end_

@ ( -- idx )
@ index to current read position in input buffer
@ is half cell size
Forthword_ RIB, 0, "rib"
  user_ ram_rib
  hmw_
  end_

@ ( n -- Y:n )
@ set index to current read position in input buffer
Forthword_ RIB_STR, 0, "rib="
  y_w_
  user_ ram_rib
  hmw_y_
  end_

@ ( n -- ribaddr Y:n )
@ add n to read index of input buffer
Forthword_ RIB_PLUS_STR, 0, "rib+="
  y_w_
  user_ ram_rib
  x_hmw_
  x_add_y_
  hmw_x_
  end_

@ ( k ? -- )
@ put key character in input buffer
Forthword_ TIB_STR, 0, "tib="
  do_ STIB             @ ( k tibaddr wib )
  y_d0_                @ ( k tibaddr wib ) Y:tibaddr
  x_d1_                @ ( k tibaddr wib ) X:k
  add_y_              @ ( k tibaddr tibaddr+wib )
  cmw_x_               @ ( k tibaddr tibaddr+wib )
  d_sub_2_             @ ( tibaddr+wib )

  end_do_ WIB_INC      @ ( #tibaddr )
  

@ ( -- keyaddr )
@ get ram address of key defer
Forthword_ KEYADDR, 0, "key#"
  user_ USER_KEY
  end_

@ ( -- key )
@ fetch key from standard input, should leave a single character on wreg
@ if a key was pressed. If no key pressed then -1 is on wreg.
Forthword_ STDIN, 0, "stdin"
  do_ getchr
  end_

@ ( -- key )
@ fetch key from deffered routine, should leave a single character
@ on wreg if a key was pressed. If no key pressed then -1 is on wreg.
Forthword_ KEY, 0, "key"
  d_w_
  do_ KEYADDR
  mw_
  end_do_ EXEC

@ ( -- )
@ Reset the input buffer
Forthword_ INRESET, 0, "in_"
  zero_
  @ reset input buffer read position
  do_ RIB_STR           @ ( rib_addr Y:0 )
  @ reset input buffer write position
  y_
  do_ WIB_STR           @ ( #tibaddr )
  end_do_ QP_RD

@ ( -- flag )
@ receive a string of at most tibsize characters or cr/lf detected.
@ flag will be true if input buffer needs to be processed ie interpreted
@ flag will be false if more input needed
Forthword_ ACCEPT, 0, "accept"
  @ <begin>
  do_ KEY        @ ( k )
  iszero_
  bgt.n ACCEPT_checkeol
  add_1_
  exit_

ACCEPT_checkeol:
  @ check for EOL
  cmp wreg, #10
  @ <if>
  ifnz_ ACCEPT_checkreturn
  exit_

ACCEPT_checkreturn:
  cmp wreg, #13     @ ( k k 13 )
  @ <if>
  ifnz_ ACCEPT_checkdelete
  exit_

ACCEPT_checkdelete:
  @ check delete
  cmp wreg, #127      @ ( k k 8 )
  @ <if>
  ifnz_ ACCEPT_checkcontrol
  @ delete previous character
  @ check beginning of line
  @ if cursor is 0 then at begining of input
  d_w_
  do_ WIB             @ ( k wib )
  @ <if>
  iszero_             @ ( k wib )
  d_                  @ ( k )
  ifnz_ ACCEPT_dodelete
  @ at the beginning of the line, ignore this character
  zero_
  exit_

ACCEPT_dodelete:
  movs tmp1, #8
  ands wreg, tmp1
  d_w_                @ ( k k )
  do_ EMIT            @ ( k ? )
  bl_                 @ ( k bl )
  do_ EMIT            @ ( k ? )
  d_                  @ ( k )
  do_ EMIT            @ ( ? )
  @ decrease cursor position by one
  do_ WIB_DEC         @ ( #tibaddr )
  goto_ ACCEPT_checkmaxinput


ACCEPT_checkcontrol:
  @ check for remaining control characters, replace them with blank
  cmp wreg, #32         @ ( k k bl )
  bge.n ACCEPT_echo
  @ replace control key with a space
  bl_

ACCEPT_echo:
  @ emit the key
  d_w_                 @ ( k k )
  do_ EMIT             @ ( k ? )
  @ now store the key in the input buffer
  do_ TIB_STR          @ ( ? )
ACCEPT_checkmaxinput:
  @ check if max number of char input
  do_ WIB              @ ( wib )
  y_w_                 @ ( wib Y:wib )
  lit_ TIBSIZE         @ ( tibsize )
  sub_y_               @ ( tibsize-wib )
  @ <if>
  iszero_              @ ( tibsize-#tib )
  ifz_ ACCEPT_atmaxinput
  zero_
  exit_

ACCEPT_atmaxinput:
  @ max number of characters in input buffer so have it processed
  true_
  end_

@ ( -- f )
@ refills the input buffer - flag is true if buffer has something
Forthword_ REFILLTIB, 0, "reftib"
    do_ ACCEPT           @ ( f )
    iszero_              @ ( f )
    ifz_ REFILLTIB_exit
    d_w_
    do_ CR
    d_
    
REFILLTIB_exit:
    end_

@ ( -- f )
@ refills the input buffer
Forthword_ REFILL, 0, "refill"
  end_do_ REFILLTIB

