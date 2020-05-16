@ include.S

@ ( -- keyfileaddr )
@ get ram address of key file descriptor
Forthword_ KEYFILEADDR, 0, "keyf#"
  user_ USER_KEYFILE
  end_

@ ( -- key )
@ fetch key from an open file using filedes, should leave
@ a single character on wreg or -1 if no more to read in file.
Forthword_ KEYFILE, 0, "keyfile"
  push_lr_
  do_ KEYFILEADDR        @ ( KEYFILEADDR )
  mw_                    @ ( KEYFILEDES )
  y_0_                   @ ( KEYFILEDES ) Y:0
  d_y_                   @ ( 0 KEYFILEDES )
  movs r1, dsp           @ dsp points to buffer that read will write to
  movs r2, #1
  do_ read               @ ( key count ) 
  @ was one key read from the file?
  cmp wreg, #1
  w_d_                   @ ( key )
  ifz_ KEYEND
    oneminus_
    exit_do_ BYE  

 KEYEND:
  end_

@ ( caddr -- ** )
@ open a file that will be used for key input
@ caddr points to null terminated file name
Forthword_ DOINCLUDE, 0, "(include)"
  push_lr_
  @ set file open mode to reading
  x_0_
  do_ open             @ ( filedes )
  @ if file descriptor > 0 then open is success
  d_w_                 @ ( filedes filedes )
  do_ GREATERZERO      @ ( filedes flag )
  iszero_
  ifz_ DOINCLUDE_EXIT

  do_ IDLETIME         @ ( filedes itime )
  r_w_                 @ ( filedes itime ) (R: itime )
  do_ SLEEPOFF         @ ( filedes ? )

  @ push FFLAGS on tor
  do_ FFLAGS           @ ( filedes fflags# )
  hmw_                 @ ( filedes fflags )
  r_w_                 @ ( filedes fflags ) (R: itime fflags )

  @ push on return stack the old defer key
  do_ KEYADDR          @ ( filedes KEYADDR )
  x_w_                 @ ( filedes KEYADDR X:KEYADDR)
  mw_                  @ ( filedes KEY )
  r_w_                 @ ( filedes KEY ) (R: itime fflags KEY)

  @ defer key to keyfile for input
  lit32_ KEYFILE       @ ( filedes KEYFILE )
  mx_w_                @ ( KEYFILE )

  @ push old keyfile on return stack
  do_ KEYFILEADDR      @ ( filedes KEYFILEADDR ) (R: itime fflags KEY)
  x_w_
  mw_                  @ ( filedes KEYFILE ) (R: itime fflags KEY)
  r_w_                 @ ( filedes KEYFILE ) (R: itime fflags KEY KEYFILE)
  w_d_                 @ ( filedes )
  mx_w_                @ ( filedes )


  @ run interpreter
  do_ DOTASKS

  @ close keyfile
  do_ KEYFILEADDR      @ ( KEYFILEADDR )
  mw_                  @ ( KEYFILE )
  do_ close            @ ( ? )

  @ restore old keyfile descriptor
  y_r_                 @  ( ? Y: KEYFILE ) ( R: itime fflags KEY )
  bl KEYFILEADDR       @ ( KEYFILEADDR )
  mw_y_                @ ( KEYFILEADDR )

  @ restore old key function
  x_r_                 @ ( KEYFILEADDR X:KEY ) ( R: itime fflags )
  do_ KEYADDR          @ ( KEYADDR )
  mw_x_                @ ( KEYADDR )

  @ restore FFLAGS
  y_r_                 @ ( KEYADDR Y:fflags ) ( R: itime )
  do_ FFLAGS           @ ( FFLAGS )
  hmw_y_               @ ( FFLAGS )
  w_r_                 @ ( itime ) ( R: )
  exit_do_ IDLETIME_STR
       
DOINCLUDE_EXIT:
  w_d_                 @ ( filedes )
  type_ "File not found!"
  end_

@ ( C:filepath -- ** )
@ open a file that will be used for key input
Forthword_ INCLUDEF, 0, "include"
  @ parse input for filename to include
  do_ PNAME     @ ( addr len )
  @ add null to end of string
  y_d0_         @ ( addr len ) Y: addr
  x_0_
  w_plus_y_     @ ( addr addr' )
  cmw_x_        @ ( addr addr' )
  w_d_          @ ( addr )
  end_do_ DOINCLUDE
