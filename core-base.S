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
  end_

@ ( u1 u2 -- flag )
@ flag is true if u1 > u2 (unsigned)
Forthword_ UGREATER, 0, "u>"
  popy_
  subs wreg, yreg
  sbcs wreg, wreg
  end_

@ ( u1 u2 -- flag)
@ flag is true if u1 < u2 (unsigned)
Forthword_ ULESS, 0, "u<"
  popy_
  subs wreg, yreg, wreg
@ wreg = a-b  -- carry set if a is less than b
  sbcs wreg, wreg
  end_

@ ( n1 -- n2 )
@ convert byte length to half word align length
@ round number up to even value
Forthword_ HALIGN, 0, "h_"
  oneplus_
  movs r1, #1
  mvns r1, r1
  ands wreg, r1
  end_
