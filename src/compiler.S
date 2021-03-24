@ compiler.S


@ ( -- xt )
@ get new word. Get program address of latest word currently being compiled.
Forthword_ NWORD, 0, "nword"
  user_ NEW_WORD
  mw_
  end_

@ ( xt -- )
@ set new word. Set nword to program code address of latest word being compiled.
Forthword_ NWORD_STR, 0, "nword="
  y_w_
  user_ NEW_WORD
  mw_y_
  end_

@ ( -- f-addr )
@ set dictionary pointer address
Forthword_ DP_STR, 0, "dp="
  y_w_
  user_ ram_dp
  mw_y_
  end_

@ ( -- f-addr )
@ address of the next free dictionary cell
Forthword_ DP, 0, "dp"
  user_ ram_dp
  mw_
  end_

@ ( offset -- )
@ add offset to (dictionary pointer) DP
Forthword_ DPPLUS, 0, "dp+="
  y_w_
  user_ ram_dp
  x_mw_
  x_add_y_
  mw_x_
  end_

@ ( -- f-addr )
@ address of the next free code cell
Forthword_ CP, 0, "cp"
  user_ ram_cp
  mw_
  end_

@ ( -- f-addr )
@ set code pointer address
Forthword_ CP_STR, 0, "cp="
  y_w_
  user_ ram_cp
  mw_y_
  end_

@ ( offset -- cp#)
@ increment CP by one instruction length
Forthword_ CP_PLUS_PLUS, 0, "cp++"
  user_ ram_cp
  x_mw_
  x_add_2_
  mw_x_
  end_

@ ( offset -- cp#)
@ add offset to (code pointer) CP
Forthword_ CPPLUS, 0, "cp+="
  y_w_
  user_ ram_cp
  x_mw_
  x_add_y_
  mw_x_
  end_

@ is cp word aligned
@ ( -- flag )
@ flag is zero if cp word aligned 
Forthword_ CPWA, 0, "cpwa"
  @if cp is not word aligned then add nop,
  do_ CP
  movs tmp1, #3
  ands wreg, tmp1
  end_


@ ( -- )
@ tail call optimize: change last branch with link (bl) into a branch (b)
Forthword_ TAILOPT, 0, ";opt"
  @ optimize only if nword is not zero
  do_ NWORD
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
  x_w_
  @ r0 = start address: will be current last word defined
  do_ CURRENT_ADDR
  mw_
  @ can't tail call optimize here since calling c code in arm not thumb
  do_ __clear_cache
  end_
    
@ ( -- )
@ update wlid from nword if valid
Forthword_ UWID, 0, "uwid"
  do_ NWORD            @ (xt)
  iszero_
  ifz_ UWID_end
    @ wlid.word = nword
    y_w_               @ ( xt ) Y:xt
    do_ CURRENT_ADDR   @ ( current )
    mw_                @ ( wlid )
    mw_y_              @ ( wid )
    do_ CLRCACHE
    @ set nword to zero indicating no longer compiling a word
    zero_
    do_ NWORD_STR

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
  b_add_2_           @ ( s-addr len len' len' ) B:d-addr+2
  y_iszero_          @ len == 0 ?
  ifz_ COPYSTRING_DONE
  hmx_               @ ( s-addr len len' c2c1 )
  y_sub_1_           @ ( s-addr len len' c2c1 ) Y:len-1
  @ program strings could be zero-padded at the last cell for 16bit alignment
  @ if count is even or > 1 then continue
  ifnz_ COPYSTRING_DO
    movs tmp1, #255
    @ count was at 1
    @ count in Y is now at zero so add 1 to prevent underflow
    @ so that loop can end properly
    y_add_1_        @ ( s-addr len len' c1 ) Y:len+1
    @ length of string is odd 
    @ only allow low byte of W
    ands wreg, tmp1    @ ( s-addr len len' c1 )

COPYSTRING_DO:
  hmb_w_             @ [d-addr]=c2c1
  x_add_2_           @ ( s-addr len len' c2c1 ) X:s-addr+2
  y_sub_1_           @ ( s-addr len len' c2c1 ) Y:len-1 
  goto_ COPYSTRING_LOOP


COPYSTRING_DONE:
  b_                 @ ( s-addr len len' s-addr+len )
  d_sub_3_           @ ( s-addr+len )
  b_r_               @ ( s-addr+len ) B:b (R: )
  end_

@ ( addr len len' -- )
@ copies a counted string with flags to program ram
Forthword_ STRINGPROGSTORE, 0, "@cp=s"
  d_w_
  do_ CP
  do_ COPYSTRING
  end_do_ CP_STR

@ ( addr len len' -- )
@ copies a counted string with flags to dictionary ram
Forthword_ STRINGDICTSTORE, 0, "@dp=s"
  d_w_
  do_ DP
  do_ COPYSTRING
  end_do_ DP_STR
  

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
  y_add_2_           @ ( source destination val16 ) Y:Y+2
  cmp wreg, xreg    
  @ until
  ifz_ CBU_DONE
  hmb_w_             @ ( source destination val16 ) [B]:val16
  b_add_2_           @ ( source destination val16 ) B:B+2
  goto_ CBU_BEGIN

CBU_DONE:
  y_d0_              @ ( source destination byte ) Y: destination
  d_sub_2_           @ ( byte )
  b_                 @ ( destination+count )
  sub_y_             @ ( count )
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
