\ vocabulary.fs - words for managing the words

\ get context index address
: contidx# ( -- addr )
  context# 2-
;

\ increment context idx by 1
: contidx++ ( * -- contidx )
  contidx# y=h@ y+1 h@=y
;

\ change value of context index
: contidx= ( val -- )
  y= contidx# h@=y 
;

\ get context array address using index
: context[]# ( idx -- addr )
  *dcell y= context# +y
;

\ get a wordlist id from context array
: context ( -- wlist )
  contidx context[]# @
;

\ save wordlist id in context array at context index
: context= ( wlist -- addr )
  d= contidx context[]# y=d @=y
;

\ get a valid wlist from the context
\ tries to get the top vocabulary
\ if no valid entries then defaults to root Forth wlid
: wlist ( -- wlist )
  context
  ==0
  ifz
    \ no valid word list found
    \ default to root word list
    context# @
  then
;


\ wordlist record fields:
 struct{
   \ address to nfa of most recent word added to this wordlist
   pointer: wlist.word
   \ address to nfa of vocabulary name 
   pointer: wlist.nfa
   \ address to previous sibling wordlist
   pointer: wlist.sibling
   \ address to head of child wordlist
   pointer: wlist.child
 }struct: wlist.size

\ initialize wlist fields of definitions vocabulary
: wlist.init ( wlist -- wlist )
  x=          ( wlist X:wlist )
  \ wlist.word = 0
  y=0 @=y     ( wlist )
  \ parent wid child field is in current->child
  current y=  ( parentwlist )
  wlist.child +y ( parentwlist.child )
  d=          ( parentwlist.child parentwlist.child )
  y=@         ( parentwlist.child parentwlist.child Y:childLink )
  wlist.sibling +x ( parentwlist.child wlist.sibling )
  \ wlist.sibling = childLink
  @=y         ( parentwlist.child wlist.sibling )
  \ wlist.child = 0
  +dcell y=0
  @=y         ( parentwlist.child wlist.child )
  \ parentwlist.child = wlist
  d           ( parentwlist.child )
  @=x x       ( wlist )
;

\ make a wordlist record in data ram
\ and initialize the fields
: wlist.create ( -- wlist )
  \ get next available ram from here and use as wid
  here                  ( wlist )   
  \ allocate  ram for the wlist fields
  d= wlist.size allot d ( wlist )

  wlist.init            ( wlist )
;

\ duplicate current wordlist in vocabulary search list
\ normally used to add another vocabulary to search list
\ ie: MyWords also MyOtherWords
: also ( -- )
  context d=
  \ increment index
  contidx++ d
  context=  
; immediate

\ removes most recently added wordlist from vocabulary search list
: prev ( -- )
  \ get current index and decrement by 1
  contidx        ( idx ) 
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

: def ( -- )
    context
    ==0 ifnz current= then
; immediate

\ A defining word used in the form:
\     voc: cccc  
\ to create a vocabulary definition cccc. Subsequent use of cccc will
\ make it the CONTEXT vocabulary which is searched first by INTERPRET.
\ The sequence "cccc def" will also make cccc the CURRENT
\ vocabulary into which new definitions are placed.

\ By convention, vocabulary names are automaticaly declared IMMEDIATE.

: voc: ( -- ) ( C:cccc )
  create
  immediate
  \ allocate space in ram for head and tail of vocab word list
  wlist.create d= ( wlid wlid )
  d,              ( wlid ? )
  \ wlist.name = vocabulary.nfa  
  current @       ( wlid wid )
  y= d            ( wlid Y:voc.nfa )
  +dcell @=y      ( wlid.name )

  does>
    @ \ get header address
    \ make this vocabulary the active search context
    context=
;

\ Set context to Forth vocabulary
: Forth ( -- )
  context# @ context=
; immediate

\ setup forth name pointer in forth wlid name field
\ get forth nfa - its the most recent word created
current @ d= ( nfa nfa )
\ get the forth wid, initialize it and set name field
\ forthwlid.word is already initialized
context# @ +dcell ( nfa forthwid.name )
\ forthwlid.name = nfa
y=d @=y          ( forthwid.name )
\ forthwlid.link = 0
+dcell y=0 @=y   ( forthwid.link )
\ forthwlid.child = 0
+dcell y=0 @=y   ( )

\ print name field
: .nf ( nfa -- )
      $l y= $FF &y   ( addr cnt ) \ mask immediate bit
      type space     ( ? )
;
 
\ list words starting at a wid address
: lwords ( wid -- )
  d= 0 d=                  ( wid 0 0 )
  d1                       ( wid cnt wid )
  begin
    ==0
  whilenz                  ( wid cnt wid ) \ is nfa = counted string
    .nf                    ( wid cnt ? )
    d0 +1 d0=              ( wid' cnt+1 cnt+1 )
    d1 wid.lfa             ( wid cnt lfa )
    @ d1=                  ( wid' cnt addr )
  repeat 
  cr ." count: " d0 .
  d-2
;

\ List the names of the definitions in the context vocabulary.
\ Does not list other linked vocabularies.
\ Use words to see all words in the top context search.
: words ( -- )
    wlist ( wlist )
    @     ( nfa )
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
  contidx d=                 ( idx idx )
  begin
  \ iterate through vocab array and print out vocab names
    ==0
  whilenz
    context[]#               ( idx context' )
    \ get context wlist
    @                        ( idx wlist )
    \ if not zero then print vocab name 
    ==0
    ifnz
      \ next cell has name field address 
      +dcell @               ( idx nfa )
      .nf                    ( idx ? )
    else
      ." [] "
    then
    \ decrement index
    d0 1- d0=
  repeat
  d
  ." Forth Root" cr
  ." definitions: "
  current +dcell @ .nf cr
;

\ print child vocabularies
: .childvocs ( spaces wlist -- )
  begin
  \ while link is not zero
  ==0
  whilenz                ( spaces linkwlist )
    \ print indent
    d= d1 spaces ." |- " ( spaces linkwlist ? )
    \ get name from name field
    d0 +dcell d0= @      ( spaces linkwlist.name name )
    \ print name and line feed
    .nf cr               ( spaces link.name ? )
    \ increase spaces for indenting child vocabularies
    d1 +4 d=             ( spaces linkwlist.name spaces+4 spaces+4 )
    \ get link field
    d1 +dcell d1=        ( spaces linkwlist.sibling spaces+4 linkwlist.sibling )
    \ get child link and recurse: print child vocabularies
    +dcell @             ( spaces linkwlist.sibling spaces+4 childwlist )
    recurse              ( spaces linkwlist.sibling )
    \ get link for next sibling
    @
  repeat
  d-1 d
;

\ list context vocabulary and all child vocabularies
\ order is newest to oldest
: vocs ( -- )
  \ start spaces at 2
  d= 2           ( ? 2 )
  \ get top search vocabulary address
  \ it is the head of the vocabulary linked list
  d= wlist       ( ? 2 wlist )
  \ print context vocabulary
  d= +dcell      ( ? 2 wlist wlist.name )
  @ .nf cr d     ( ? 2 wlist )
  \ get child link of linked list
  y= 
  wlist.child +y ( ? 2 wlist.child )
  @              ( ? 2 childwlist )
  .childvocs cr  ( ? )
;
