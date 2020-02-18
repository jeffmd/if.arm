only

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

\ read register/ram byte contents and print in binary form
: rb? ( reg -- )
  c@ x= bin x <# # # # # # # # # #> type space dec
;

\ read register/ram byte contents and print in hex form
: r? ( reg -- )
  c@ .$
;

\ setup fence which is the lowest address that we can forget words
var: fence#

: fence ( -- fence )
  fence# @
;

\ set fence if word in context
: fence= ( C:word -- )
  find
  ==0
  ifnz
    y= fence# @=y
  else
    ." word not found" cr
  then
;

\ forget all words definned after wordname including wordname
\ only works if wordname is in the current definition
\ cp and dp get set to what the word used
: forget ( c: wordname -- )
  pname             ( addr cnt )
  d= current        ( addr cnt wlid )
  findnfa           ( nfa )
  ==0
  ifnz
    \ nfa must be greater than fence
    d=              ( nfa nfa)
    d= fence        ( nfa nfa fence )
    > ==0           ( nfa nfa>fence )
    =d              ( nfa )
    ifnz
      \ nfa is valid
      \ set dp to nfa
      dp=           ( dp# Y:nfa )
      \ set current wlid to lfa
      y d=y nfa>lfa ( nfa lfa )
      @             ( nfa wid )
      current+      ( nfa wlid )
      =d            ( nfa )
      \ set cp to xt
      nfa>xtf =d    ( xt )
      cp=           ( cp# Y:xt )
    else
      ." can't forget, word behind fence" cr
    then
  else
    ." word not found" cr
  then
;

fence= forget

\ create a marker word
\ when executed it will restore dp, cp, here, and current
\ back to when marker was created
: marker  ( c: name -- )
  \ copy current word list, current wid, dp, cp, here
  current d=         ( wlid wlid )
  @ d=               ( wlid nfa nfa )
  dp d=              ( wid nfa dp dp )
  cp d=              ( wid nfa dp cp )
  here d=            ( wid nfa dp here here )
  create             ( wid nfa dp here ? )
  \ save here, cp, dp, current wid, current word list
  =d d, \ here
  =d d, \ cp
  =d d, \ dp
  =d d, \ wid
  =d d, \ wlid

  does> ( addr )
    \ restore here
    x= @ here=
    \ restore cp
    x+4 @x cp=
    \ restore dp
    x+4 @x dp=
    \ restore current wid
    x+4 @x y=
    \ restore wordlist with wid as last entry 
    x+4 @x @=y
    \ only Forth and Root are safe vocabs
    [compile] only
;
