\ boot.fs - bootstrap the forth compiler
\ header and (create) are created manually
\ use (create) to make : then define the rest manually

\ header ( addr len wid -- nfa )
\ build header entry in dictionary 
dp d=           \ ( nfa nfa ) name field address
pname header d= y# $FF00 |y @dp=s \ ( nfa ? )
  current# @ @  \ ( nfa linkaddr ) get latest word
  @dp=          \ ( nfa ? ) set link field to prev word in vocab
  cp @dp= =d    \ ( nfa ) set code pointer field
  nword=        \ ( ? )
  _pushlr , 
  ]
    d= dp       \ ( addr len wid nfa )
    r=          \ ( addr len wid nfa ) (R: nfa )
    =d          \ ( addr len wid )
    r=          \ ( addr len wid ) (R: nfa wid )
    y=d0        \ ( addr len wid Y:len )
    $FF00 |y    \ ( addr len len|$FF00 )
    @dp=s       \ ( ? )
    =r @        \ ( linkaddr ) (R: nfa )
    @dp=        \ ( ? )
    =r          \ ( nfa ) (R: )
  [
  ;opt
  uwid

\ (create) ( <input> -- nfa )
\ create a dictionay entry along with entry for start of code
pname (create) d= current# @ header \ ( nfa )
  d= cp         \ ( nfa cp )
  @dp= =d       \ ( nfa )
  nword=        \ ( ? )
  _pushlr , 
  ]
    pname d= current# @ header d= cp @dp= =d
  [
  ;opt
  uwid

\ : ( <input> -- )
\ used to define a new word
(create) :
  nword=
  _pushlr ,
  ]
    (create) nword= _pushlr , ]
  [
  ;opt
  uwid

\ ( -- wlid )
\ get current word list
: current
    current# @
  [
  ;opt uwid

\ ( wlid -- )
\ set current word list
: current=
    y= current# @=y
  [
  ;opt uwid

\ ( nfa -- wlid )
\ wlid.nfa = nfa
\ add word to current word list
: current+
    y= current @=y
  [
  ;opt uwid

\ ( n -- )
\ set wid flags of current word
: widf
    y=         \ ( n ) Y:n
    current @  \ ( nfa )
    x=         \ ( nfa ) X:nfa
    h@x        \ ( flags )
    &y         \ ( n&flags )
    h@x=       \ ( n&flags )
  [
  ;opt uwid

: immediate
    $7FFF widf
  [
  ;opt uwid

\ define ; which is used when finishing the compiling of a word
: ;
  \ change to interpret mode and override to compile [
  [ pname [ findw nfa>xtf xt, ]
  \ back in compile mode
    ;opt uwid
[ ;opt uwid immediate
