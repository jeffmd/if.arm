@ core-base.S

@ ( xt -- )
@ execute XT
Forthword_ EXEC, 0, "exec"
    movs r1, #1
    @ make sure its a thumb address mode
    orrs r1, wreg
    pop_
    bx r1

@ ( xx -- xx)
@ Don't do anything, just chew up a few cycles
Forthword_ NOOP, INLINE_OPT, "noop"
    ands wreg, wreg
    bx lr

@ ( u1 u2 -- flag )
@ flag is true if u1 > u2 (unsigned)
Forthword_ UGREATER, 0, "u>"
  popy_
  subs wreg, yreg
  sbcs wreg, wreg
  bx lr

@ ( u1 u2 -- flag)
@ flag is true if u1 < u2 (unsigned)
Forthword_ ULESS, 0, "u<"
  popy_
  subs wreg, yreg, wreg
@ wreg = a-b  -- carry set if a is less than b
  sbcs wreg, wreg
  bx lr

@ ( n1 -- n2 )
@ convert byte length to half word align length
@ round number up to even value
Forthword_ HALIGN, 0, "h_"
  oneplus_
  movs r1, #1
  mvns r1, r1
  ands wreg, r1
  bx lr

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr into working register
@ assumes caller was in thumb mode
Forthword_ W_MI, 0, "@i"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr wreg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr into Y register
@ assumes caller was in thumb mode
Forthword_ Y_MI, 0, "y=@i"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr yreg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr into X register
@ assumes caller was in thumb mode
Forthword_ X_MI, 0, "x=@i"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr xreg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr into A register
@ assumes caller was in thumb mode
Forthword_ A_MI, 0, "a=@i"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr areg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr into B register
@ assumes caller was in thumb mode
Forthword_ B_MI, 0, "b=@i"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr breg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1
