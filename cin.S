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
    hfetch_
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
  b getchar

@ ( -- key )
@ fetch key from an open file using filedes, should leave
@ a single character on wreg or -1 if no more to read in file.
Forthword_ KEYFILE, 0, "keyfile"
  push {lr}
  bl KEYFILEADDR
  fetch_
  movs r0, wreg
  movs wreg, #0
  push_
  mov r1, dsp
  movs r2, #1
  bl read 
  pop_
  @ was one key read from the file?
  cmp r0, #1
  beq.n KEYEND
  subs wreg, #1
  bl BYE  
 KEYEND:
  pop {pc}

@ ( -- key )
@ fetch key from deffered routine, should leave a single character
@ on wreg if a key was pressed. If no key pressed then -1 is on wreg.
Forthword_ KEY, 0, "key"
  push {lr}
  push_
  bl KEYADDR
  fetch_
  pop_lr_
  b EXEC

@ ( -- f )
@ refills the input buffer
Forthword_ REFILL, 0, "refill"
  b REFILLTIB

@ ( -- )
@ Reset the input buffer
Forthword_ INRESET, 0, "in_"
  push {lr}
  bl G_IN                @ ( >inaddr )
  bl ZEROHSTORE          @ (  )
  @ reset input buffer cursor position
  bl SHARPTIB            @ ( #tibaddr )
  bl ZEROHSTORE          @ ( )
  pop_lr_
  b QP_RD

@ ( -- flag )
@ receive a string of at most tibsize characters or cr/lf detected.
@ flag will be true if input buffer needs to be processed ie interpreted
@ flag will be false if more input needed
Forthword_ ACCEPT, 0, "accept"
    push {lr}
    @ <begin>
    bl KEY        @ ( k )
    dupzerosense_
    bgt.n ACCEPT_haskey
    adds wreg, #1
    pop {pc}

ACCEPT_haskey:
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
    bl SHARPTIB
    hfetch_          @ ( k #tib )
    @ <if>
    zerosense_            @ ( k )
    bne.n ACCEPT_dodelete
    @ at the beginning of the line, ignore this character
    pop_
    pop_lr_
    b ZERO

ACCEPT_dodelete:
    movs r0, #8
    ands wreg, r0
    push_              @ ( k k )
    bl EMIT           @ ( k )
    bl_               @ ( k bl )
    bl EMIT           @ ( k )
    bl EMIT           @ ( )
    @ decrease cursor position by one
    bl TRUE           @ ( -1 )
    bl SHARPTIB       @ ( -1 #tibaddr )
    bl PLUSHSTORE     @ ( )
    b.n ACCEPT_checkmaxinput


ACCEPT_checkcontrol:
    @ check for remaining control characters, replace them with blank
    cmp wreg, #32         @ ( k k bl )
    bge.n ACCEPT_echo
    pop_
    @ replace control key with a space
    bl_

ACCEPT_echo:
    @ emit the key
    push_                 @ ( k k)
    bl EMIT              @ ( k)
    @ now store the key in the input buffer
    bl STIB              @ ( k tibaddr #tib)
    plus_                @ ( k tibaddr+#tib )
    bl CSTORE            @ ( )

    bl SHARPTIB          @ ( 1 #tibaddr )
    bl ONEPLUSHSTORE     @ ( )

ACCEPT_checkmaxinput:
    @ check if max number of char input
    dolit8_ TIBSIZE   @ ( tibsize )
    bl SHARPTIB          @ ( tibsize #tibaddr )
    bl HFETCH            @ ( tibsize #tib)
    minus_               @ ( tibsize-#tib)
    @ <if>
    zerosense_           @ ( )
    beq.n ACCEPT_atmaxinput
    pop_lr_
    b ZERO

ACCEPT_atmaxinput:
    @ max number of characters in input buffer so have it processed
    pop_lr_
    b TRUE

@ ( -- f )
@ refills the input buffer - flag is true if buffer has something
Forthword_ REFILLTIB, 0, "reftib"
    push {lr}
    bl ACCEPT                  @ ( f )
    dupzerosense_              @ ( f )
    beq.n REFILLTIB_exit
    bl CR

REFILLTIB_exit:
    pop {pc}
