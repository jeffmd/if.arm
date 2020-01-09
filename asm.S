@ asm.S - words that generate inline assembly ie arm thumb instructions

@ ( Rd Rs op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |            op           |  Rs |  Rd |
@ build arm thumb assembler instruction   
Forthword_ OPRSRD, 0, "_oprsrd"
  @ shift left Op 6 bits
  lsls wreg, #6    @ ( Rd Rs op000000 )
  @ mask Rs with 7
  y_d_             @ ( Rd op000000 Y:Rs )
  movs r1, #0x7
  ands yreg, r1    @ ( Rd op000000 Y:00000xxx )
  lsls yreg, #3    @ ( Rd op000000 Y:00xxx000 )
  w_or_y_          @ ( Rd opxxx000 ) 
  x_d_             @ ( opxxx000 X:Rd )
  movs r1, #0x7
  ands xreg, r1    @ ( opxxx000 X:00000xxx )
  w_or_x_          @ ( opRsRd ) 
  end_

@ ( Rd Rs val5 op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |      op      |   val5   |  Rs |  Rd |
@ buil arm thumb assembler instruction    
Forthword_ OPV5RSRD, 0, "_opv5rsrd"
  y_d_               @ ( Rd Rs op ) Y:val5
  movs r1, #31
  ands yreg, r1      @ ( Rd Rs op ) Y:val5&31
  lsls wreg, #5      @ ( Rd Rs op:00000 )
  w_or_y_            @ ( Rd Rs op|val5&31 )
  end_do_ OPRSRD

@ ( Rd Rs val3 op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |        op         | val3|  Rs |  Rd |
@ build arm thumb assembler instruction  
Forthword_ OPVRRSRD, 0, "_opvrrsrd"
  y_d_             @ ( Rd Rs op ) Y:val3
  movs r1, #7
  ands yreg, r1    @ ( Rd Rs op ) Y:val3&7
  lsls wreg, #3    @ ( Rd Rs op:000 )
  w_or_y_          @ ( Rd Rs op:val3&7 )
  end_do_ OPRSRD

@ ( Rd Rs Op -- )
@ instruction bit pattern
@ 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@  0  1  0  0  0  0|   op  |  Rs |  Rd |
@ ALU operations: and, eor, lsl, lsr, asr, adc, sbc, ror, tst, rsbs
Forthword_ ALUOP, 0, "_aluop"
  movs r1, #64
  lsls r1, #2
  orrs wreg, r1
  end_do_ OPRSRD

@ ( Rd Rs Op -- )
@ instruction bit pattern
@ 15 14 13 12 11 10 9 8  7  6 5 4 3 2 1 0
@  0  1  0  0  0  1|op |h1|h2|Rs/Hs|Rd/Hd|
@ operations: add, cmp, mov, bx
Forthword_ OPHIRSRD, 0, "_ophirsrd"
  movs r1, #68
  orrs wreg, r1
  lsls wreg, #2
  y_d0_
  x_d1_
  movs r1, #7
  cmp yreg, r1
  ble OPHIRSRD_CHECK_RS
    @ set h1 bit field
    adds wreg, #2
    subs yreg, #8
    d0_y_

OPHIRSRD_CHECK_RS:
  cmp xreg, r1
  ble OPHIRSRD_END
    adds wreg, #1
    subs xreg, #8
    d1_x_

OPHIRSRD_END:
  end_do_ OPRSRD
    
@ ( Rd val8 op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |       op     |  Rd  |  8 bit val    |
@ build arm thumb assembler instruction    
Forthword_ OPRDV8, 0, "_oprdv8"
  lsls wreg, #3         @ ( val8 Rd op000 )
  @ mask val with 255
  x_d_                  @ ( Rd opxxx X:val8 )
  movs r1, #0xFF
  ands xreg, r1         @ ( Rd opxxx X:bxxxxxxxx )
  @ mask Rd with 7
  y_d_                  @ ( op Y:Rd )
  movs r1, #0x7
  ands yreg, r1         @ ( op Y:b00000xxx )
  w_or_y_               @ ( opRd )
  lsls wreg, #8         @ ( opRd00000000 )
  w_or_x_               @ ( opRdval )
  end_
