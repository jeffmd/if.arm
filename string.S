@ string.S - string words

@ ( addr -- addr+2 n )
@ get string address and length information out of a counted string
Forthword_ STRINGLEN, 0, "$l"
    push_
    twoplus_
    swap_
    hfetch_
    bx lr

@ ( addr1 u1 n -- addr2 u2 )
@ adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n
Forthword_ SLASHSTRING, 0, "/$"
    push {lr}
    over_         @ ( -- addr1 u1 n u1 )
    bl MIN        @ ( -- addr1 u1 n|u1 )
    bl ROT        @ ( -- u1 n addr1 )
    over_         @ ( -- u1 n addr1 n )
    plus_         @ ( -- u1 n addr2 )
    bl RROT       @ ( -- addr2 u1 n )
    minus_        @ ( -- addr2 u2)
    pop {pc}

@ ( -- addr len )
@ runtime portion of sliteral
@ string literal is located starting at return cell
@ return cell is string length
@ string then occupies the following cells: c2c1 c4c3 ...
Forthword_ DOSLIT, 0, "(slit)"
  @ get return address to get string length, calculate string address start,
  @ and calculate return address
  push_
  mov wreg, lr    @ ( raddr )  (R: raddr -- )
  push_           @ ( raddr raddr )
  @ get the string length
  oneminus_      @ account for odd address number because using thumb instructions
  hfetch_        @ ( raddr slength )
  over_          @ ( raddr slength raddr )
  @ calculate string address
  oneplus_       @ ( raddr slength straddr )
  @ calculate the number of words to skip over for return address
  bl FLIP        @ ( straddr slength raddr )
  over_          @ ( straddr slength raddr slength)
  bl HALIGN      @ ( straddr slength raddr k )
  plus_          @ ( straddr slength raddr+k )
  @ also skip string length
  twoplus_       @ ( straddr slength raddr+k+2 )
  mov lr, wreg
  pop_
  bx lr

