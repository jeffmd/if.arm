\ minimum.fs words that make up minimum forth vocabulary

\ check if n is within min..max
\ flag is 1 if min <= n <= max
: within ( n min max -- f)
  y=d        ( n max Y:min )
  x=d0       ( n max Y:min X:n )
  -y         ( n diff )
  x-y        ( n diff X:n-min )
  d0=x       ( n-min diff ) 
  u<         ( flag )
;

\ increment a cvar by one.  If val > max then set flag to true.
: 1+c@mx ( maxval cvar -- flag )
  y=d       ( cvar Y:maxval ) 
  x= c@x    ( val X:cvar )
  +1 d=     ( val+1 val+1 )
  y >       ( val+1 flag )
  ==0
  ifnz 0 then
  d= c@x= 0=
;

\ divide n1 by n2 giving the remainder n3
: mod ( n1 n2 -- n3 )
  /mod =d
;

\ emits a space (bl)
: space ( -- )
  bl emit
;

\ emits n space(s) (bl)
\ only accepts positive values
: spaces ( n -- )
  \ make sure a positive number
  y= >0 &y
  d=
  ==0
  begin
  whilenz
    space
    d0 1- d0=
  repeat
  d-1
;

\ pointer to current write position
\ in the Pictured Numeric Output buffer
var: hld


\ prepend character to pictured numeric output buffer
: hold ( c -- )
  x= hld y=
  @y 1- @y=  
  c@=x
;

\ Address of the temporary scratch buffer.
: pad ( -- a-addr )
    here y# 100 +y
;

\ initialize the pictured numeric output conversion process
: <# ( -- )
    d= pad y= hld @=y =d
;

\ start null terminated buffer
: <#_ ( n -- n n )
  <# d= 0 hold
;

\ pictured numeric output: convert one digit
: # ( u1 -- u2 )
  d= base    ( u1 base )
  /mod       ( rem u2 )
  y=d0 d0= y ( u2 rem )
  #h hold =d ( u2 )
;

\ pictured numeric output: convert all digits until 0 (zero) is reached
: #s ( u -- 0 )
  #
  begin
    ==0
  whilenz
    #
  repeat
;

\ copy string to numeric output buffer
: #$ ( addr len -- )
\ start at end of string
  d=        ( addr len len )
  begin
    d0
    ==0
  whilenz
    1- d0= y=
    d1 +y c@ hold
  repeat
  d-2    
;

\ Pictured Numeric Output: convert PNO buffer into an string
: #> ( u1 -- addr count )
  hld @ d= x=  ( addr addr X:addr ) 
  pad -x       ( addr count )
;

\ place a - in HLD if n is negative
: sign ( n -- )
  <0 ==0 
  ifnz
   [char] - hold
  then
;

\ convert base to prefix character
: prefix ( base -- c )
\ if base not dec then determine corresponding prefix character
\ base character
\  10    space
\  16     $
\   8     &
\   2     %
  d=          ( base base )
  x# 16 -x
  ifz
    [char] $ 
  else
    d0 x# 8 -x
    ifz
      [char] &
    else
      d0 x# 2 -x
      ifz
        [char] %
      else
        bl
      then
    then
  then

  d-1
;

\ singed PNO with cell numbers, right aligned in width w
: rn$ ( wantsign n w -- addr len )
  r= =d   ( wantsign n ) ( R: w )
  <# #s   ( wantsign 0 )
     =d sign ( ? )
     base prefix hold
  #>      ( addr len )
  d= =r   ( addr len w )  ( R: )
  y=d0    ( addr len w Y:len )
  -y      ( addr len spaces )
  spaces  ( addr len ? )
  =d      ( addr len )
;

\ unsigned PNO with single cell numbers
: .u ( u -- )
  d= d= 0 ( n n 0 ) \ want unsigned
  d1=     ( 0 n 0 )
  rn$ type
  space
;


\ signed PNO with single cell numbers
: .  ( n -- )
  d=       ( n n )
  abs      ( n n' )
  d= 0     ( n n' 0 ) \ not right aligned
  rn$ type
  space
;

\ signed print with no space at end
: ..  ( n -- )
  d=       ( n n )
  abs      ( n n' )
  d= 0     ( n n' 0 ) \ not right aligned
  rn$ type
;

\ stack dump
\ prints stack contents from bottom to top with
\ working register printed last
: .s  ( -- )
  d=          ( ? ? )
  dsp         ( ? limit ) \ setup limit
  dcell-
  d= dsp0     ( ? limit counter )
  begin
    dcell-    ( ? limit counter-4 )
    y=d0 d=   ( ? limit counter-4 counter-4 Y:limit  )
    d=y       ( ? limit counter-4 limit counter-4 )
    !=        ( ? limit counter-4 flag )
    ==0
  whilenz
    d0        ( ? limit counter-4 counter-4 )
    @         ( ? limit counter-4 val )
    . =d      ( ? limit counter-4 )
  repeat
  d-2 =d
;

\ 1 millisecond delay
( -- )
: 1ms 1000 usleep ;

\ set name as the background task that
\ executes each time pause executes
( char:name -- )
: dopause ' pause= ;

\ put a null at end of string
: $_ ( addr len -- addr )
  \ [addr + len] = 0
  y=d x=0 +y c@=x y
;

