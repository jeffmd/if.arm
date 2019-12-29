\ compiler.fs 

\ force compile any word including immediate words
: [compile]
  'f xt,
; :ic


\ read the following cell from the executing word and compile it
\ into the current code position.
: (word:,)  ( -- )
    r0+      ( raddr ) ( R: raddr+1 )
    1-       \ account for thumb address
    @        ( nfa )
    nfa>xtf  ( xt xtflags )
    xt,
;

\ compile a word into pending new word
: word:, ( C: x "<spaces>name" -- )
  ['f] (word:,) xt,
  find d,
; :ic


( -- ) ( C: "<spaces>name" -- )
\ Dictionary
\ create a dictionary header that will push the address of the
\ data field of name.
\ is used in conjunction with does>
: create
    rword
    pushlr,
    \ leave address after call on tos
    word:, popret
;


\ copy the first character of the next word onto the stack
: char  ( "<spaces>name" -- c )
    pname
    pop
    c@
;

( -- c ) ( C: "<space>name" -- )
\ skip leading space delimites, place the first character
\ of the next word in working register
: [char]
    char
    w:,
; immediate

( -- )
\ replace the instruction written by CREATE to call
\ the code that follows does>
\ does not return to caller
\ this is the runtime portion of does>
: (does>)
    \ change call at XT to code after (does>)
    \ code at XT is 'bl POPRET'
    \ want to change POPRET address to return address
    rpop                      ( retaddr )
    \ remove thumb flag - will be using for memory access
    1- push                   ( retaddr-1 retaddr-1 )
    \ get address of bl POPRET
    \ get current word and then get its XT being compiled
    cur@ @                    ( retaddr nfa )
    nfa>xtf                   ( retaddr xt flags )
    \ temp save cp on return stack
    cp rpush                  ( retaddr xt flags ) ( R: cp )
    \  skip over push {lr}    
    d0 icell+                 ( retaddr xt xt+2 )
    \ set cp to xt+2
    cp= pop icell+            ( retaddr xt+2 )
    \ modify the bl
    \ calc displacement
    reldst                    ( dst )
    \ compile a bl instruction
    do,                       ( ? )
    \ restore cp
    rpop cp=                  ( ? ) ( R: )
;

( -- )
\ Compiler
\ organize the XT replacement to call other colon code
\ used in conjunction with create
\ ie: : name create .... does> .... ;
: does>
    \ compile pop return to tos which is used as 'THIS' pointer
    word:, (does>)
    word:, lr
    word:, 1-
; :ic

( -- xt )
\ Compiler
\ create an unnamed entry in the dictionary
: :noname
    cp ]
;

( -- start )
\ Compiler
\ place marker. Places current code position for forward
\ jump resolve on stack and advances CP
: markf
    cp push        ( start start )
    4 cp+=         ( start ? ) \ advance DP to allow branch/jmp
;

( start ? -- )
\ Compiler
\ resolve jump forward
: rjmpf
    ?dsp             ( start ? ) \ check stack integrety
    cp               ( start dest )
    gotos            ( ? )
;

( -- dest )
\ Compiler
\ place marker for destination of backward branch
: markb
    cp push          ( dest )
;

( dest -- )
\ Compiler
\ resolve jump backwards
: rjmpb
    ?dsp            \ make sure there is something on the stack
    \ compile a rjmp at current CP that jumps back to mark
    cp              \ ( dest start )
    y=d0
    d0=
    y               \ ( start dest )
    gotos           \ ( ? )
    4 cp+=          \ advance CP
;

( f -- ) ( C: -- orig )
\ Compiler
\ start conditional branch
\ part of: ifz...[else]...then
: ifz
   ifz,
   markf
; :ic

( f -- ) ( C: -- orig )
\ Compiler
\ start conditional branch
\ part of: ifnz...[else]...then
: ifnz
   ifnz,
   markf
; :ic


( C: orig1 -- orig2 )
\ Compiler
\ resolve the forward reference and place
\ a new unresolved forward reference
\ part of: if...else...then
: else
    markf         \ mark forward rjmp at end of true code
    d1 y=d0
    d0= d1=y      \ swap new mark with previouse mark
    rjmpf         \ rjmp from previous mark to false code starting here
; :ic

( -- ) ( C: orig -- )
\ Compiler
\ finish if
\ part of: if...[else]...then
: then
    rjmpf
; :ic


( -- ) ( C: -- dest )
\ Compiler
\ put the destination address for the backward branch:
\ part of: begin...while...repeat, begin...until, begin...again
: begin
    markb
; :ic


( -- ) ( C: dest -- )
\ Compiler
\ compile a jump back to dest
\ part of: begin...again
: again
    rjmpb
; :ic

( f -- ) ( C: dest -- orig dest )
\ Compiler
\ at runtime skip until repeat if non-true
\ part of: begin...whilez...repeat
: whilez
    [compile] ifz
    d1 y=d0
    d0= d1=y     \ swap new mark with previouse mark
; :ic

( f -- ) ( C: dest -- orig dest )
\ Compiler
\ at runtime skip until repeat if non-true
\ part of: begin...whilenz...repeat
: whilenz
    [compile] ifnz
    d1 y=d0
    d0= d1=y     \ swap new mark with previouse mark
; :ic

( --  ) ( C: orig dest -- )
\ Compiler
\ continue execution at dest, resolve orig
\ part of: begin...while...repeat
: repeat
  [compile] again
  rjmpf
; :ic


( f -- ) ( C: dest -- )
\ Compiler
\ finish begin with conditional branch,
\ leaves the loop if true flag at runtime
\ part of: begin...untilz
: untilz
    ifz,
    rjmpb
; :ic

( f -- ) ( C: dest -- )
\ Compiler
\ finish begin with conditional branch,
\ leaves the loop if true flag at runtime
\ part of: begin...untilnz
: untilnz
    ifnz,
    rjmpb
; :ic

( -- )
\ Compiler
\ perform a recursive call to the word currently being defined
\ compile the XT of the word currently
\ being defined into the dictionary
: recurse
  smudge nfa>xtf xt,  
; :ic

\ allocate or release n bytes of memory in RAM
: allot ( n -- )
    y= here y+= here# @=y
;

( x -- ) ( C: x "<spaces>name" -- )
\ create a constant in the dictionary
: con
    push rword
    pop
    w:,
    bxlr,
    clrcache
;


\ create a dictionary entry for a variable and allocate 1 cell RAM
: var ( cchar -- )
    here con
    dcell allot
;

( cchar -- )
\ Compiler
\ create a dictionary entry for a character variable
\ and allocate 1 byte RAM
: cvar
    here con
    1 allot
;


\ compiles a string from RAM to program RAM
: s, ( addr len -- )
    push @cp=s
;

( C: addr len -- )
\ String
\ compiles a string to program RAM
: slit
    push word:, (slit) pop     ( addr n)
    s,
; immediate


( -- addr len) ( C: <cchar> -- )
\ Compiler
\ compiles a string to ram,
\ at runtime leaves ( -- ram-addr count) on stack
: s"
    [char] " parse        ( addr n)
    push state ==0 pop
    ifnz  \ skip if not in compile mode
      [compile] slit
    then
; immediate

( -- ) ( C: "ccc<quote>" -- )
\ Compiler
\ print string if in interpreter mode
\ if comping then compiles string into
\ dictionary to be printed at runtime
: ."
     [compile] s"             \ "
     push state ==0 pop
     ifnz
       word:, type
     else
       type
     then
; immediate
