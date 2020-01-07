\ core-inline.fs - core inlined words

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
