only

\ Tools
\ Amount of available RAM (incl. PAD)
: unused ( -- n )
    here y= cp0 -y
;

\ dump memory to screen
: dmp ( addr1 cnt -- addr2 )
  d= d1 .$ [char] : emit space
  begin
    d0 ==0
  whilenz
    1- d0= 
    d1 @ .$
    d1 dcell+ d1=
  repeat
  d-1 =d
;

\ Tools
\ print the contents at ram word addr
: ? ( addr -- ) 
  @ .
;

\ print the contents at ram char addr
: c? ( addr -- )
  c@ .
;

\ set the bits of an 8 bit register port
\ bits set defined by bit pattern in bbb
: rbs ( bbb reg -- )
  y=d x= c@ |y c@x=
;

\ clear the bits of reg defined by bit pattern in bbb
: rbc ( bbb reg -- )
  x= y=d !y
  c@x &y c@x=
;

\ modify bits of reg defined by mask
: rbm ( val mask reg -- )
  x= y=d
  c@x &y y=d |y c@x=
;

\ tools
\ read register/ram byte contents and print in binary form
: rb? ( reg -- )
  c@ x= bin x <# # # # # # # # # #> type space decimal
;

\ read register/ram byte contents and print in hex form
: r? ( reg -- )
  c@ .$
;

\ setup fence which is the lowest address that we can forget words
var fence

\ set fence
: fence= ( addr -- )
  y= fence @=y
;

find r? fence= 


\ can only forget a name that is in the current definition
: forget ( c: name -- )
  pname             ( addr cnt )
  d= cur@           ( addr cnt wid )
  findnfa           ( nfa )
  ==0
  ifnz
    \ nfa must be greater than fence
    d=              ( nfa nfa)
    d= fence @      ( nfa nfa fence )
    > ==0           ( nfa nfa>fence )
    =d              ( nfa )
    ifnz
      \ nfa is valid
      \ set dp to nfa
      dp=           ( dp# Y:nfa )
      \ set context wid to lfa
      y nfa>lfa     ( lfa )
      @ y=          ( nfa Y:nfa)
      cur@          ( wid )
      @=y           ( wid )
    then
  then
;

find forget fence=

\ create a marker word
\ when executed it will restore dp, here and current
\ back to when marker was created
: marker  ( c: name -- )
  \ copy current word list, current wid, dp, here
  cur@ d=            ( wid wid )
  @ d=               ( wid nfa nfa )
  dp d=              ( wid nfa dp dp )
  here d=            ( wid nfa dp here here )
  create             ( wid nfa dp here ? )
  \ save here, dp, current wid, current word list
  =d d, =d d, =d d, =d d,

  does> ( addr )
    \ restore here
    x= y=@ here# @=y
    \ restore dp
    x+4 @x dp=
    \ restore current wid
    x+4 @x y= 
    x+4 @x @=y
    \ only Forth and Root are safe vocabs
    [compile] only
;
