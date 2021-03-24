@ string.S - string words

@ ( addr -- addr+2 n )
@ get string address and length information out of a counted string
Forthword_ STRINGLEN, 0, "$l"
  x_w_        @ ( addr ) X: addr
  add_2_      @ ( addr+2 )
  d_w_        @ ( addr+2 addr+2 )
  hmx_        @ ( addr+2 len )
  end_

@ ( addr1 u1 n -- addr2 u2 )
@ adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n
Forthword_ SLASHSTRING, 0, "/$"
  d_w_          @ ( addr1 u1 n n )
  d1_           @ ( addr1 u1 n u1 )
  do_ MIN       @ ( addr1 u1 n|u1 )
  y_w_          @ ( addr1 u1 n ) Y: n
  d1_           @ ( addr1 u1 addr1 )
  add_y_        @ ( addr1 u1 addr2 )
  d1_w_         @ ( addr2 u1 addr2 )
  d_            @ ( addr2 u1 )
  sub_y_        @ ( addr2 u2 )
  end_

@ ( -- addr len )
@ runtime portion of sliteral
@ string literal is located starting at return cell
@ return cell is string length
@ string then occupies the following cells: c2c1 c4c3 ...
Forthword_ DOSLIT, 0, "(slit)"
  @ get return address to get string length, calculate string address start,
  @ and calculate return address
  push_lr_
  y_r0_          @ ( Y:raddr )  (R: raddr -- )
  @ get the string length
  y_sub_1_       @ account for odd address number because using thumb instructions
  hmy_           @ ( slength Y:raddr )
  @ calculate string address
  y_add_2_       @ ( slength Y:straddr )
  @ calculate the number of words to skip over for return address
  d_y_           @ ( straddr slength )
  d_w_           @ ( straddr slength slength)
  bl HALIGN      @ ( straddr slength k )
  y_add_         @ ( straddr slength k Y:raddr+k )
  d_             @ ( straddr slength )
  y_add_1_       @ make sure return address is odd
  r0_y_          @ ( straddr slength ) (R: straddr+k )
  end_
