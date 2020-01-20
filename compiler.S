@ compiler.S


@ ( -- addr )
@ system SMUDGE. Get program address of latest word currently being compiled.
Forthword_ SMUDGE, 0, "smudge"
  user_ COLON_SMUDGE
  mw_
  end_

@ ( addr -- )
@ system SMUDGE. Set program address of latest word being compiled.
Forthword_ SMUDGE_STR, 0, "smudge="
  y_w_
  user_ COLON_SMUDGE
  mw_y_
  end_

@ ( -- f-addr )
@ get address of the dictionary cell
Forthword_ DPSHARP, 0, "dp#"
  user_ ram_dp
  end_

@ ( -- f-addr )
@ address of the next free dictionary cell
Forthword_ DP, 0, "dp"
  user_ ram_dp
  mw_
  end_

@ ( offset -- )
@ add offset to 16 bit (dictionary pointer) DP
Forthword_ DPPLUS, 0, "dp+="
  y_w_
  user_ ram_dp
  x_mw_
  x_plus_y_
  mw_x_
  end_

@ ( -- f-addr )
@ get address of the code cell
Forthword_ CPSHARP, 0, "cp#"
  user_ ram_cp
  end_

@ ( -- f-addr )
@ address of the next free code cell
Forthword_ CP, 0, "cp"
  user_ ram_cp
  mw_
  end_

@ ( offset -- cp#)
@ add offset to (code pointer) CP
Forthword_ CPPLUS, 0, "cp+="
  y_w_
  user_ ram_cp
  x_mw_
  x_plus_y_
  mw_x_
  end_

@ is cp word aligned
@ ( -- flag )
@ flag is zero if cp word aligned 
Forthword_ CPWA, 0, "cpwa"
  @if cp is not word aligned then add nop,
  do_ CP
  movs r1, #3
  ands wreg, r1
  end_


@ ( -- )
@ tail call optimize: change last branch with link (bl) into a branch (b)
Forthword_ TAILOPT, 0, ";opt"
  @ optimize only if smudge is not zero
  do_ SMUDGE
  iszero_
  ifnz_ TAILOPT_OPT
  exit_

TAILOPT_OPT:
  @ don't optimize tail call, just compile a ret.
.if BUILD_LEVEL >= ASM_BASE
  do_ POPPC          @ ( poppc )
  end_do_ COMMA
.else
  end_
.endif

@ ( -- )
@ clear code cache to force reload when executed as instructions
Forthword_ CLRCACHE, 0, "clrcache"
  @ r1 = end address
  do_ CP
  mov r1, wreg
  @ r0 = start address: will be current last word defined
  do_ CURRENT
  mw_
  @ can't tail call optimize here since calling c code in arm not thumb
  do_ __clear_cache
  end_
    
@ ( -- )
@ update wid from smudge if valid
Forthword_ UWID, 0, "uwid"
  do_ SMUDGE           @ (xt)
  iszero_
  ifz_ UWID_end
    @ wid.word = smudge
    y_w_               @ ( xt ) Y:xt
    do_ CURRENT        @ ( current )
    mw_                @ ( wid )
    mw_y_              @ ( wid )
    do_ CLRCACHE
    @ set smudge to zero indicating no longer compiling a word
    zero_
    do_ SMUDGE_STR

UWID_end:
  end_


@ ( n -- )
@ store 16 bit value in WR into code section ram at (code pointer) CP
Forthword_ COMMA, 0, ","
  y_w_               @ ( n ) Y:n
  do_ CP             @ ( CP )
  hmw_y_             @ [CP]=n
  lit_ 2             @ ( 2 )
  end_do_ CPPLUS     @ CP+=2

@ ( n -- )
@ store 32 bit value in WR into code section ram at (code pointer) CP
Forthword_ DCOMMA, 0, "d,"
  y_w_               @ ( n ) Y:n
  do_ CP             @ ( CP )
  mw_y_              @ [CP]=n
  lit_ 4             @ ( 4 )
  end_do_ CPPLUS     @ CP+=4

@ ( n -- )
@ store 32 bit value in WR into dictionary section ram at (dictionary pointer) DP
@ automaticaly increment dp position by 4 bytes
Forthword_ DPSTORE, 0, "@dp="
  y_w_
  do_ DP
  mw_y_
  lit_ 4
  end_do_ DPPLUS

@ ( s-addr len len' d-addr -- d-addr+len)
@ copies a counted string with flags from s-addr to d-addr
Forthword_ COPYSTRING, 0, "copy$"
  r_b_               @ ( s-addr len len' d-addr ) (R: b )
  b_w_               @ ( s-addr len len' d-addr ) B:d-addr
  d0_                @ ( s-addr len len' len' )
  y_d1_              @ ( s-addr len len' len' ) Y:len
  hmb_w_             @ [d-addr]=len'
  x_d2_              @ ( s-addr len len' len' ) X:s-addr

COPYSTRING_LOOP:
  b_plus2_           @ ( s-addr len len' len' ) B:d-addr+2
  y_iszero_          @ len == 0 ?
  ifz_ COPYSTRING_DONE
  hmx_               @ ( s-addr len len' c2c1 )
  y_minus1_          @ ( s-addr len len' c2c1 ) Y:len-1
  @ program strings could be zero-padded at the last cell for 16bit alignment
  @ if count is even or > 1 then continue
  ifnz_ COPYSTRING_DO
    movs r1, #255
    @ count was at 1
    @ count in Y is now at zero so add 1 to prevent underflow
    @ so that loop can end properly
    y_plus1_         @ ( s-addr len len' c1 ) Y:len+1
    @ length of string is odd 
    @ only allow low byte of W
    ands wreg, r1    @ ( s-addr len len' c1 )

COPYSTRING_DO:
  hmb_w_             @ [d-addr]=c2c1
  x_plus2_           @ ( s-addr len len' c2c1 ) X:s-addr+2
  y_minus1_          @ ( s-addr len len' c2c1 ) Y:len-1 
  goto_ COPYSTRING_LOOP


COPYSTRING_DONE:
  b_                 @ ( s-addr len len' s-addr+len )
  d_m3_              @ ( s-addr+len )
  b_r_               @ ( s-addr+len ) B:b (R: )
  end_

@ ( addr len len' -- )
@ copies a counted string with flags to program ram
Forthword_ STRINGPROGSTORE, 0, "@cp=s"
  d_w_
  do_ CP
  do_ COPYSTRING
  y_w_
  do_ CPSHARP
  mw_y_
  end_

@ ( addr len len' -- )
@ copies a counted string with flags to dictionary ram
Forthword_ STRINGDICTSTORE, 0, "@dp=s"
  d_w_
  do_ DP
  do_ COPYSTRING
  y_w_
  do_ DPSHARP
  mw_y_
  end_

@ ( source destination term -- count )
@ copy half words from source to destination until match is made
@ term is the 16 bit value that terminates copy operation
@ source is the start address of the source in ram
@ destination is the start address of where memory is copied to
@ the copy/search goes up in ram address space
@ count is the number of bytes copied
Forthword_ COPY_HWORD_UNTIL, 0, "copy.hword.until"
  @ fetch from ram and check if equal to match byte
  r_a_               @ ( source destination term ) (R: A )
  x_w_               @ ( source destination term ) X: term
  b_d0_              @ ( source destination match ) B: destination
  y_d1_              @ ( source destination match ) Y: source

  @ begin
CBU_BEGIN:
  hmy_               @ ( source destination val16 )
  y_plus2_           @ ( source destination val16 ) Y:Y+2
  cmp wreg, xreg    
  @ until
  ifz_ CBU_DONE
  hmb_w_             @ ( source destination val16 ) [B]:val16
  b_plus2_           @ ( source destination val16 ) B:B+2
  goto_ CBU_BEGIN

CBU_DONE:
  y_d0_              @ ( source destination byte ) Y: destination
  d_m2_              @ ( byte )
  b_                 @ ( destination+count )
  w_minus_y_         @ ( count )
  a_r_               @ ( count ) (R: ) A:A
  end_


@ ( start -- )
@ copy code to current code entry
Forthword_ INLINE, 0, "inline"
  @ find the bx lr instruction, want count to bx lr
  @ count will be number of half words to inline
  d_w_                     @ ( start start )
  do_ CP                   @ ( start CP )
  d_w_                     @ ( start CP CP )
  lit_ 0x4770              @ ( start CP 0x4770 )
  do_ COPY_HWORD_UNTIL     @ ( count )
  end_do_ CPPLUS
