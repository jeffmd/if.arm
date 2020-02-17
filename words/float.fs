\ float.fs words that deal with floating point numbers

\ print floating point number
: .f ( f -- )
  d= i d=        ( f i i ) 
  ..             ( f i ? )
  ." ."
  d0 f x=        ( f i nf X:nf )
  d1 f-          ( f i f-nf )
  d= 10000 f x=  ( f i fr 10000.0f X:10000.0f )
  =d f* i        ( f i fr*10000.0f )
  .              ( f i ? )
  d-2            ( ? )
;

