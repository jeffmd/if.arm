@ cin.S - character input

@ ( -- addr )
@ terminal input buffer address
Forthword_ TIB, 0, "tib"
  user_  ram_tib
	bx lr

@ ( -- addr-half )
@ variable holding the number of characters in TIB
@ is half cell size
Forthword_ SHARPTIB, 0, "#tib"
  user_ ram_sharptib
  bx lr

@ ( -- addr len )
@ address and current length of the input buffer
Forthword_ STIB, 0, "stib"
  user_  ram_tib
  push_
  user_ ram_sharptib
  hmw_
  bx lr

@ ( -- a-addr )
@ index to current read position in input buffer
@ is half cell size
Forthword_ G_IN, 0, ">in"
  user_ user_g_in
  bx lr

@ ( -- keyaddr )
@ get ram address of key defer
Forthword_ KEYADDR, 0, "key#"
  user_ USER_KEY
  bx lr

@ ( -- key )
@ fetch key from standard input, should leave a single character on wreg
@ if a key was pressed. If no key pressed then -1 is on wreg.
Forthword_ STDIN, 0, "stdin"
  push {lr}
  bl getchr
  pop {pc}

@ ( -- key )
@ fetch key from deffered routine, should leave a single character
@ on wreg if a key was pressed. If no key pressed then -1 is on wreg.
Forthword_ KEY, 0, "key"
  push {lr}
  push_
  bl KEYADDR
  mw_
  pop_lr_
  b EXEC

@ ( -- )
@ Reset the input buffer
Forthword_ INRESET, 0, "in_"
  push {lr}
  bl G_IN                @ ( >inaddr )
  y_0_
  hmw_y_                 @ ( >inaddr )
  @ reset input buffer cursor position
  bl SHARPTIB            @ ( #tibaddr )
  hmw_y_                 @ ( #tibaddr )
  pop_lr_
  b QP_RD

@ ( -- flag )
@ receive a string of at most tibsize characters or cr/lf detected.
@ flag will be true if input buffer needs to be processed ie interpreted
@ flag will be false if more input needed
Forthword_ ACCEPT, 0, "accept"
    push {lr}
    @ <begin>
    @bl KEY        @ ( k )
    iszero_
    @bgt.n ACCEPT_checkeol
    oneplus_
    pop {pc}

ACCEPT_checkeol:
    @ check for EOL
    cmp wreg, #10
    @ <if>
    bne.n ACCEPT_checkreturn
    pop {pc}

ACCEPT_checkreturn:
    cmp wreg, #13     @ ( k k 13 )
    @ <if>
    bne.n ACCEPT_checkdelete
    pop {pc}

ACCEPT_checkdelete:
    @ check delete
    cmp wreg, #127      @ ( k k 8 )
    @ <if>
    bne.n ACCEPT_checkcontrol
    @ delete previous character
    @ check beginning of line
    @ if cursor is 0 then at begining of input
    push_
    bl SHARPTIB
    hmw_                @ ( k #tib )
    @ <if>
    iszero_             @ ( k )
    pop_
    bne.n ACCEPT_dodelete
    @ at the beginning of the line, ignore this character
    zero_
    pop {pc}

ACCEPT_dodelete:
    movs r1, #8
    ands wreg, r1
    push_             @ ( k k )
    bl EMIT           @ ( k ? )
    bl_               @ ( k bl )
    bl EMIT           @ ( k ? )
    pop_              @ ( k )
    bl EMIT           @ ( ? )
    @ decrease cursor position by one
    true_             @ ( true )
    y_w_              @ ( true Y:true )
    bl SHARPTIB       @ ( #tibaddr )
    x_hmw_
    x_plus_y_
    hmw_x_            @ ( #tibaddr )
    b.n ACCEPT_checkmaxinput


ACCEPT_checkcontrol:
    @ check for remaining control characters, replace them with blank
    cmp wreg, #32         @ ( k k bl )
    bge.n ACCEPT_echo
    @ replace control key with a space
    bl_

ACCEPT_echo:
    @ emit the key
    push_                @ ( k k )
    bl EMIT              @ ( k ? )
    @ now store the key in the input buffer
    bl STIB              @ ( k tibaddr #tib)
    y_d0_                @ ( k tibaddr #tib) Y: tibaddr
    w_plus_y_            @ ( k tibaddr tibaddr+#tib )
    x_d1_                @ ( k tibaddr tibaddr+#tib ) X: k
    cmw_x_               @ ( k tibaddr tibaddr+#tib )
    nip2_                @ ( tibaddr+#tib )

    bl SHARPTIB          @ ( #tibaddr )
    y_hmw_
    y_plus1_
    hmw_y_               @ ( ? )

ACCEPT_checkmaxinput:
    @ check if max number of char input
    bl SHARPTIB          @ ( #tibaddr )
    y_hmw_               @ ( tibsize #tib )
    lit_ TIBSIZE         @ ( tibsize )
    w_minus_y_           @ ( tibsize-#tib )
    @ <if>
    iszero_              @ ( tibsize-#tib )
    beq.n ACCEPT_atmaxinput
    zero_
    pop {pc}

ACCEPT_atmaxinput:
    @ max number of characters in input buffer so have it processed
    true_
    pop {pc}

@ ( -- f )
@ refills the input buffer - flag is true if buffer has something
Forthword_ REFILLTIB, 0, "reftib"
    push {lr}
    bl ACCEPT                  @ ( f )
    iszero_                    @ ( f )
    beq.n REFILLTIB_exit
    push_
    bl CR
    pop_
    
REFILLTIB_exit:
    pop {pc}

@ ( -- f )
@ refills the input buffer
Forthword_ REFILL, 0, "refill"
  b REFILLTIB

