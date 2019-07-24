@ core-base.S

@ ( xt -- )
@ execute XT
Forthword_ EXEC, 0, "exec"
    movs yreg, #1
    @ make sure its a thumb address mode
    orrs yreg, wreg
    pop_
    bx yreg

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

@ ( n1 -- n2/2 )
@ convert byte length to half word align length
@ round number up to even value
Forthword_ HALIGN, 0, "h_"
  oneplus_
  movs r1, #1
  mvns r1, r1
  ands wreg, r1
  bx lr

@ ( -- 32b )
@ fetch a 32 bit constant inlinned pointed to by lr onto the top of stack
@ assumes caller was in thumb mode
Forthword_ CIFETCH, 0, "ci@"
  mov r1, lr
  subs r1, #1     @ clear bit 0 which is thumb indicator
  ldr wreg, [r1]
  adds r1, #5     @ return after constant and default to thumb mode
  bx r1
