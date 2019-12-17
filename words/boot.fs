\ boot.fs - bootstrap the forth compiler
\ header and (create) are created manually
\ use (create) to make : then define the rest manually

\ header ( addr len wid -- nfa )
\ build header entry in dictionary 
dp push         \ ( nfa nfa ) name field address
pname header push y= $FF00 w|=y @dp=s \ ( nfa ? )
  current @ @   \ ( nfa linkaddr ) get latest word
  @dp=          \ ( nfa ? ) set link field to prev word in vocab
  cp @dp= pop   \ ( nfa ) set code pointer field
  smudge=       \ ( ? )
  pushlr, 
  ]
    push dp     \ ( addr len wid nfa )
    rpush       \ ( addr len wid nfa ) (R: nfa )
    pop         \ ( addr len wid )
    rpush       \ ( addr len wid ) (R: nfa wid )
    y=d0        \ ( addr len wid Y:len )
    $FF00 w|=y  \ ( addr len len|$FF00 )
    @dp=s       \ ( ? )
    rpop @      \ ( linkaddr ) (R: nfa )
    @dp=        \ ( ? )
    rpop        \ ( nfa ) (R: )
  [
  ;opt
  uwid

\ (create) ( <input> -- nfa )
\ create a dictionay entry along with entry for start of code
pname (create) push current @ header \ ( nfa )
  push cp       \ ( nfa cp )
  @dp= pop      \ ( nfa )
  smudge=       \ ( ? )
  pushlr, 
  ]
    pname push current @ header push cp @dp= pop
  [
  ;opt
  uwid

\ : ( <input> -- )
\ used to define a new word
(create) :
  smudge=
  pushlr,
  ]
    (create) smudge= pushlr, ]
  [
  ;opt
  uwid

: cur@
    current @
  [
  ;opt uwid

\ ( n -- )
\ set wid flags of current word
: widf
    y=w        \ ( n ) y; n
    cur@ @ x=w \ ( nfa ) X: nfa
    h@x        \ ( flags )
    w&=y       \ ( n&flags )
    h@x=w      \ ( n&flags )
  [
  ;opt uwid

: immediate
    $7FFF widf
  [
  ;opt uwid

\ define ; which is used when finishing the compiling of a word
: ;
  \ change to interpret mode and override to compile [
  [ pname [ findw nfa>xtf cxt ]
  \ back in compile mode
    ;opt uwid
[ ;opt uwid immediate

