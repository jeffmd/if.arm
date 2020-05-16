@ core.S

@@@@@@@@@@@@@ Return Stack @@@@@@@@@@@@@

@ ( -- retaddr )
@ pop return onto data stack and exit caller
@ used if data in program mem and need an address to it
Forthword_ POPRET, 0, "popret"
  mov wreg, lr
  oneminus_
  pop {pc}

@ ( n1 n2 -- flag )
@ flag is true if wreg and NOS are equal
Forthword_ EQUAL, 0, "=="
  ldm dsp!, {tmp1}
  subs wreg, tmp1
  oneminus_
  sbcs wreg, wreg
  end_

@ ( n1 n2 -- flag)
@ flag is true if n1 is less than n2
Forthword_ LESS, 0, "<"
  ldm dsp!, {tmp1}
  cmp tmp1, wreg
  bge.n LESS_END
  true_
  exit_

LESS_END:
  zero_
  end_

@ ( n1 n2 -- flag )
@ flag is true if n1 is greater than n2
Forthword_ GREATER, 0, ">"
  ldm dsp!, {tmp1}     @ Get x1 into a register.
  cmp tmp1, wreg       @ Is x2 greater?
GREATER_CHK:
  ble.n GREATER_END
  zero_
  not_
  exit_
GREATER_END:
  zero_
  end_

@ ( n1 -- flag )
@ flag is true if n1 is greater than 0
Forthword_ GREATERZERO, 0, ">0"
  subs wreg, #0
  end_do_ GREATER_CHK

@ ( n1 -- flag)
@ flag is true if wreg is less than zero
forthword_ LESSZERO, INLINE_OPT, "<0"
  lesszero_
  end_

@ ( len -- len/2 rem)
@ convert byte length to word length plus remainder
Forthword_ BTOW, 0, "btow"
  y_w_        @ ( len Y:len )
  y_twoslash_ @ ( len Y:len/2 )
  d_y_        @ ( len/2 len )
  y_twostar_  @ ( len/2 len Y:len' )
  w_minus_y_  @ ( len/2 rem )
  end_

@ (start dest count -- )
@ count is the number of bytes to copy and must be a multiple of two
@ copy ram using half words.  Assumes no overlap.
Forthword_ MCPY, 0, "mcpy"
  r_b_
  b_d_              @ ( start count ) B:dest
  x_d_              @ ( count ) X:start
  y_w_              @ ( count Y:count )

MCPY_LOOP:
  y_iszero_         @ ( count )
  ifz_ MCPY_END
  hmx_              @ ( val )
  x_plus2_          @ ( val A:A+2 )
  hmb_w_            @ ( val )
  y_minus2_         @ ( val Y:Y-2 )
  b_plus2_          @ ( val B:B+2 )
  goto_ MCPY_LOOP

MCPY_END:
  b_r_
  end_
