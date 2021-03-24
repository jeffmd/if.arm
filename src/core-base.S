@ core-base.S

@ ( xt -- )
@ execute XT
Forthword_ EXEC, 0, "exec"
  movs tmp1, #1
  @ make sure its a thumb address mode
  orrs tmp1, wreg
  d_
  bx tmp1

@ ( xx -- xx)
@ Don't do anything, just chew up a few cycles
Forthword_ NOOP, INLINE_OPT, "noop"
  nop
  end_

@ ( u1 u2 -- flag )
@ flag is true if u1 > u2 (unsigned)
Forthword_ UGREATER, 0, "u>"
  y_d_
  sub_y_
  sbcs wreg, wreg
  end_

@ ( u1 u2 -- flag)
@ flag is true if u1 < u2 (unsigned)
Forthword_ ULESS, 0, "u<"
  y_d_
  subs wreg, yreg, wreg
@ wreg = a-b  -- carry set if a is less than b
  sbcs wreg, wreg
  end_

@ ( n1 -- n2 )
@ convert byte length to half word align length
@ round number up to even value
Forthword_ HALIGN, 0, "h_"
  add_1_
  movs tmp1, #1
  mvns tmp1, tmp1
  ands wreg, tmp1
  end_
