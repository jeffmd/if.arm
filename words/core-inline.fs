\ core-inline.fs - core inlined words

\ ********** Return Stack ************

( -- ) ( R: n -- )
\ Drop TOR
rword r-1 inlined
  1 _addsp ,
  _bxlr ,

( -- ) ( R: n1 n2 -- )
\ remove 2 top cells of return stack
rword r-2 inlined
  2 _addsp ,
  _bxlr ,

( -- ) ( R: n1 n2 -- )
\ remove 3 top cells of return stack
rword r-3 inlined
  3 _addsp ,
  _bxlr ,

( -- n ) ( R: n -- n )
\            R0
\ load value from top of return stack into working register
\ w = rsp[0]
rword r0 inlined
  _w d= _r0 _ldrsp ,
  _bxlr ,

( -- n1 ) ( R: n1 n2 -- n1 n2 )
\              R1 R0
\ load value from return stack into working register
\ w = rsp[1]
rword r1 inlined
  _w d= _r1 _ldrsp ,
  _bxlr ,

( -- n1 ) ( R: n1 n2 n3 -- n1 n2 n3 )
\              R2 R1 R0
\ load value from return stack into working register
\ w = rsp[2]
rword r2 inlined
  _w d= _r2 _ldrsp ,
  _bxlr ,

( -- A:n ) ( R: n -- n )
\              R0
\ load value from top of return stack into register A
\ a = rsp[0]
rword a=r0 inlined
  _a d= _r0 _ldrsp ,
  _bxlr ,

( -- A:n1 ) ( R: n1 n2 -- n1 n2 )
\                R1 R0
\ load value from return stack into register A
\ a = rsp[1]
rword a=r1 inlined
  _a d= _r1 _ldrsp ,
  _bxlr ,

( -- A:n1 ) ( R: n1 n2 n3 -- n1 n2 n3 )
\                R2 R1 R0
\ load value from return stack into register A
\ a = rsp[2]
rword a=r2 inlined
  _a d= _r2 _ldrsp ,
  _bxlr ,

( -- B:n ) ( R: n -- n )
\              R0
\ load value from top of return stack into register B
\ b = rsp[0]
rword b=r0 inlined
  _b d= _r0 _ldrsp ,
  _bxlr ,

( -- B:n1 ) ( R: n1 n2 -- n1 n2 )
\                R1 R0
\ load value from return stack into register B
\ b = rsp[1]
rword b=r1 inlined
  _b d= _r1 _ldrsp ,
  _bxlr ,

( -- B:n1 ) ( R: n1 n2 n3 -- n1 n2 n3 )
\                R2 R1 R0
\ load value from return stack into register B
\ b = rsp[2]
rword b=r2 inlined
  _b d= _r2 _ldrsp ,
  _bxlr ,

( -- X:n ) ( R: n -- n )
\              R0
\ load value from top of return stack into register X
\ x = rsp[0]
rword x=r0 inlined
  _x d= _r0 _ldrsp ,
  _bxlr ,

( -- X:n1 ) ( R: n1 n2 -- n1 n2 )
\                R1 R0
\ load value from return stack into register X
\ x = rsp[1]
rword x=r1 inlined
  _x d= _r1 _ldrsp ,
  _bxlr ,

( -- X:n1 ) ( R: n1 n2 n3 -- n1 n2 n3 )
\                R2 R1 R0
\ load value from return stack into register X
\ x = rsp[2]
rword x=r2 inlined
  _x d= _r2 _ldrsp ,
  _bxlr ,

( -- Y:n ) ( R: n -- n )
\              R0
\ load value from top of return stack into register Y
\ y = rsp[0]
rword y=r0 inlined
  _y d= _r0 _ldrsp ,
  _bxlr ,

( -- Y:n1 ) ( R: n1 n2 -- n1 n2 )
\                R1 R0
\ load value from return stack into register Y
\ y = rsp[1]
rword y=r1 inlined
  _y d= _r1 _ldrsp ,
  _bxlr ,

( -- Y:n1 ) ( R: n1 n2 n3 -- n1 n2 n3 )
\                R2 R1 R0
\ load value from return stack into register Y
\ y = rsp[2]
rword y=r2 inlined
  _y d= _r2 _ldrsp ,
  _bxlr ,

( n -- n ) ( R: ? -- n )
\            R0
\ store working register into top of return stack
\ rsp[0] = w
rword r0= inlined
  _w d= _r0 _strsp ,
  _bxlr ,

( n1 -- n1 ) ( R: n3 n2 -- n1 n2 )
\                 R1 R0
\ store working register into return stack
\ rsp[1] = w
rword r1= inlined
  _w d= _r1 _strsp ,
  _bxlr ,

( n1 -- n1 ) ( R: n4 n2 n3 -- n1 n2 n3 )
\                 R2 R1 R0
\ store working register into return stack
\ rsp[2] = w
rword r2= inlined
  _w d= _r2 _strsp ,
  _bxlr ,

( A:n -- A:n ) ( R: ? -- n )
\                  R0
\ store register A into return stack
\ rsp[0] = a
rword r0=a inlined
  _a d= _r0 _strsp ,
  _bxlr ,

( A:n1 -- A:n1 ) ( R: n3 n2 -- n1 n2 )
\                     R1 R0
\ store register A into return stack
\ rsp[1] = a
rword r1=a inlined
  _a d= _r1 _strsp ,
  _bxlr ,

( A:n1 -- A:n1 ) ( R: n4 n2 n3 -- n1 n2 n3 )
\                     R2 R1 R0
\ store register A into return stack
\ rsp[2] = a
rword r2=a inlined
  _a d= _r2 _strsp ,
  _bxlr ,

( B:n -- B:n ) ( R: ? -- n )
\                  R0
\ store register B into return stack
\ rsp[0] = b
rword r0=b inlined
  _b d= _r0 _strsp ,
  _bxlr ,

( B:n1 -- B:n1 ) ( R: n3 n2 -- n1 n2 )
\                     R1 R0
\ store register B into return stack
\ rsp[1] = b
rword r1=b inlined
  _b d= _r1 _strsp ,
  _bxlr ,

( B:n1 -- B:n1 ) ( R: n4 n2 n3 -- n1 n2 n3 )
\                     R2 R1 R0
\ store register B into return stack
\ rsp[2] = b
rword r2=b inlined
  _b d= _r2 _strsp ,
  _bxlr ,

( X:n -- X:n ) ( R: ? -- n )
\                  R0
\ store register X into return stack
\ rsp[0] = x
rword r0=x inlined
  _x d= _r0 _strsp ,
  _bxlr ,

( X:n1 -- X:n1 ) ( R: n3 n2 -- n1 n2 )
\                     R1 R0
\ store register X into return stack
\ rsp[1] = x
rword r1=x inlined
  _x d= _r1 _strsp ,
  _bxlr ,

( X:n1 -- X:n1 ) ( R: n4 n2 n3 -- n1 n2 n3 )
\                     R2 R1 R0
\ store register X into return stack
\ rsp[2] = x
rword r2=x inlined
  _x d= _r2 _strsp ,
  _bxlr ,

( Y:n -- Y:n ) ( R: ? -- n )
\                  R0
\ store register Y into return stack
\ rsp[0] = y
rword r0=y inlined
  _y d= _r0 _strsp ,
  _bxlr ,

( Y:n1 -- Y:n1 ) ( R: n3 n2 -- n1 n2 )
\                     R1 R0
\ store register Y into return stack
\ rsp[1] = y
rword r1=y inlined
  _y d= _r1 _strsp ,
  _bxlr ,

( Y:n1 -- Y:n1 ) ( R: n4 n2 n3 -- n1 n2 n3 )
\                     R2 R1 R0
\ store register Y into return stack
\ rsp[2] = y
rword r2=y inlined
  _y d= _r2 _strsp ,
  _bxlr ,

\ ********** Data Stack ************

( n -- ? n  )
\ restore top of data stack once
rword d+1 inlined
  _dsp d= 4 _subsi ,
  _bxlr ,

( n -- ? ? n  )
\ restore top of data stack twice
rword d+2 inlined
  _dsp d= 8 _subsi ,
  _bxlr ,

( n -- ? ? ? n  )
\ restore top of data stack three times
rword d+3 inlined
  _dsp d= 12 _subsi ,
  _bxlr ,

( n1 n2 n3 -- n3)
\ drop top of data stack twice
rword d-2 inlined
  _dsp d= 8 _addsi ,
  _bxlr ,

( n1 n2 n3 n4 -- n4)
\ drop top of data stack three times
rword d-3 inlined
  _dsp d= 12 _addsi ,
  _bxlr ,

( n1 n2 -- n1 a n2 )
\ push register A onto top of data stack
rword d=a inlined
  _dsp d= 4 _subsi ,
  _a d= _dsp d= 0 _str ,
  _bxlr ,

( n1 n2 -- n1 b n2 )
\ push register B onto top of data stack
rword d=b inlined
  _dsp d= 4 _subsi ,
  _b d= _dsp d= 0 _str ,
  _bxlr ,

( n1 n2 -- n1 x n2 )
\ push register X onto top of data stack
rword d=x inlined
  _dsp d= 4 _subsi ,
  _x d= _dsp d= 0 _str ,
  _bxlr ,

( n1 n2 -- n1 y n2 )
\ push register Y onto top of data stack
rword d=y inlined
  _dsp d= 4 _subsi ,
  _y d= _dsp d= 0 _str ,
  _bxlr ,

( n1 n2 n3 -- n1 n3 A:n2 )
\ pop top of data stack into register A
rword a=d inlined
  _dsp d= _a _ldmia! ,
  _bxlr ,

( n1 n2 n3 -- n1 n3 B:n2 )
\ pop top of data stack into register B
rword b=d inlined
  _dsp d= _b _ldmia! ,
  _bxlr ,

( n1 n2 n3 -- n1 n3 X:n2 )
\ pop top of data stack into register X
rword x=d inlined
  _dsp d= _x _ldmia! ,
  _bxlr ,

( n1 n2 n3 -- n1 n3 Y:n2 )
\ pop top of data stack into register Y
rword y=d inlined
  _dsp d= _y _ldmia! ,
  _bxlr ,

( n2 n1 -- n2 n1 X:n2 )
\ d0 WR
rword x=d0 inlined
  _x d= _dsp d= _d0 _ldr ,
  _bxlr ,

( n2 n1 -- n2 n1 A:n2 )
\ d0 WR
rword a=d0 inlined
  _a d= _dsp d= _d0 _ldr ,
  _bxlr ,

( n2 n1 -- n2 n1 B:n2 )
\ d0 WR
rword b=d0 inlined
  _b d= _dsp d= _d0 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 X:n3 )
\ d1 d0 WR
rword x=d1 inlined
  _x d= _dsp d= _d1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 Y:n3 )
\ d1 d0 WR
rword y=d1 inlined
  _y d= _dsp d= _d1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 A:n3 )
\ d1 d0 WR
rword a=d1 inlined
  _a d= _dsp d= _d1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 B:n3 )
\ d1 d0 WR
rword b=d1 inlined
  _b d= _dsp d= _d1 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 X:n4 )
\ d2 d1 d0 WR
rword x=d2 inlined
  _x d= _dsp d= _d2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 Y:n4 )
\ d2 d1 d0 WR
rword y=d2 inlined
  _y d= _dsp d= _d2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 A:n4 )
\ d2 d1 d0 WR
rword a=d2 inlined
  _a d= _dsp d= _d2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 B:n4 )
\ d2 d1 d0 WR
rword b=d2 inlined
  _b d= _dsp d= _d2 _ldr ,
  _bxlr ,

(  ? n1 -- n1 n1  )
\ d0 WR
rword d0= inlined
  _w d= _dsp d= _d0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 X:n1 )
\ d0 WR
rword d0=x inlined
  _x d= _dsp d= _d0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 Y:n1 )
\ d0 WR
rword d0=y inlined
  _y d= _dsp d= _d0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 A:n1 )
\ d0 WR
rword d0=a inlined
  _a d= _dsp d= _d0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 B:n1 )
\ d0 WR
rword d0=b inlined
  _b d= _dsp d= _d0 _str ,
  _bxlr ,

(  ?  ? n1 -- n1 ? n1 )
\ d1 d0 WR
rword d1= inlined
  _w d= _dsp d= _d1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 X:n1 )
\ d1 d0 WR
rword d1=x inlined
  _x d= _dsp d= _d1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 Y:n1 )
\ d1 d0 WR
rword d1=y inlined
  _y d= _dsp d= _d1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 A:n1 )
\ d1 d0 WR
rword d1=a inlined
  _a d= _dsp d= _d1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 B:n1 )
\ d1 d0 WR
rword d1=b inlined
  _b d= _dsp d= _d1 _str ,
  _bxlr ,

(  ?  ?  ? n1 -- n1 ? ? n1 )
\ d2 d1 d0 WR
rword d2= inlined
  _w d= _dsp d= _d2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 X:n1 )
\ d2 d1 d0 WR
rword d2=x inlined
  _x d= _dsp d= _d2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 Y:n1 )
\ d2 d1 d0 WR
rword d2=y inlined
  _y d= _dsp d= _d2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 A:n1 )
\ d2 d1 d0 WR
rword d2=a inlined
  _a d= _dsp d= _d2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 B:n1 )
\ d2 d1 d0 WR
rword d2=b inlined
  _b d= _dsp d= _d2 _str ,
  _bxlr ,

\ ********** Register Moves ************

( -- a )
\ working register = a
rword a inlined
  _w d= _a _mov ,
  _bxlr ,

( -- b )
\ working register = b
rword b inlined
  _w d= _b _mov ,
  _bxlr ,

( n -- A:n )
\ a = working register
rword a= inlined
  _a d= _w _mov ,
  _bxlr ,

( n -- B:n )
\ b = working register
rword b= inlined
  _b d= _w _mov ,
  _bxlr ,

( addr -- addr DSP:addr )
\ set data stack pointer to addr
\ dsp = working register
rword dsp= inlined
  _dsp d= _w _mov ,
  _bxlr ,

( addr RSP:? -- addr RSP:addr )
\ set return stack pointer to addr
\ rsp = working register
rword rsp= inlined
  _rsp d= _w _mov ,
  _bxlr ,

( ? RSP:addr -- addr RSP:addr )
\ current return stack pointer
\ working register = rsp
rword rsp inlined
  _w d= _rsp _mov ,
  _bxlr ,

\ ********** Arithmatic ************

( n1 -- n1+a )
\ w = w + a
rword +a inlined
  _w d= d= _a _adds ,
  _bxlr ,

( n1 -- n1+b )
\ w = w + b
rword +b inlined
  _w d= d= _b _adds ,
  _bxlr ,

( n1 -- n1-a )
\ w = w - a
rword -=a inlined
  _w d= d= _a _subs ,
  _bxlr ,

( n1 -- n1-b )
\ w = w - b
rword -=b inlined
  _w d= d= _b _subs ,
  _bxlr ,

( n1 -- n1 X:x+n1 )
\ x = x + w
rword x+ inlined
  _x d= d= _w _adds ,
  _bxlr ,

( n1 -- n1 X:x+y )
\ x = x + y
rword x+y inlined
  _x d= d= _y _adds ,
  _bxlr ,

( n1 -- n1 X:x+a )
\ x = x + a
rword x+a inlined
  _x d= d= _a _adds ,
  _bxlr ,

( n1 -- n1 X:x+b )
\ x = x + b
rword x+b inlined
  _x d= d= _b _adds ,
  _bxlr ,

( n1 -- n1 Y:y+n1 )
\ y = y + w
rword y+ inlined
  _y d= d= _w _adds ,
  _bxlr ,

( n1 -- n1 Y:y+x )
\ y = y + x
rword y+x inlined
  _y d= d= _x _adds ,
  _bxlr ,

( n1 -- n1 Y:y+a )
\ y = y + a
rword y+a inlined
  _y d= d= _a _adds ,
  _bxlr ,

( n1 -- n1 Y:y+b )
\ y = y + b
rword y+b inlined
  _y d= d= _b _adds ,
  _bxlr ,

( n1 -- n1 A:a+n1 )
\ a = a + w
rword a+ inlined
  _a d= d= _w _adds ,
  _bxlr ,

( n1 -- n1 A:a+x )
\ a = a + x
rword a+x inlined
  _a d= d= _x _adds ,
  _bxlr ,

( n1 -- n1 A:a+y )
\ a = a + y
rword a+y inlined
  _a d= d= _y _adds ,
  _bxlr ,

( n1 -- n1 A:a+b )
\ a = a + b
rword a+b inlined
  _a d= d= _b _adds ,
  _bxlr ,

( n1 -- n1 B:b+n1 )
\ b = b + w
rword b+ inlined
  _b d= d= _w _adds ,
  _bxlr ,

( n1 -- n1 B:b+x )
\ b = b + x
rword b+x inlined
  _b d= d= _x _adds ,
  _bxlr ,

( n1 -- n1 B:b+y )
\ b = b + y
rword b+y inlined
  _b d= d= _y _adds ,
  _bxlr ,

( n1 -- n1 B:b+n1 )
\ b = b + a
rword b+a inlined
  _b d= d= _a _adds ,
  _bxlr ,

( n1 -- n1 X:x-n1 )
\ x = x - w
rword x- inlined
  _x d= d= _w _subs ,
  _bxlr ,

( n1 -- n1 X:x-y )
\ x = x - y
rword x-y inlined
  _x d= d= _y _subs ,
  _bxlr ,

( n1 -- n1 X:x-a )
\ x = x - a
rword x-a inlined
  _x d= d= _a _subs ,
  _bxlr ,

( n1 -- n1 X:x-b )
\ x = x - b
rword x-b inlined
  _x d= d= _b _subs ,
  _bxlr ,

( n1 -- n1 Y:y-n1 )
\ y = y - w
rword y- inlined
  _y d= d= _w _subs ,
  _bxlr ,

( n1 -- n1 Y:y-x )
\ y = y - x
rword y-x inlined
  _y d= d= _x _subs ,
  _bxlr ,

( n1 -- n1 Y:y-a )
\ y = y - a
rword y-a inlined
  _y d= d= _a _subs ,
  _bxlr ,

( n1 -- n1 Y:y-b )
\ y = y - b
rword y-b inlined
  _y d= d= _b _subs ,
  _bxlr ,

( n1 -- n1 A:a-n1 )
\ a = a - w
rword a- inlined
  _a d= d= _w _subs ,
  _bxlr ,

( n1 -- n1 A:a-x )
\ a = a - x
rword a-x inlined
  _a d= d= _x _subs ,
  _bxlr ,

( n1 -- n1 A:a-y )
\ a = a - y
rword a-y inlined
  _a d= d= _y _subs ,
  _bxlr ,

( n1 -- n1 A:a-b )
\ a = a - b
rword a-b inlined
  _a d= d= _b _subs ,
  _bxlr ,

( n1 -- n1 B:b-n1 )
\ b = b - w
rword b- inlined
  _b d= d= _w _subs ,
  _bxlr ,

( n1 -- n1 B:b-x )
\ b = b - x
rword b-x inlined
  _b d= d= _x _subs ,
  _bxlr ,

( n1 -- n1 B:b-y )
\ b = b - y
rword b-y inlined
  _b d= d= _y _subs ,
  _bxlr ,

( n1 -- n1 B:b-a )
\ b = b - a
rword b-a inlined
  _b d= d= _a _subs ,
  _bxlr ,

( n -- -n )
\ 2-compliment of W
\ w = -w
rword -w inlined
  _w d= _w _rsbs ,
  _bxlr ,

( X:n -- X:-n )
\ 2-compliment of X
\ x = -x
rword -x inlined
  _x d= _x _rsbs ,
  _bxlr ,

( Y:n -- Y:-n )
\ 2-compliment of Y
\ y = -y
rword -y inlined
  _y d= _y _rsbs ,
  _bxlr ,

( A:n -- A:-n )
\ 2-compliment of A
\ a = -a
rword -a inlined
  _a d= _a _rsbs ,
  _bxlr ,

( B:n -- B:-n )
\ 2-compliment of B
\ b = -b
rword -b inlined
  _b d= _b _rsbs ,
  _bxlr ,

( n -- !n )
\ 1-compliment of W
\ W = NOT W
rword !w inlined
  _w d= _w _mvns ,
  _bxlr ,

( X:n -- X:!n )
\ 1-compliment of X
\ x = NOT x
rword !x inlined
  _x d= _x _mvns ,
  _bxlr ,

( Y:n -- Y:!n )
\ 1-compliment of Y
\ y = NOT y
rword !y inlined
  _y d= _y _mvns ,
  _bxlr ,

( A:n -- A:!n )
\ 1-compliment of A
\ a = NOT a
rword !a inlined
  _a d= _a _mvns ,
  _bxlr ,

( B:n -- B:!n )
\ 1-compliment of B
\ b = NOT b
rword !b inlined
  _b d= _b _mvns ,
  _bxlr ,

( n -- n*X )
\ signed multiply 32b x 32b = 32b
\ w = w * x
rword *x inlined
  _w d= _x _muls ,
  _bxlr ,

( n -- n*Y )
\ signed multiply 32b x 32b = 32b
\ w = w * y
rword *y inlined
  _w d= _y _muls ,
  _bxlr ,

( n -- n*A )
\ signed multiply 32b x 32b = 32b
\ w = w * a
rword *a inlined
  _w d= _a _muls ,
  _bxlr ,

( n -- n*B )
\ signed multiply 32b x 32b = 32b
\ w = w * b
rword *b inlined
  _w d= _b _muls ,
  _bxlr ,

( n -- n X:X*n )
\ signed multiply 32b x 32b = 32b
\ x = x * w
rword x* inlined
  _x d= _w _muls ,
  _bxlr ,

( n -- n Y:Y*n )
\ signed multiply 32b x 32b = 32b
\ y = y * w
rword y* inlined
  _y d= _w _muls ,
  _bxlr ,

( n -- n A:A*n )
\ signed multiply 32b x 32b = 32b
\ a = a * w
rword a* inlined
  _a d= _w _muls ,
  _bxlr ,

( n -- n B:B*n )
\ signed multiply 32b x 32b = 32b
\ b = b * w
rword b* inlined
  _b d= _w _muls ,
  _bxlr ,

\ ********** Register Arithmatic with constants ************

( -- X:X+1 )
\ x = x + 1
rword x+1 inlined
  _x d= 1 _addsi ,
  _bxlr ,

( -- X:X+2 )
\ x = x + 2
rword x+2 inlined
  _x d= 2 _addsi ,
  _bxlr ,

( -- X:X+4 )
\ x = x + 4
rword x+4 inlined
  _x d= 4 _addsi ,
  _bxlr ,

( -- Y:Y+1 )
\ y = y + 1
rword y+1 inlined
  _y d= 1 _addsi ,
  _bxlr ,

( -- Y:Y+2 )
\ y = y + 2
rword y+2 inlined
  _y d= 2 _addsi ,
  _bxlr ,

( -- Y:Y+4 )
\ y = y + 4
rword y+4 inlined
  _y d= 4 _addsi ,
  _bxlr ,

( -- A:A+1 )
\ a = a + 1
rword a+1 inlined
  _a d= 1 _addsi ,
  _bxlr ,

( -- A:A+2 )
\ a = a + 2
rword a+2 inlined
  _a d= 2 _addsi ,
  _bxlr ,

( -- A:A+4 )
\ a = a + 4
rword a+4 inlined
  _a d= 4 _addsi ,
  _bxlr ,

( -- B:B+1 )
\ b = b + 1
rword b+1 inlined
  _b d= 1 _addsi ,
  _bxlr ,

( -- B:B+2 )
\ b = b + 2
rword b+2 inlined
  _b d= 2 _addsi ,
  _bxlr ,

( -- B:B+4 )
\ b = b + 4
rword b+4 inlined
  _b d= 4 _addsi ,
  _bxlr ,

( -- X:X-1 )
\ x = x - 1
rword x-1 inlined
  _x d= 1 _subsi ,
  _bxlr ,

( -- X:X-2 )
\ x = x - 2
rword x-2 inlined
  _x d= 2 _subsi ,
  _bxlr ,

( -- X:X-4 )
\ x = x - 4
rword x-4 inlined
  _x d= 4 _subsi ,
  _bxlr ,

( -- Y:Y-1 )
\ y = y - 1
rword y-1 inlined
  _y d= 1 _subsi ,
  _bxlr ,

( -- Y:Y-2 )
\ y = y - 2
rword y-2 inlined
  _y d= 2 _subsi ,
  _bxlr ,

( -- Y:Y-4 )
\ y = y - 4
rword y-4 inlined
  _y d= 4 _subsi ,
  _bxlr ,

( -- A:A-1 )
\ a = a - 1
rword a-1 inlined
  _a d= 1 _subsi ,
  _bxlr ,

( -- A:A-2 )
\ a = a - 2
rword a-2 inlined
  _a d= 2 _subsi ,
  _bxlr ,

( -- A:A-4 )
\ a = a - 4
rword a-4 inlined
  _a d= 4 _subsi ,
  _bxlr ,

( -- B:B-1 )
\ b = b - 1
rword b-1 inlined
  _b d= 1 _subsi ,
  _bxlr ,

( -- B:B-2 )
\ b = b - 2
rword b-2 inlined
  _b d= 2 _subsi ,
  _bxlr ,

( -- B:B-4 )
\ b = b - 4
rword b-4 inlined
  _b d= 4 _subsi ,
  _bxlr ,

( -- A:A*2 )
\ a = a * 2
rword a*2 inlined
  _a d= _a d= 1 _lslsi ,
  _bxlr ,

( -- B:B*2 )
\ b = b * 2
rword b*2 inlined
  _b d= _b d= 1 _lslsi ,
  _bxlr ,

( -- A:A/2 )
\ a = a / 2
rword a/2 inlined
  _a d= _a d= 1 _lsrsi ,
  _bxlr ,

( -- B:B/2 )
\ b = b / 2
rword b/2 inlined
  _b d= _b d= 1 _lsrsi ,
  _bxlr ,

( -- A:A*4 )
\ a = a * 4
rword a*4 inlined
  _a d= _a d= 2 _lslsi ,
  _bxlr ,

( -- B:B*4 )
\ b = b * 4
rword b*4 inlined
  _b d= _b d= 2 _lslsi ,
  _bxlr ,

( -- A:A/4 )
\ a = a / 4
rword a/4 inlined
  _a d= _a d= 2 _lsrsi ,
  _bxlr ,

( -- B:B/4 )
\ b = b / 4
rword b/4 inlined
  _b d= _b d= 2 _lsrsi ,
  _bxlr ,

\ ********** Register Logical Operations ************

( n1 A:n2 -- n1&n2 A:n2 )
\ w = w and a
rword &a inlined
  _w d= _a _ands ,
  _bxlr ,

( n1 B:n2 -- n1&n2 B:n2 )
\ w = w and b
rword &b inlined
  _w d= _b _ands ,
  _bxlr ,

( n1 X:n2 -- n2 X:n1&n2 )
\ x = x and w
rword x& inlined
  _x d= _w _ands ,
  _bxlr ,

( n1 Y:n2 -- n2 Y:n1&n2 )
\ y = y and w
rword y& inlined
  _y d= _w _ands ,
  _bxlr ,

( n1 A:n2 -- n2 A:n1&n2 )
\ a = a and w
rword a& inlined
  _a d= _w _ands ,
  _bxlr ,

( n1 B:n2 -- n2 B:n1&n2 )
\ b = b and w
rword b& inlined
  _b d= _w _ands ,
  _bxlr ,

( n1 A:n2 -- n1|n2 A:n2 )
\ w = w or a
rword |a inlined
  _w d= _a _orrs ,
  _bxlr ,

( n1 B:n2 -- n1|n2 B:n2 )
\ w = w or b
rword |b inlined
  _w d= _b _orrs ,
  _bxlr ,

( n1 X:n2 -- n1 X:n2|n1 )
\ x = x or w
rword x| inlined
  _x d= _w _orrs ,
  _bxlr ,

( n1 Y:n2 -- n1 Y:n2|n2 )
\ y = y or w
rword y| inlined
  _y d= _w _orrs ,
  _bxlr ,

( n1 A:n2 -- n1 A:n2|n1 )
\ a = a or w
rword a| inlined
  _a d= _w _orrs ,
  _bxlr ,

( n1 B:n2 -- n1 B:n2|n2 )
\ b = b or w
rword b| inlined
  _b d= _w _orrs ,
  _bxlr ,

( n1 A:n2 -- n1^n2 A:n2 )
\ w = w xor a
rword ^a inlined
  _w d= _a _eors ,
  _bxlr ,

( n1 B:n2 -- n1^n2 B:n2 )
\ w = w xor b
rword ^b inlined
  _w d= _b _eors ,
  _bxlr ,

( n1 X:n2 -- n1 X:n2^n1 )
\ x = x xor w
rword x^ inlined
  _x d= _w _eors ,
  _bxlr ,

( n1 Y:n2 -- n1 Y:n2^n1 )
\ y = y xor w
rword y^ inlined
  _y d= _w _eors ,
  _bxlr ,

( n1 A:n2 -- n1 A:n2^n1 )
\ a = a xor w
rword a^ inlined
  _a d= _w _eors ,
  _bxlr ,

( n1 B:n2 -- n1 B:n2^n1 )
\ b = b xor w
rword b^ inlined
  _b d= _w _eors ,
  _bxlr ,

\ ********** initialize register ************

( X:? -- X:0 )
\ x = 0
rword x=0 inlined
  _x d= 0 _movsi ,
  _bxlr ,

( Y:? -- Y:0 )
\ y = 0
rword y=0 inlined
  _y d= 0 _movsi ,
  _bxlr ,

( A:? -- A:0 )
\ a = 0
rword a=0 inlined
  _a d= 0 _movsi ,
  _bxlr ,

( B:? -- B:0 )
\ b = 0
rword b=0 inlined
  _b d= 0 _movsi ,
  _bxlr ,


\ ********** Memory Store and Load ************

( addr A:n32 -- addr A:n32 )
\ store a word in A to RAM address pointed to by W
rword @=a inlined
  _a d= _w d= 0 _str ,
  _bxlr ,

( addr B:n32 -- addr B:n32 )
\ store a word in B to RAM address pointed to by W
rword @=b inlined
  _b d= _w d= 0 _str ,
  _bxlr ,

( addr A:n16 -- addr A:n16 )
\ store a half word in A to RAM address pointed to by W
rword h@=a inlined
  _a d= _w d= 0 _strh ,
  _bxlr ,

( addr B:n16 -- addr B:n16 )
\ store a half word in B to RAM address pointed to by W
rword h@=b inlined
  _b d= _w d= 0 _strh ,
  _bxlr ,

( addr X:n8 -- addr X:n8 )
\ store a character/byte in X to RAM address pointed to by W
rword c@=x inlined
  _x d= _w d= 0 _strb ,
  _bxlr ,

( addr Y:n8 -- addr Y:n8 )
\ store a character/byte in Y to RAM address pointed to by W
rword c@=y inlined
  _y d= _w d= 0 _strb ,
  _bxlr ,

( addr A:n8 -- addr A:n8 )
\ store a character/byte in A to RAM address pointed to by W
rword c@=a inlined
  _a d= _w d= 0 _strb ,
  _bxlr ,

( addr B:n8 -- addr B:n8 )
\ store a character/byte in B to RAM address pointed to by W
rword c@=b inlined
  _b d= _w d= 0 _strb ,
  _bxlr ,

( addr -- addr A:n32 )
\ Read a word (32bit) from memory pointed to by W
\ and store in register A
rword a=@ inlined
  _a d= _w d= 0 _ldr ,
  _bxlr ,

( addr -- addr B:n32 )
\ Read a word (32bit) from memory pointed to by W
\ and store in register B
rword b=@ inlined
  _b d= _w d= 0 _ldr ,
  _bxlr ,

( addr -- addr A:n16 )
\ Read a half word (16bit) from memory pointed to by W
\ and store in register A
rword a=h@ inlined
  _a d= _w d= 0 _ldrh ,
  _bxlr ,

( addr -- addr B:n16 )
\ Read a half word (16bit) from memory pointed to by W
\ and store in register B
rword b=h@ inlined
  _b d= _w d= 0 _ldrh ,
  _bxlr ,

( addr -- n8 )
\ Read a byte (8bit) from memory pointed to by W
\ and store in register W
rword c@ inlined
  _w d= _w d= 0 _ldrb ,
  _bxlr ,

( addr -- addr X:n8 )
\ Read a byte (8bit) from memory pointed to by W
\ and store in register X
rword x=c@ inlined
  _x d= _w d= 0 _ldrb ,
  _bxlr ,

( addr -- addr Y:n8 )
\ Read a byte (8bit) from memory pointed to by W
\ and store in register Y
rword y=c@ inlined
  _y d= _w d= 0 _ldrb ,
  _bxlr ,

( addr -- addr A:n8 )
\ Read a byte (8bit) from memory pointed to by W
\ and store in register A
rword a=c@ inlined
  _a d= _w d= 0 _ldrb ,
  _bxlr ,

( addr -- addr B:n8 )
\ Read a byte (8bit) from memory pointed to by W
\ and store in register B
rword b=c@ inlined
  _b d= _w d= 0 _ldrb ,
  _bxlr ,

( -- n )
\ Read a word (32bit) from memory pointed to by register A
rword @a inlined
  _w d= _a d= 0 _ldr ,
  _bxlr ,

( n -- )
\ store a word to RAM address pointed to by register A
rword @a= inlined
  _w d= _a d= 0 _str ,
  _bxlr ,

( -- n )
\ Read a half word (16bit) from memory pointed to by register A
rword h@a inlined
  _w d= _a d= 0 _ldrh ,
  _bxlr ,

( h -- h )
\ store a half word to RAM address pointed to by register A
rword h@a= inlined
  _w d= _a d= 0 _strh ,
  _bxlr ,

( -- n )
\ Read a byte from memory pointed to by register X
rword c@x inlined
  _w d= _x d= 0 _ldrb ,
  _bxlr ,

( c -- )
\ store a single byte to RAM address pointed to by register X
rword c@x= inlined
  _w d= _x d= 0 _strb ,
  _bxlr ,

( -- n )
\ Read a byte from memory pointed to by register Y
rword c@y inlined
  _w d= _y d= 0 _ldrb ,
  _bxlr ,

( c -- )
\ store a single byte to RAM address pointed to by register Y
rword c@y= inlined
  _w d= _y d= 0 _strb ,
  _bxlr ,

( -- n )
\ Read a byte from memory pointed to by register A
rword c@a inlined
  _w d= _a d= 0 _ldrb ,
  _bxlr ,

( c -- )
\ store a single byte to RAM address pointed to by register A
rword c@a= inlined
  _w d= _a d= 0 _strb ,
  _bxlr ,

( -- n )
\ Read a word (32bit) from memory pointed to by register B
rword @b inlined
  _w d= _b d= 0 _ldr ,
  _bxlr ,

( n -- n )
\ store a word to RAM address pointed to by register B
rword @b= inlined
  _w d= _b d= 0 _str ,
  _bxlr ,

( -- n )
\ Read a half word (16bit) from memory pointed to by register B
rword h@b inlined
  _w d= _b d= 0 _ldrh ,
  _bxlr ,

( h -- h )
\ store a half word to RAM address pointed to by register B
rword h@b= inlined
  _w d= _b d= 0 _strh ,
  _bxlr ,

( -- n )
\ Read a byte from memory pointed to by register B
rword c@b inlined
  _w d= _b d= 0 _ldrb ,
  _bxlr ,

( c -- )
\ store a single byte to RAM address pointed to by register B
rword c@b= inlined
  _w d= _b d= 0 _strb ,
  _bxlr ,

\ ********** register shifting ************

( n Y:n2 -- n<<n2 )
\ left shift working register by value in Y register
rword <<y inlined
  _w d= _y _lsls ,
  _bxlr ,

( n Y:n2 -- n>>n2 )
\ right shift working register by value in Y register
rword >>y inlined
  _w d= _y _lsrs ,
  _bxlr ,

( n X:n2 -- n<<n2 )
\ left shift working register by value in X register
rword <<x inlined
  _w d= _x _lsls ,
  _bxlr ,

( n X:n2 -- n>>n2 )
\ right shift working register by value in X register
rword >>x inlined
  _w d= _x _lsrs ,
  _bxlr ,

\ ********** Return Stack ************

\ push X register value onto return stack
( -- ) ( R: -- x )
rword r=x inlined
  _x y= 1 <<y _push ,
  _bxlr ,

\ push Y register value onto return stack
( -- ) ( R: -- y )
rword r=y inlined
  _y y= 1 <<y _push ,
  _bxlr ,

\ push A register value onto return stack
( -- ) ( R: -- a )
rword r=a inlined
  _a y= 1 <<y _push ,
  _bxlr ,

\ push B register value onto return stack
( -- ) ( R: -- b )
rword r=b inlined
  _b y= 1 <<y _push ,
  _bxlr ,

\ push dsp register value onto return stack
( -- ) ( R: -- dsp )
rword r=dsp inlined
  _dsp y= 1 <<y _push ,
  _bxlr ,

\ pop value from return stack into register X
( -- X:x ) ( R: x -- )
rword x=r inlined
  _x y= 1 <<y _pop ,
  _bxlr ,

\ pop value from return stack into register Y
( -- Y:y ) ( R: y -- )
rword y=r inlined
  _y y= 1 <<y _pop ,
  _bxlr ,

\ pop value from return stack into register A
( -- A:a ) ( R: a -- )
rword a=r inlined
  _a y= 1 <<y _pop ,
  _bxlr ,

\ pop value from return stack into register B
( -- B:b ) ( R: b -- )
rword b=r inlined
  _b y= 1 <<y _pop ,
  _bxlr ,

\ move link register into working register
( -- lr )
rword _lr inlined
  _w d= __lr _mov ,
  _bxlr ,



