@ core-inline.S - inlinned words using core macros
@ these inlined words are needed for boot and core

@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@

@ ( n -- n n )
@ push wreg onto data stack
Forthword_ D_W, INLINE_OPT, "d="
  d_w_
  end_

@ ( n2 n1 -- n2 n2 )
@   d0 WR
@ w=d0
Forthword_ D0, INLINE_OPT, "d0"
  d0_
  end_
  
@ ( n3 n2 n1 -- n3 n2 n3 )
@   d1 d0 WR
@ w=d1
Forthword_ D1, INLINE_OPT, "d1"
  d1_
  end_

@ ( n4 n3 n2 n1 -- n4 n3 n2 n4 )
@   d2 d1 d0 WR
@ w=d2
Forthword_ D2, INLINE_OPT, "d2"
  d2_
  end_

@ ( n2 n1 -- n2 n1 Y:n2 )
@   d0 WR
Forthword_ Y_D0, INLINE_OPT, "y=d0"
  y_d0_
  end_

@ ( n1 n2 -- n2)
@ drop NOS, one before wreg.
Forthword_ D_M1, INLINE_OPT, "d-1"
  d_m1_
  end_

@ ( n1 n2 -- n1)
@   d0 WR    WR
@ pop top of data stack into WR
Forthword_ W_D, INLINE_OPT, "=d"
  w_d_
  end_

@ ( ? DSP:addr -- addr DSP:addr )
@ current data stack pointer
@ working register = dsp
Forthword_ DSP, INLINE_OPT, "dsp"
  dsp_
  end_

@@@@@@@@@@@@@ return Stack @@@@@@@@@@@@@

@ ( n1 -- n2 ) (R: n2 --)
@ pop top of return stack into WR
Forthword_ W_R, INLINE_OPT, "=r"
  w_r_
  end_

@ ( n -- n ) (R: -- n )
@ push WR on top of return stack
Forthword_ R_W, INLINE_OPT, "r="
  r_w_
  end_

@ ( -- r0 ) (R: n -- n+1 )
@ get r0 and increment r0 by 4 on return stack
Forthword_ R0PLUS, INLINE_OPT, "r0+"
  r0_
  adds r1, wreg, #4
  str r1, [sp]
  end_

@@@@@@@@@@@@@ Arithmatic @@@@@@@@@@@@@

@ ( n1 -- n1+y )
@ w = w + y
Forthword_ W_PLUS_Y, INLINE_OPT, "+y"
  w_plus_y_
  end_

@ ( n1 -- n1+x )
@ w = w + x
Forthword_ W_PLUS_X, INLINE_OPT, "+x"
  w_plus_x_
  end_

@ ( n1|u1 -- n1-y|u1-y )
@ w = w - y
Forthword_ W_MINUS_Y, INLINE_OPT, "-y"
  w_minus_y_
  end_

@ ( n1|u1 -- n1-x|u1-x )
@ w = w - x
Forthword_ W_MINUS_X, INLINE_OPT, "-x"
  w_minus_x_
  end_

@ ( n1 -- n1 and Y )
@ w = w and y
Forthword_ W_AND_Y, INLINE_OPT, "&y"
  w_and_y_
  end_

@ ( n1 -- n1 and X )
@ w = w and x
Forthword_ W_AND_X, INLINE_OPT, "&x"
  w_and_x_
  end_

@ ( n1 -- n1.or.Y )
@ w = w or y
Forthword_ W_OR_Y, INLINE_OPT, "|y"
  w_or_y_
  end_

@ ( n1 -- n1.or.X )
@ w = w or x
Forthword_ W_OR_X, INLINE_OPT, "|x"
  w_or_x_
  end_

@ ( n1 n2 -- flag)
@ flag is true if n1 is not equal to n2
Forthword_ NOTEQUAL, INLINE_OPT, "!="
  y_d_
  w_xor_y_
  end_

@ ( n1 -- n1+1 ) 
@ optimized increment
Forthword_ ONEPLUS, INLINE_OPT, "+1"
  oneplus_
  end_

@ ( n1 -- n1-1 )
@ optimized decrement
Forthword_ ONEMINUS, INLINE_OPT, "1-"
  oneminus_
  end_

@ ( n1 -- n1-2 )
@ optimized decrement
Forthword_ TWOMINUS, INLINE_OPT, "2-"
  twominus_
  end_

@ ( n1 -- n1+2 )
@ optimized decrement
Forthword_ TWOPLUS, INLINE_OPT, "+2"
  twoplus_
  end_

@ ( n1 -- n1-4 )
@ optimized decrement
Forthword_ FOURMINUS, INLINE_OPT, "4-"
  fourminus_
  end_

@ ( n1 -- n1+4 )
@ optimized decrement
Forthword_ FOURPLUS, INLINE_OPT, "+4"
  fourplus_
  end_

@ ( n1 -- n1/2 )
@ optimized divide by 2
Forthword_ TWOSLASH, INLINE_OPT, "/2"
  twoslash_
  end_

@ ( n1 -- n1*2 )
@ optimized 2 multiply
Forthword_ TWOSTAR, INLINE_OPT, "*2"
  twostar_
  end_

@ ( n1 -- n1/4 )
@ optimized divide by 4
Forthword_ FOURSLASH, INLINE_OPT, "/4"
  fourslash_
  end_

@ ( n1 -- n*4 )
@ optimized four multiply
Forthword_ FOURSTAR, INLINE_OPT, "*4"
  fourstar_
  end_

@ ( X:n1 -- X:n1/2 )
@ optimized X divide by 2
Forthword_ XTWOSLASH, INLINE_OPT, "x/2"
  x_twoslash_
  end_

@ ( X:n1 -- X:n1*2 )
@ optimized X 2 multiply
Forthword_ XTWOSTAR, INLINE_OPT, "x*2"
  x_twostar_
  end_

@ ( X:n1 -- X:n1/4 )
@ optimized X divide by 4
Forthword_ XFOURSLASH, INLINE_OPT, "x/4"
  x_fourslash_
  end_

@ ( X:n1 -- X:n*4 )
@ optimized x four multiply
Forthword_ XFOURSTAR, INLINE_OPT, "x*4"
  x_fourstar_
  end_

@ ( Y:n1 -- Y:n1/2 )
@ optimized y divide by 2
Forthword_ YTWOSLASH, INLINE_OPT, "y/2"
  y_twoslash_
  end_

@ ( Y:n1 -- Y:n1*2 )
@ optimized y 2 multiply
Forthword_ YTWOSTAR, INLINE_OPT, "y*2"
  y_twostar_
  end_

@ ( Y:n1 -- Y:n1/4 )
@ optimized y divide by 4
Forthword_ YFOURSLASH, INLINE_OPT, "y/4"
  y_fourslash_
  end_

@ ( Y:n1 -- Y:n*4 )
@ optimized y four multiply
Forthword_ YFOURSTAR, INLINE_OPT, "y*4"
  y_fourstar_
  end_

@ ( -- 0 ) 
@ zero
Forthword_ ZERO, INLINE_OPT, "0"
  zero_
  end_

@ ( n1 -- flag )
@ flag is true if n1 is 0
Forthword_ ZEROEQUAL, INLINE_OPT, "0="
  zeroequal_
  end_

@ ( -- -1 )
@ w=-1 (true)
Forthword_ TRUE, INLINE_OPT, "true"
  true_
  end_

@ ( n -- n )
@ test WR if zero,
Forthword_ ISZERO, INLINE_OPT, "==0"
  iszero_
  end_  
  
@ ( a-addr -- n32 )
@ read 1 cell (32 bits) from RAM address
Forthword_ FETCH, INLINE_OPT, "@"
  mw_
  end_

@ ( a-addr -- a-addr X:n32 )
@ read 1 cell (32 bits) from RAM address and put in X register
Forthword_ X_MW, INLINE_OPT, "x=@"
  x_mw_
  end_

@ ( a-addr -- a-addr Y:n32 )
@ read 1 cell (32 bits) from RAM address and put in Y register
Forthword_ Y_MW, INLINE_OPT, "y=@"
  y_mw_
  end_

@ ( a-addr -- n16 )
@ read half cell (16 bits) from RAM address
Forthword_ HMW, INLINE_OPT, "h@"
  hmw_
  end_

@ ( a-addr -- a-addr X:n16 )
@ read 1 cell (16 bits) from RAM address and put in X register
Forthword_ X_HMW, INLINE_OPT, "x=h@"
  x_hmw_
  end_

@ ( a-addr -- a-addr Y:n16 )
@ read 1 cell (16 bits) from RAM address and put in Y register
Forthword_ Y_HMW, INLINE_OPT, "y=h@"
  y_hmw_
  end_

@ ( addr Y:n -- )
@ store a word from Y (32 bits) to RAM address
Forthword_ MW_Y, INLINE_OPT, "@=y"
  mw_y_
  end_

@ ( addr X:n -- )
@ store a word From X (32 bits) to RAM address
Forthword_ MW_X, INLINE_OPT, "@=x"
  mw_x_
  end_

@ ( a-addr -- a-addr Y:n16 )
@ store a half word (16 bits) in Y register to RAM address
Forthword_ HMW_Y, INLINE_OPT, "h@=y"
  hmw_y_
  end_

@ ( a-addr -- a-addr X:n16 )
@ store a half word (16 bits) in X register to RAM address
Forthword_ HMW_X, INLINE_OPT, "h@=x"
  hmw_x_
  end_

@ ( n1 -- n1 ) X: n1
@   WR
@ copy WR register to X register
Forthword_ X_W, INLINE_OPT, "x="
  x_w_
  end_
  
@ ( n1 -- n1 ) Y: n1
@   WR
@ copy WR register to Y register
Forthword_ Y_W, INLINE_OPT, "y="
  y_w_
  end_
  
@ ( -- n )
@ copy X register to WR
Forthword_ X_, INLINE_OPT, "x"
  x_
  end_

@ ( -- n )
@ copy the Y register to WR
Forthword_ Y_, INLINE_OPT, "y"
  y_
  end_

@ ( -- n )
@ Read a word (32bit) from memory pointed to by register X
Forthword_ MX, INLINE_OPT, "@x"
  mx_
  end_

@ ( n -- )
@ store a word to RAM address pointed to by x register
Forthword_ MX_W, INLINE_OPT, "@x="
  mx_w_
  end_

@ ( -- n )
@ Read a half word (32bit) from memory pointed to by register X
Forthword_ HMX, INLINE_OPT, "h@x"
  hmx_
  end_

@ ( h -- )
@ store a half word to RAM address pointed to by x reg
Forthword_ HMX_W, INLINE_OPT, "h@x="
  hmx_w_
  end_

@ ( -- n )
@ Read a word (32bit) from memory pointed to by register Y
Forthword_ MY, INLINE_OPT, "@y"
  my_
  end_

@ ( n -- )
@ store a word to RAM address pointed to by Y register
Forthword_ MY_W, INLINE_OPT, "@y="
  my_w_
  end_

@ ( -- n )
@ Read a half word (16bit) from memory pointed to by register Y
Forthword_ HMY, INLINE_OPT, "h@y"
  hmy_
  end_

@ ( h -- )
@ store a half word to RAM address pointed to by Y reg
Forthword_ HMY_W, INLINE_OPT, "h@y="
  hmy_w_
  end_

@ ( -- )
@ exit a word
Forthword_ EXIT, INLINE_OPT, "exit"
  pop {pc}
  end_

