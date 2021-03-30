@ cin.S - character input

@ ( -- n )
@ the number of characters (write position) in TIB
Forthword_ TIB_W, 0, "tib.w"
  user_ ram_tib_w
  hmw_
  end_

@ ( n -- Y:n )
@ set write index to current write position in input buffer
Forthword_ TIB_W_STR, 0, "tib.w="
  y_w_
  user_ ram_tib_w
  hmw_y_
  end_

@ ( -- )
@ decrement write index
Forthword_ TIB_W_DEC, 0, "tib.w--"
  user_ ram_tib_w
  y_hmw_
  y_sub_1_
  hmw_y_
  end_

@ ( -- )
@ increment write index
Forthword_ TIB_W_INC, 0, "tib.w++"
  user_ ram_tib_w
  y_hmw_
  y_add_1_
  hmw_y_
  end_

@ ( -- addr len )
@ address and current write position (length) in the input buffer
Forthword_ TIBW, 0, "tibw"
  user_  ram_tib
  d_w_
  user_ ram_tib_w
  hmw_
  end_

@ ( -- idx )
@ index to current read position in input buffer
@ is half cell size
Forthword_ TIB_R, 0, "tib.r"
  user_ ram_tib_r
  hmw_
  end_

@ ( n -- Y:n )
@ set index to current read position in input buffer
Forthword_ TIB_R_STR, 0, "tib.r="
  y_w_
  user_ ram_tib_r
  hmw_y_
  end_

@ ( n -- ribaddr Y:n )
@ add n to read index of input buffer
Forthword_ TIB_R_ADD_STR, 0, "tib.r+="
  y_w_
  user_ ram_tib_r
  x_hmw_
  x_add_y_
  hmw_x_
  end_

@ ( k ? -- )
@ put key character in input buffer
Forthword_ TIB_STR, 0, "tib="
  do_ TIBW             @ ( k tibaddr wib )
  y_d0_                @ ( k tibaddr wib ) Y:tibaddr
  x_d1_                @ ( k tibaddr wib ) X:k
  add_y_               @ ( k tibaddr tibaddr+wib )
  cmw_x_               @ ( k tibaddr tibaddr+wib )
  d_sub_2_             @ ( tibaddr+wib )

  end_do_ TIB_W_INC    @ ( #tibaddr )
  

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
Forthword_ TIB_RST, 0, "tib.rst"
  zero_
  @ reset input buffer read position
  do_ TIB_R_STR         @ ( rib_addr Y:0 )
  @ reset input buffer write position
  y_
  do_ TIB_W_STR         @ ( #tibaddr )
  end_do_ QP_RD

@ ( -- srcaddr len  )
@ Adjust the TIB source addr using tib.r to get the next read location and length.
Forthword_ TIB_STRING, 0, "tib.$"
  do_ TIBW             @ ( srcaddr len )
  d_w_                 @ ( srcaddr len len)
  do_ TIB_R            @ ( srcaddr len tib.r )
  end_do_ SLASHSTRING  @ ( srcaddr' len' )

@ ( -- flag )
@ get a key and edit buffer
@ at most tibsize characters or cr/lf detected.
@ flag will be true if input buffer needs to be processed ie interpreted
@ flag will be false if more input can be handled
Forthword_ TIB_EDIT, 0, "tib.edit"
  @ <begin>
  do_ KEY        @ ( k )
  iszero_
  bgt.n TIB_EDIT_checkeol
  add_1_
  exit_

TIB_EDIT_checkeol:
  @ check for EOL
  cmp wreg, #10
  @ <if>
  ifnz_ TIB_EDIT_checkreturn
  exit_

TIB_EDIT_checkreturn:
  cmp wreg, #13     @ ( k k 13 )
  @ <if>
  ifnz_ TIB_EDIT_checkdelete
  exit_

TIB_EDIT_checkdelete:
  @ check delete
  cmp wreg, #127      @ ( k k 8 )
  @ <if>
  ifnz_ TIB_EDIT_checkcontrol
  @ delete previous character
  @ check beginning of line
  @ if cursor is 0 then at begining of input
  d_w_
  do_ TIB_W           @ ( k wib )
  @ <if>
  iszero_             @ ( k wib )
  d_                  @ ( k )
  ifnz_ TIB_EDIT_dodelete
  @ at the beginning of the line, ignore this character
  zero_
  exit_

TIB_EDIT_dodelete:
  movs tmp1, #8
  ands wreg, tmp1
  d_w_                @ ( k k )
  do_ EMIT            @ ( k ? )
  bl_                 @ ( k bl )
  do_ EMIT            @ ( k ? )
  d_                  @ ( k )
  do_ EMIT            @ ( ? )
  @ decrease cursor position by one
  do_ TIB_W_DEC       @ ( #tibaddr )
  goto_ TIB_EDIT_checkmaxinput


TIB_EDIT_checkcontrol:
  @ check for remaining control characters, replace them with blank
  cmp wreg, #32       @ ( k k bl )
  bge.n TIB_EDIT_echo
  @ replace control key with a space
  bl_

TIB_EDIT_echo:
  @ emit the key
  d_w_                @ ( k k )
  do_ EMIT            @ ( k ? )
  @ now store the key in the input buffer
  do_ TIB_STR         @ ( ? )

TIB_EDIT_checkmaxinput:
  @ check if max number of char input
  do_ TIB_W           @ ( wib )
  y_w_                @ ( wib Y:wib )
  lit_ TIBSIZE        @ ( tibsize )
  sub_y_              @ ( tibsize-wib )
  @ <if>
  iszero_             @ ( tibsize-#tib )
  ifz_ TIB_EDIT_end
  zero_
  exit_

TIB_EDIT_end:
  @ max number of characters in input buffer so have it processed
  true_
  end_

@ ( -- f )
@ fills the input buffer - flag is true if buffer has something
Forthword_ TIB_FILL, 0, "tib.fill"
    do_ TIB_EDIT          @ ( f )
    iszero_              @ ( f )
    ifz_ TIB_FILL_exit
    d_w_
    do_ CR
    d_
    
TIB_FILL_exit:
    end_

@ ( -- f )
@ fill the input buffer
Forthword_ CIN, 0, "cin"
  end_do_ TIB_FILL

@ ( -- flag )
@ refill the input buffer
@ flag is true if buffer needs processing ie full or enter pressed
Forthword_ DO_CIN, 0, "(cin)"
  @ if just starting new input line then check prompt and reset input position
  do_ TIB_R                @ ( rib )
  iszero_                  @ ( )
  ifz_ DO_CIN_do
    do_ TIB_RST

DO_CIN_do:
  @ try to fill the input buffer
  end_do_ CIN           @ ( f )



