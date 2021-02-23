\ float.fs words that deal with floating point numbers

\ print floating point number
\ no exponent support
: .f ( f -- )
  d= i d=        ( f i i ) 
  ..             ( f i ? )
  [char] . emit
  d0 f x=        ( f i nf X:nf )
  d1 f-          ( f i f-nf )
  d= base x=
  *x *x *x *x *x *x f
  x=             ( f i fr  X:10000000.0f )
  d f* i         ( f i fr*10000000.0f )
  abs            ( f i n )
  <# # # # # # # # #>
  type space
  d-2            ( ? )
;

: pi ( -- 3.141592 )
  3.14159265
;

\ convert float angle in degrees to radians
: rad ( deg -- rad )
  x# 180. f/ x= pi f*
;
