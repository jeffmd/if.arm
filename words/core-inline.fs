\ core-inline.fs - core inlined words

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
  _x d= _dsp d= 0 _ldr ,
  _bxlr ,

( n2 n1 -- n2 n1 A:n2 )
\ d0 WR
rword a=d0 inlined
  _a d= _dsp d= 0 _ldr ,
  _bxlr ,

( n2 n1 -- n2 n1 B:n2 )
\ d0 WR
rword b=d0 inlined
  _b d= _dsp d= 0 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 X:n3 )
\ d1 d0 WR
rword x=d1 inlined
  _x d= _dsp d= 1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 Y:n3 )
\ d1 d0 WR
rword y=d1 inlined
  _y d= _dsp d= 1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 A:n3 )
\ d1 d0 WR
rword a=d1 inlined
  _a d= _dsp d= 1 _ldr ,
  _bxlr ,

( n3 n2 n1 -- n3 n2 n1 B:n3 )
\ d1 d0 WR
rword b=d1 inlined
  _b d= _dsp d= 1 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 X:n4 )
\ d2 d1 d0 WR
rword x=d2 inlined
  _x d= _dsp d= 2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 Y:n4 )
\ d2 d1 d0 WR
rword y=d2 inlined
  _y d= _dsp d= 2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 A:n4 )
\ d2 d1 d0 WR
rword a=d2 inlined
  _a d= _dsp d= 2 _ldr ,
  _bxlr ,

( n4 n3 n2 n1 -- n4 n3 n2 n1 B:n4 )
\ d2 d1 d0 WR
rword b=d2 inlined
  _b d= _dsp d= 2 _ldr ,
  _bxlr ,

(  ? n2 -- n1 n2 X:n1 )
\ d0 WR
rword d0=x inlined
  _x d= _dsp d= 0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 Y:n1 )
\ d0 WR
rword d0=y inlined
  _y d= _dsp d= 0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 A:n1 )
\ d0 WR
rword d0=a inlined
  _a d= _dsp d= 0 _str ,
  _bxlr ,

(  ? n2 -- n1 n2 B:n1 )
\ d0 WR
rword d0=b inlined
  _b d= _dsp d= 0 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 X:n1 )
\ d1 d0 WR
rword d1=x inlined
  _x d= _dsp d= 1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 Y:n1 )
\ d1 d0 WR
rword d1=y inlined
  _y d= _dsp d= 1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 A:n1 )
\ d1 d0 WR
rword d1=a inlined
  _a d= _dsp d= 1 _str ,
  _bxlr ,

(  ?  ? n2 -- n1 ? n2 B:n1 )
\ d1 d0 WR
rword d1=b inlined
  _b d= _dsp d= 1 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 X:n1 )
\ d2 d1 d0 WR
rword d2=x inlined
  _x d= _dsp d= 2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 Y:n1 )
\ d2 d1 d0 WR
rword d2=y inlined
  _y d= _dsp d= 2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 A:n1 )
\ d2 d1 d0 WR
rword d2=a inlined
  _a d= _dsp d= 2 _str ,
  _bxlr ,

(  ?  ?  ? n2 -- n1 ? ? n2 B:n1 )
\ d2 d1 d0 WR
rword d2=b inlined
  _b d= _dsp d= 2 _str ,
  _bxlr ,

\ (  -- addr )
\ current data stack pointer
rword dsp inlined
  _w d= _dsp _mov ,
  _bxlr ,

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

( -- X:X+1 )
\ x = x + 1
rword x+=1 inlined
  _x d= 1 _addsi ,
  _bxlr ,

( -- X:X+2 )
\ x = x + 2
rword x+=2 inlined
  _x d= 2 _addsi ,
  _bxlr ,

( -- X:X+4 )
\ x = x + 4
rword x+=4 inlined
  _x d= 4 _addsi ,
  _bxlr ,

( -- Y:Y+1 )
\ y = y + 1
rword y+=1 inlined
  _y d= 1 _addsi ,
  _bxlr ,

( -- Y:Y+2 )
\ y = y + 2
rword y+=2 inlined
  _y d= 2 _addsi ,
  _bxlr ,

( -- Y:Y+4 )
\ y = y + 4
rword y+=4 inlined
  _y d= 4 _addsi ,
  _bxlr ,

( -- A:A+1 )
\ a = a + 1
rword a+=1 inlined
  _a d= 1 _addsi ,
  _bxlr ,

( -- A:A+2 )
\ a = a + 2
rword a+=2 inlined
  _a d= 2 _addsi ,
  _bxlr ,

( -- A:A+4 )
\ a = a + 4
rword a+=4 inlined
  _a d= 4 _addsi ,
  _bxlr ,

( -- B:B+1 )
\ b = b + 1
rword b+=1 inlined
  _b d= 1 _addsi ,
  _bxlr ,

( -- B:B+2 )
\ b = b + 2
rword b+=2 inlined
  _b d= 2 _addsi ,
  _bxlr ,

( -- B:B+4 )
\ b = b + 4
rword b+=4 inlined
  _b d= 4 _addsi ,
  _bxlr ,

( -- X:X-1 )
\ x = x - 1
rword x-=1 inlined
  _x d= 1 _subsi ,
  _bxlr ,

( -- X:X-2 )
\ x = x - 2
rword x-=2 inlined
  _x d= 2 _subsi ,
  _bxlr ,

( -- X:X-4 )
\ x = x - 4
rword y-=4 inlined
  _x d= 4 _subsi ,
  _bxlr ,

( -- Y:Y-1 )
\ y = y - 1
rword a-=1 inlined
  _y d= 1 _subsi ,
  _bxlr ,

( -- Y:Y-2 )
\ y = y - 2
rword y-=2 inlined
  _y d= 2 _subsi ,
  _bxlr ,

( -- Y:Y-4 )
\ y = y - 4
rword y-=4 inlined
  _y d= 4 _subsi ,
  _bxlr ,

( -- A:A-1 )
\ a = a - 1
rword a-=1 inlined
  _a d= 1 _subsi ,
  _bxlr ,

( -- A:A-2 )
\ a = a - 2
rword a-=2 inlined
  _a d= 2 _subsi ,
  _bxlr ,

( -- A:A-4 )
\ a = a - 4
rword a-=4 inlined
  _a d= 4 _subsi ,
  _bxlr ,

( -- B:B-1 )
\ b = b - 1
rword b-=1 inlined
  _b d= 1 _subsi ,
  _bxlr ,

( -- B:B-1 )
\ b = b - 1
rword b-=1 inlined
  _b d= 1 _subsi ,
  _bxlr ,

( -- B:B-4 )
\ b = b - 4
rword b-=4 inlined
  _b d= 4 _subsi ,
  _bxlr ,

( -- n )
\ Read a word (32bit) from memory pointed to by register A
rword @a inlined
  _w d= _a d= 0 _ldr ,
  _bxlr ,

( n -- )
\ store a word to RAM address pointed to by areg
rword @a= inlined
  _w d= _a d= 0 _str ,
  _bxlr ,

( -- n )
\ Read a half word (16bit) from memory pointed to by register A
rword h@a inlined
  _w d= _a d= 0 _ldrh ,
  _bxlr ,

( h -- h )
\ store a half word to RAM address pointed to by areg
rword h@a= inlined
  _w d= _a d= 0 _strh ,
  _bxlr ,

( -- n )
\ Read a byte from memory pointed to by register A
rword c@a inlined
  _w d= _a d= 0 _ldrb ,
  _bxlr ,

( c -- )
\ store a single byte to RAM address pointed to by areg
rword c@a= inlined
  _w d= _a d= 0 _strb ,
  _bxlr ,

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

\ push X register value onto return stack
( reg -- ) ( R: -- x )
rword r=x inlined
  _x y= 1 <<y _push ,
  _bxlr ,

\ push Y register value onto return stack
( reg -- ) ( R: -- y )
rword r=y inlined
  _y y= 1 <<y _push ,
  _bxlr ,

\ push A register value onto return stack
( reg -- ) ( R: -- a )
rword r=a inlined
  _a y= 1 <<y _push ,
  _bxlr ,

\ push B register value onto return stack
( reg -- ) ( R: -- b )
rword r=b inlined
  _b y= 1 <<y _push ,
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

