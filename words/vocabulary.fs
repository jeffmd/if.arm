\ vocabulary.fs - words for managing the words

\ get context array address using context index
: context# ( -- addr )
  context dup 2- c@ 4* +
;

\ get a wordlist id from context array
: context@ ( -- wid )
  context# @
;

\ save wordlist id in context array at context index
: context! ( wid -- )
  context# !
;


: wordlist ( -- wid )
  here dup 0! \ get head address in ram and set to zero
  8 allot \ allocate  2 words in ram
;

: also ( -- )
  context@
  \ increment index
  context 2- 1+h!
  context!
  
; immediate


: previous ( -- )
  \ get current index and decrement by 1
  context 2- dup h@ 1- dup
  \ index must be >= 1
  0> if
       0 context! swap h!
     else
       2drop
     then
; immediate

\ Used in the form:
\ cccc DEFINITIONS
\ Set the CURRENT vocabulary to the CONTEXT vocabulary. In the
\ example, executing vocabulary name cccc made it the CONTEXT
\ vocabulary and executing DEFINITIONS made both specify vocabulary
\ cccc.

: definitions
    context@
    current !
; immediate

\ A defining word used in the form:
\     vocabulary cccc  
\ to create a vocabulary definition cccc. Subsequent use of cccc will
\ make it the CONTEXT vocabulary which is searched first by INTERPRET.
\ The sequence "cccc DEFINITIONS" will also make cccc the CURRENT
\ vocabulary into which new definitions are placed.

\ By convention, vocabulary names are automaticaly declared IMMEDIATE.

: vocabulary ( -- ) ( C:cccc )
  create
  [compile] immediate
  \ allocate space in ram for head and tail of vocab word list
  wordlist dup ,,
  \ get nfa and store in second field of wordlist record in eeprom
  cur@ @ swap 4+ !
  does>
   @ \ get eeprom header address
   context!
;

\ Set context to Forth vocabulary
: Forth ( -- )
  context @ context!
; immediate

\ setup forth name pointer in forth wid name field
\ get forth nfa - its the most recent word created
cur@ @
\ get the forth wid and adjust to name field 
context @ 4+
\ write forth nfa to name field
! 

\ print name field
: ?nf ( nfa -- )
      $l $FF and             ( cnt addr addr n ) \ mask immediate bit
      type space             ( cnt addr )
;
 
\ list words starting at a name field address
: lwords ( nfa -- )
    0 swap
    begin
      ?dup                   ( cnt addr addr )
    while                    ( cnt addr ) \ is nfa = counted string
      dup                    ( cnt addr addr )
      ?nf                    ( cnt addr )
      nfa>lfa                ( cnt lfa )
      @                      ( cnt addr )
      swap                   ( addr cnt )
      1+                     ( addr cnt+1 )
      swap                   ( cnt+1 addr )
    repeat 

    cr .
;

\ List the names of the definitions in the context vocabulary.
\ Does not list other linked vocabularies.
\ Use words to see all words in the top context search.
: words ( -- )
    context@
    ?if else drop context @ then
    @                       ( 0 addr )
    lwords
;

\ list the root words
: rwords ( -- )
  [ find WIPE lit ]
  lwords
;

\ list active vocabularies
: vocabs ( -- )
  \ get context index and use as counter
  context 2- h@
  begin
  \ iterate through vocab array and print out vocab names
  ?while
    dup 4* context +
    \ get context wid
    @
    \ if not zero then print vocab name 
    ?dup if
      \ next cell in eeprom has name field address 
      4+ @
      ?nf
    then
    \ decrement index
    1-
  repeat
  drop
  ." Forth Root"
;
