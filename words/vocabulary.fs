\ vocabulary.fs - words for managing the words

\ get context index address
: contidx ( -- addr )
  context 2-
;

\ increment context idx by 1
: contidx++ ( * -- contidx )
  contidx y=h@ y+1 h@=y
;

\ change value of context index
: contidx= ( val -- )
  y= contidx h@=y 
;

\ get context array address using context index
: context# ( -- addr )
  context d= contidx@ y=d dcell* +y
;

\ get a wordlist id from context array
: context@ ( -- wid )
  context# @
;

\ save wordlist id in context array at context index
: context= ( wid -- addr )
  d= context# y=d @=y
;

\ get a valid wid from the context
\ tries to get the top vocabulary
\ if no valid entries then defaults to Forth wid
: wid@ ( -- wid )
  context@
  ==0 ifnz else context @ then
;

\ wordlist record fields:
\ [0] word:dcell: address to nfa of most recent word
\     added to this wordlist
\ [1] Name:dcell: address to nfa of vocabulary name 
\ [2] link:dcell: address to previous sibling wordlist to form
\     vocabulary linked list
\ [3] child:dcell: address to head of child wordlist

\ add link field offset
: wid:link ( wid -- wid:link) dcell+ dcell+ ;
\ add child field offset
: wid:child ( wid -- wid:child ) y= 3 dcell* +y ;

\ initialize wid fields of definitions vocabulary
: widinit ( wid -- wid )
  x=          ( wid X:wid )
  \ wid.word = 0
  y=0 @=y     ( wid )
  \ parent wid child field is in cur@->child
  cur@        ( parentwid )
  wid:child   ( parentwid.child )
  d=          ( parentwid.child parentwid.child )
  y=@         ( parentwid.child parentwid.child Y:childLink )
  x wid:link  ( parentwid.child wid.link )
  \ wid.link = childLink
  @=y         ( parentwid.child wid.link )
  \ wid.child = 0
  dcell+ y=0
  @=y         ( parentwid.child wid.child )
  \ parentwid.child = wid
  =d          ( parentwid.child )
  @=x x       ( wid )
;

\ make a wordlist record in data ram
\ and initialize the fields
: wordlist ( -- wid )
  \ get next available ram from here and use as wid
  here                  ( wid )   
  \ allocate  4 data cells in ram for the 4 fields
  d= 4 dcell* allot  =d ( wid )

  widinit ( wid )
;

\ similar to dup : duplicate current wordlist in vocabulary search list
\ normally used to add another vocabulary to search list
\ ie: also MyWords
: also ( -- )
  context@ d=
  \ increment index
  contidx++ =d
  context=  
; immediate

\ removes most recently added wordlist from vocabulary search list
: prev ( -- )
  \ get current index and decrement by 1
  contidx@       ( idx ) 
  1- d=          ( idx-1 idx-1 )
  \ index must be >= 1
  >0 ==0         ( idx-1 flag )
  ifnz
    0 context=   ( idx-1 ? ) 
    d0 contidx=  ( idx-1 ? )
  else
    [compile] only
  then
  d-1
; immediate

\ Used in the form:
\ cccc def
\ Set the CURRENT vocabulary to the CONTEXT vocabulary - where new
\ definitions are put in the CURRENT word list. In the
\ example, executing vocabulary name cccc made it the CONTEXT
\ vocabulary (for word searches) and executing DEFINITIONS
\ made both specify vocabulary
\ cccc.

: def
    context@
    ==0 ifnz y= current @=y then
; immediate

\ A defining word used in the form:
\     vocabulary cccc  
\ to create a vocabulary definition cccc. Subsequent use of cccc will
\ make it the CONTEXT vocabulary which is searched first by INTERPRET.
\ The sequence "cccc DEFINITIONS" will also make cccc the CURRENT
\ vocabulary into which new definitions are placed.

\ By convention, vocabulary names are automaticaly declared IMMEDIATE.

: voc: ( -- ) ( C:cccc )
  create
  immediate
  \ allocate space in ram for head and tail of vocab word list
  wordlist d=    ( wid wid )
  d,             ( wid ? )
  \ wid.name = vocabulary.nfa  
  cur@ @ y= =d   ( wid Y:voc.nfa )
  dcell+ @=y     ( wid.name )

  does>
   @ \ get header address
   \ make this vocabulary the active search context
   context=
;

\ Set context to Forth vocabulary
: Forth ( -- )
  context @ context=
; immediate

\ setup forth name pointer in forth wid name field
\ get forth nfa - its the most recent word created
cur@ @ d= ( nfa nfa )
\ get the forth wid, initialize it and set name field
\ forthwid.word is already initialized
context @ dcell+ ( nfa forthwid.name )
\ forthwid.name = nfa
y=d @=y          ( forthwid.name )
\ forthwid.link = 0
dcell+ y=0 @=y   ( forthwid.link )
\ forthwid.child = 0
dcell+ y=0 @=y   ( )

\ print name field
: .nf ( nfa -- )
      $l y= $FF &y   ( addr cnt ) \ mask immediate bit
      type space     ( ? )
;
 
\ list words starting at a name field address
: lwords ( nfa -- )
  d= 0 d=                  ( nfa 0 0 )
  d1                       ( nfa cnt nfa )
  begin
    ==0
  whilenz                  ( nfa cnt nfa ) \ is nfa = counted string
    .nf                    ( nfa cnt ? )
    d0 +1 d0=              ( nfa' cnt+1 cnt+1 )
    d1 nfa>lfa             ( nfa cnt lfa )
    @ d1=                  ( nfa' cnt addr )
  repeat 
  cr ." count: " d0 .
  d-2
;

\ List the names of the definitions in the context vocabulary.
\ Does not list other linked vocabularies.
\ Use words to see all words in the top context search.
: words ( -- )
    wid@ ( wid )
    @    ( nfa )
    lwords
;

\ list the root words
: rwords ( -- )
  [ find WIPE #, ]
  lwords
;

\ print out search list of active vocabularies
: order ( -- )
  ." Search: "
  \ get context index and use as counter
  contidx@ d=                ( idx idx )
  begin
  \ iterate through vocab array and print out vocab names
    ==0
  whilenz
    dcell* y= context +y     ( idx context' )
    \ get context wid
    @                        ( idx wid )
    \ if not zero then print vocab name 
    ==0
    ifnz
      \ next cell has name field address 
      dcell+ @               ( idx nfa )
      .nf                    ( idx ? )
    else
      ." [] "
    then
    \ decrement index
    d0 1- d0=
  repeat
  =d
  ." Forth Root" cr
  ." definitions: "
  cur@ dcell+ @ .nf cr
;

\ print child vocabularies
: .childvocs ( spaces wid -- )
  begin
  \ while link is not zero
  ==0
  whilenz  ( spaces linkwid )
    \ print indent
    d= d1 spaces ." |- " ( spaces linkwid ? )
    \ get name from name field
    d0 dcell+ d0= @      ( spaces linkwid.name name )
    \ print name and line feed
    .nf cr               ( spaces link.name ? )
    \ increase spaces for indenting child vocabularies
    d1 +4 d=             ( spaces linkwid.name spaces+4 spaces+4 )
    \ get link field
    d1 dcell+ d1=        ( spaces linkwid.link spaces+4 linkwid.link )
    \ get child link and recurse: print child vocabularies
    dcell+ @             ( spaces linkwid.link spaces+4 childwid )
    recurse              ( spaces linkwid.link )
    \ get link for next sibling
    @
  repeat
  d-1 =d
;

\ list context vocabulary and all child vocabularies
\ order is newest to oldest
: vocs ( -- )
  \ start spaces at 2
  d= 2          ( ? 2 )
  \ get top search vocabulary address
  \ it is the head of the vocabulary linked list
  d= wid@       ( ? 2 wid )
  \ print context vocabulary
  d= dcell+     ( ? 2 wid wid.name )
  @ .nf cr =d   ( ? 2 wid )
  \ get child link of linked list
  wid:child @   ( ? 2 childwid )
  .childvocs cr ( ? )
;
