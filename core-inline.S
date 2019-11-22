@ core-inline.S - inlinned words using core macros

@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@

@ ( n -- ? n  )
@ restore top of data stack once
Forthword_ PUT1, INLINE_OPT, "put1"
  put1_
  end_  
  
@ ( n -- ? ? n )
@ restore top of data stack twice
Forthword_ PUT2, INLINE_OPT, "put2"
  put2_
  end_  
  
@ ( n -- ? ? ? n)
@ restore top of data stack three times
Forthword_ PUT3, INLINE_OPT, "put3"
  put2_
  end_  
  
@ ( n -- n n )
@ duplicate wreg
Forthword_ DPUSH, INLINE_OPT, "push"
  push_
  end_

@ ( n1 n2 -- n1 a  n2 )
@   d0 WR    d1 d0 WR
@ push register A onto top of data stack
Forthword_ DPUSHA, INLINE_OPT, "pusha"
  pusha_
  end_

@ ( n1 n2 -- n1 b  n2 )
@   d0 WR    d1 d0 WR
@ push register B onto top of data stack
Forthword_ DPUSHB, INLINE_OPT, "pushb"
  pushb_
  end_

@ ( n1 n2 -- n1 x  n2 )
@   d0 WR    d1 d0 WR
@ push register X onto top of data stack
Forthword_ DPUSHX, INLINE_OPT, "pushx"
  pushx_
  end_

@ ( n1 n2 -- n1 y  n2 )
@   d0 WR    d1 d0 WR
@ push register Y onto top of data stack
Forthword_ DPUSHY, INLINE_OPT, "pushy"
  pushy_
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

@ ( n2 n1 -- n1 n1 )
@   d0 WR
@ d0=w
Forthword_ D0_W, INLINE_OPT, "d0=w"
  d0_w_
  end_
    
@ ( n3 n2 n1 -- n1 n2 n1 )
@   d1 d0 WR
@ d1=w
Forthword_ D1_W, INLINE_OPT, "d1=w"
  d1_w_
  end_
    
@ ( n4 n3 n2 n1 -- n1 n3 n2 n1 )
@   d2 d1 d0 WR
@ d2=w
Forthword_ D2_W, INLINE_OPT, "d2=w"
  d2_w_
  end_
    
@ ( n2 n1 -- n2 n1 ) A: n2
@   d0 WR
@ a=d0
Forthword_ A_D0, INLINE_OPT, "a=d0"
  a_d0_
  end_
  
@ ( n2 n1 -- n2 n1 ) B: n2
@   d0 WR
@ b=d0
Forthword_ B_D0, INLINE_OPT, "b=d0"
  b_d0_
  end_
  
@ ( n2 n1 -- n2 n1 ) X: n2
@   d0 WR
@ x=d0
Forthword_ X_D0, INLINE_OPT, "x=d0"
  x_d0_
  end_
  
@ ( n2 n1 -- n2 n1 ) Y: n2
@   d0 WR
@ y=d0
Forthword_ Y_D0, INLINE_OPT, "y=d0"
  y_d0_
  end_
   
@ ( n3 n2 n1 -- n3 n2 n1 ) A: n3
@   d1 d0 WR
@ a=d1
Forthword_ A_D1, INLINE_OPT, "a=d1"
  a_d1_
  end_
  
@ ( n3 n2 n1 -- n3 n2 n1 ) B: n3
@   d1 d0 WR
@ b=d1
Forthword_ B_D1, INLINE_OPT, "b=d1"
  b_d1_
  end_
  
@ ( n3 n2 n1 -- n3 n2 n1 ) X: n3
@   d1 d0 WR
@ x=d1
Forthword_ X_D1, INLINE_OPT, "x=d1"
  x_d1_
  end_
  
@ ( n3 n2 n1 -- n3 n2 n1 ) Y: n3
@   d1 d0 WR
@ y=d1
Forthword_ Y_D1, INLINE_OPT, "y=d1"
  y_d1_
  end_
  
@ ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) A: n4
@   d2 d1 d0 WR
@ a=d2
Forthword_ A_D2, INLINE_OPT, "a=d2"
  a_d2_
  end_
  
@ ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) B: n4
@   d2 d1 d0 WR
@ b=d2
Forthword_ B_D2, INLINE_OPT, "b=d2"
  b_d2_
  end_

@ ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) X: n4
@   d2 d1 d0 WR
@ x=d2
Forthword_ X_D2, INLINE_OPT, "x=d2"
  x_d2_
  end_
  
@ ( n4 n3 n2 n1 -- n4 n3 n2 n1 ) Y: n4
@   d2 d1 d0 WR
@ y=d2
Forthword_ Y_D2, INLINE_OPT, "y=d2"
  y_d2_
  end_
  
@ ( ?  n2 -- n1 n2 ) A: n1
@   d0 WR
@ d0=a
Forthword_ D0_A, INLINE_OPT, "d0=a"
  d0_a_
  end_
  
@ ( ?  n2 -- n1 n2 ) B: n1
@   d0 WR
@ d0=b
Forthword_ D0_B, INLINE_OPT, "d0=b"
  d0_b_
  end_
  
@ ( ?  n2 -- n1 n2 ) X: n1
@   d0 WR
@ d0=x
Forthword_ D0_X, INLINE_OPT, "d0=x"
  d0_x_
  end_
  
@ ( ?  n2 -- n1 n2 ) Y: n1
@   d0 WR
@ d0=y
Forthword_ D0_Y, INLINE_OPT, "d0=y"
  d0_y_
  end_
  
@ ( ?  ?  n1 -- n2 ? n1 ) A: n2
@   d1 d0 WR
@ d1=a
Forthword_ D1_A, INLINE_OPT, "d1=a"
  d1_a_
  end_
  
@ ( ?  ?  n1 -- n2 ?  n1 ) B: n2
@   d1 d0 WR
@ d1=b
Forthword_ D1_B, INLINE_OPT, "d1=b"
  d1_b_
  end_
  
@ ( ?  ?  n1 -- n2 ?  n1 ) X: n2
@   d1 d0 WR
@ d1=x
Forthword_ D1_X, INLINE_OPT, "d1=x"
  d1_x_
  end_
  
@ ( ?  ?  n1 -- n2 ?  n1 ) Y: n2
@   d1 d0 WR
@ d1=y
Forthword_ D1_Y, INLINE_OPT, "d1=y"
  d1_y_
  end_
  
@ ( ?  ?  ?  n1 -- n2 ?  ? n1 ) A: n2
@   d2 d1 d0 WR
@ d2=a
Forthword_ D2_A, INLINE_OPT, "d2=a"
  d2_a_
  end_
  
@ ( ?  ?  ?  n1 -- n2 ?  ? n1 ) B: n2
@   d2 d1 d0 WR
@ d2=b
Forthword_ D2_B, INLINE_OPT, "d2=b"
  d2_b_
  end_
  
@ ( ?  ?  ?  n1 -- n2 ?  ? n1 ) X: n2
@   d2 d1 d0 WR
@ d2=x
Forthword_ D2_X, INLINE_OPT, "d2=x"
  d2_x_
  end_
  
@ ( ?  ?  ?  n1 -- n2 ?  ? n1 ) Y: n2
@   d2 d1 d0 WR    d2 d1 d0 WR
@ d2=y
Forthword_ D2_Y, INLINE_OPT, "d2=y"
  d2_y_
  end_

@ ( n1 n2 -- n2)
@ drop NOS, one before wreg.
Forthword_ NIP, INLINE_OPT, "nip"
  nip_
  end_

@ ( n1 n2 n3 -- n3)
@ drop NOS, one before wreg.
Forthword_ NIP2, INLINE_OPT, "nip2"
  nip2_
  end_

@ ( n1 n2 n3 n4 -- n4)
@ drop NOS, one before wreg.
Forthword_ NIP3, INLINE_OPT, "nip3"
  nip3_
  end_

@ ( n -- )
@ drop wreg
Forthword_ DPOP, INLINE_OPT, "pop"
  pop_
  end_

@ ( n1 n2 n3 -- n1 n3 ) A: n2
@   d1 d0 WR    d0 WR
@ pop top of data stack into register A
Forthword_ DPOPA, INLINE_OPT, "popa"
  popa_
  end_

@ ( n1 n2 n3 -- n1 n3 ) B: n2
@   d1 d0 WR    d0 WR
@ pop top of data stack into register B
Forthword_ DPOPB, INLINE_OPT, "popb"
  popb_
  end_

@ ( n1 n2 n3 -- n1 n3 ) X: n2
@   d1 d0 WR    d0 WR
@ pop top of data stack into register X
Forthword_ DPOPX, INLINE_OPT, "popx"
  popx_
  end_

@ ( n1 n2 n3 -- n1 n3 ) Y: n2
@   d1 d0 WR    d0 WR
@ pop top of data stack into register Y
Forthword_ DPOPY, INLINE_OPT, "popy"
  popy_
  end_

@ (  -- addr )
@ current data stack pointer
Forthword_ DSP, INLINE_OPT, "dsp"
  dsp_
  end_

@ ( addr -- i*x)
@ set data stack pointer to addr
Forthword_ DSP_W, INLINE_OPT, "dsp=w"
  dsp_w_
  end_

@@@@@@@@@@@@@ return Stack @@@@@@@@@@@@@

@ ( -- n ) (R: n --)
@ move TOR to wreg
Forthword_ RPOP, INLINE_OPT, "rpop"
  rpop_
  end_

@ ( -- ) (R: n2 --) A: n2
@ pop top of return stack into A
Forthword_ RPOPA, INLINE_OPT, "rpopa"
  rpopa_
  end_

@ ( -- ) (R: n2 --) B: n2
@ pop top of return stack into B
Forthword_ RPOPB, INLINE_OPT, "rpopb"
  rpopb_
  end_

@ ( -- ) (R: n2 --) X: n2
@ pop top of return stack into X
Forthword_ RPOPX, INLINE_OPT, "rpopx"
  rpopx_
  end_

@ ( -- ) (R: n2 --) Y: n2
@ pop top of return stack into Y
Forthword_ RPOPY, INLINE_OPT, "rpopy"
  rpopy_
  end_

@ ( -- ) (R: n -- )
@ Drop TOR
Forthword_ RNIP, INLINE_OPT, "rnip"
  rnip_
  end_

@ ( -- ) (R: n2 n1 -- )
@ remove 2 top cells of return stack
Forthword_ RNIP2, INLINE_OPT, "rnip2"
  rnip2_
  end_

@ ( -- ) (R: n3 n2 n1 -- )
@ remove 3 top cells of return stack
Forthword_ RNIP3, INLINE_OPT, "rnip3"
  rnip3_
  end_

@ ( n -- n ) (R: -- n )
@ copy wreg to TOR
Forthword_ RPUSH, INLINE_OPT, "rpush"
  rpush_
  end_

@ ( -- ) (R: -- a)
@ push A on top of return stack
Forthword_ RPUSHA, INLINE_OPT, "rpusha"
  rpusha_
  end_

@ ( -- ) (R: -- b)
@ push B on top of return stack
Forthword_ RPUSHB, INLINE_OPT, "rpushb"
  rpushb_
  end_

@ ( -- ) (R: -- x)
@ push X on top of return stack
Forthword_ RPUSHX, INLINE_OPT, "rpushx"
  rpushx_
  end_

@ ( -- ) (R: -- y)
@ push Y on top of return stack
Forthword_ RPUSHY, INLINE_OPT, "rpushy"
  rpushy_
  end_

@ ( -- ) (R: -- sp)
@ push datastack pointer on top of return stack
Forthword_ RPUSHDP, INLINE_OPT, "rpushdsp"
  rpushdsp_
  end_

@ ( -- n) (R: n -- n )
@ put a copy of TOR on wreg
Forthword_ R0, INLINE_OPT, "r0"
  r0_
  end_

@ ( -- n1 ) (R: n1 n2 -- n1 n2 )
@ r1
Forthword_ R1, INLINE_OPT, "r1"
  r1_
  end_

@ ( -- n1 ) (R: n1 n2 n3 -- n1 n2 n3 )
@ put a copy of R2 in WR
Forthword_ R2, INLINE_OPT, "r2"
  r2_
  end_

@ ( n1 -- n1) (R: n2 -- n1 )
@   WR            R0
@ r0=w
Forthword_ R0_W, INLINE_OPT, "r0=w"
  r0_w_
  end_

@ ( n1 -- n1) (R: n3 n2 -- n1 n2 )
@   WR            R1 R0
@ r1=w
Forthword_ R1_W, INLINE_OPT, "r1=w"
  r1_w_
  end_

@ ( n1 -- n1) (R: n4 n3 n2 -- n1 n3 n2 )
@   WR            R2 R1 R0
@ r2=w
Forthword_ R2_W, INLINE_OPT, "r2=w"
  r2_w_
  end_

@ ( -- ) (R: n1 -- n1 ) A: n1
@            R0
@ a=r0
Forthword_ A_R0, INLINE_OPT, "a=r0"
  a_r0_
  end_

@ ( -- ) (R: n1 -- n1 ) B: n1
@            R0
@ b=r0
Forthword_ B_R0, INLINE_OPT, "b=r0"
  b_r0_
  end_

@ ( -- ) (R: n1 -- n1 ) X: n1
@            R0
@ put a copy of R0 into X register
Forthword_ X_R0, INLINE_OPT, "x=r0"
  x_r0_
  end_

@ ( -- ) (R: n1 -- n1 ) Y: n1
@            R0
@ put a copy of R0 into Y register
Forthword_ Y_R0, INLINE_OPT, "y=r0"
  y_r0_
  end_

@ ( -- ) (R: n2 n1 -- n2 n1 ) A: n2
@            R1 R0
@ a=r1
Forthword_ A_R1, INLINE_OPT, "a=r1"
  a_r1_
  end_

@ ( -- ) (R: n2 n1 -- n2 n1 ) B: n2
@            R1 R0
@ b=r1
Forthword_ B_R1, INLINE_OPT, "b=r1"
  b_r1_
  end_

@ ( -- ) (R: n2 n1 -- n2 n1 ) X: n2
@            R1 R0
@ x=r1
Forthword_ X_R1, INLINE_OPT, "x=r1"
  x_r1_
  end_

@ ( -- ) (R: n2 n1 -- n2 n1 ) Y: n2
@            R1 R0
@ y=r1
Forthword_ Y_R1, INLINE_OPT, "y=r1"
  y_r1_
  end_

@ ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) A: n3
@            R2 R1 R0
@ a=r2
Forthword_ A_R2, INLINE_OPT, "a=r2"
  a_r2_
  end_

@ ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) B: n3
@            R2 R1 R0
@ b=r2
Forthword_ B_R2, INLINE_OPT, "b=r2"
  b_r2_
  end_

@ ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) X: n3
@            R2 R1 R0
@ x=r2
Forthword_ X_R2, INLINE_OPT, "x=r2"
  x_r2_
  end_

@ ( -- ) (R: n3 n2 n1 -- n3 n2 n1 ) Y: n3
@            R2 R1 R0
@ y=r2
Forthword_ Y_R2, INLINE_OPT, "y=r2"
  y_r2_
  end_

@ (R: n2 -- n1 ) A: n1
@     r0
@ r0=a
Forthword_ R0_A, INLINE_OPT, "r0=a"
  r0_a_
  end_
  
@ (R: n2 -- n1 ) B: n1
@     r0
@ r0=b
Forthword_ R0_B, INLINE_OPT, "r0=b"
  r0_b_
  end_
  
@ (R: n2 -- n1 ) X: n1
@     r0
@ r0=x
Forthword_ R0_X, INLINE_OPT, "r0=x"
  r0_x_
  end_
  
@ (R: n2 -- n1 ) Y: n1
@     r0
@ r0=y
Forthword_ R0_Y, INLINE_OPT, "r0=y"
  r0_y_
  end_
  
@ (R: ?  n1 -- n2 n1 ) A: n2
@     r1 r0
@ r1=a
Forthword_ R1_A, INLINE_OPT, "r1=a"
  r1_a_
  end_
  
@ (R: ?  n1 -- n2 n1 ) B: n2
@     r1 r0
@ r1=b
Forthword_ R1_B, INLINE_OPT, "r1=b"
  r1_b_
  end_
  
@ (R: ?  n1 -- n2 n1 ) X: n2
@     r1 r0
@ r1=x
Forthword_ R1_X, INLINE_OPT, "r1=x"
  r1_x_
  end_
  
@ (R: ?  n1 -- n2 n1 ) Y: n2
@     r1 r0
@ r1=y
Forthword_ R1_Y, INLINE_OPT, "r1=y"
  r1_y_
  end_
  
@ (R: ?  ?  n1 -- n2 ?  n1 ) A: n2
@     r2 r1 r0
@ r2=a
Forthword_ R2_A, INLINE_OPT, "r2=a"
  r2_a_
  end_
  
@ (R: ?  ?  n1 -- n2 ?  n1 ) B: n2
@     r2 r1 r0
@ r2=b
Forthword_ R2_B, INLINE_OPT, "r2=b"
  r2_b_
  end_
  
@ (R: ?  ?  n1 -- n2 ?  n1 ) X: n2
@     r2 r1 r0
@ r2=x
Forthword_ R2_X, INLINE_OPT, "r2=x"
  r2_x_
  end_
  
@ (R: ?  ?  n1 -- n2 ?  n1 ) Y: n2
@     r2 r1 r0
@ r2=y
Forthword_ R2_Y, INLINE_OPT, "r2=y"
  r2_y_
  end_
  
@ (  -- n)
@ current return stack pointer address
Forthword_ RSP, INLINE_OPT, "rsp"
  rsp_
  end_

@ ( addr  -- ) (R: -- x*y)
@ set return stack pointer
@ must be called
Forthword_ RSP_W, INLINE_OPT, "rsp=w"
  @ keep the return address
  rsp_w_
  end_
