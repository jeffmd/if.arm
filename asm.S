@ asm.S - words that generate inline assembly ie arm thumb instructions

@ ( -- lr )
@ move link register onto top of data stack
Forthword_ LR_G, INLINE_OPT, "lr"
  mov wreg, lr
  end_

@ ( Rd val8 -- )
@ subtract imediate 8 bit value from reg
Forthword_ MOVI_C, 0, "movs#,"
  push_
  lit_ 0x0
  end_do_ MCASI_C

@ ( Rd val8 -- )
@ subtract imediate 8 bit value from reg
Forthword_ CMPI_C, 0, "cmp#,"
  push_
  lit_ 0x1
  end_do_ MCASI_C

@ ( Rd val8 -- )
@ add imediate 8 bit value to reg
@ reg is 0 -7 corresponding to r0 - r7
Forthword_ ADDI_C, 0, "adds#,"
  lit_ 0x2
  end_do_ MCASI_C

@ ( Rd val8 -- )
@ subtract imediate 8 bit value from reg
Forthword_ SUBI_C, 0, "subs#,"
  push_
  lit_ 0x3
  end_next_

@ ( Rd val8 Op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |       Op     |  Rd  |     val8      |
@ move, cmp, add, sub operations with immediate
MCASI_C:    
  @ flip Rd and val8 around
  to_r_
  swap_
  r_from_
  movs r1, #4
  orrs wreg, r1
  end_do_ OPRDVAL_C

@ ( Rd Rs -- )
@ Rd = Rd and Rs
@ and Rd with Rs and place result in Rd
Forthword_ ANDS_C, 0, "ands,"
  dolit8_ 0x0
  b.n ALU_C

@ ( Rd Rs -- )
@ Rd = Rd eor Rs
@ exclusive or Rd with Rs and place result in Rd
Forthword_ EORS_C, 0, "eors,"
    dolit8_ 0x1
    b.n ALU_C
    
@ ( Rd Rs -- )
@ Rd = Rd << Rs
@ logical shift left Rd by Rs bits and place result in Rd
Forthword_ LSLS_C, 0, "lsls,"
    dolit8_ 0x2
    b.n ALU_C
    
@ ( Rd Rs -- )
@ Rd = Rd >> Rs
@ logical shift right Rd by Rs bits and place result in Rd
Forthword_ LSRS_C, 0, "lsrs,"
    dolit8_ 0x3
    b.n ALU_C

@ ( Rd Rs -- )
@ Rd = Rd ASR Rs
@ arithmetic shift right Rd by Rs and place result in Rd
Forthword_ ASRS_C, 0, "asrs,"
    dolit8_ 0x4
    b.n ALU_C

@ ( Rd Rs -- )
@ Rd = Rd + Rs + C-bit
@ add Rd with Rs + carry bit and place result in Rd
Forthword_ ADCS_C, 0, "adcs,"
    dolit8_ 0x5
    b.n ALU_C

@ ( Rd Rs -- )
@ Rd = Rd - Rs - NOT C-bit
@ subtract Rs from Rd using carry bit and place result in Rd
Forthword_ SBCS_C, 0, "sbcs,"
  lit_ 0x6
  end_do_ ALU_C

@ ( Rd Rs -- )
@ Rd : Rd ROR Rs
@ rotate Rd to the right using Rs and place result in Rd
Forthword_ RORS_C, 0, "rors,"
  lit_ 0x7
  end_do_ ALU_C

@ ( Rd Rs -- )
@ condition codes = Rd AND Rs
@ test Rd with Rs and set condition codes
Forthword_ TST_C, 0, "tst,"
  lit_ 0x8
  end_do_ ALU_C

@ ( Rd Rs -- )
@ subtract Rs from 0 and place result in Rd
Forthword_ RSBS_C, 0, "rsbs,"
  lit_ 0x9
  end_next_

@ ( Rd Rs Op -- )
@ instruction bit pattern
@ 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@  0  1  0  0  0  0|   op  |  Rs |  Rd |
@ ALU operations: and, eor, lsl, lsr, asr, adc, sbc, ror, tst, rsbs
ALU_C:
  movs r1, #64
  lsls r1, #2
  orrs wreg, r1
  end_do_ OPRSRD_C
    
@ ( Rd Rs -- )
@ condition codes = Rd - Rs
@ compare Rd with Rs and set condition codes
Forthword_ CMP_C, 0, "cmp,"
  lit_ 0xA
  end_do_ ALU_C

@ ( Rd Rs -- )
@ condition codes = Rd + Rs
@ test Rd + Rs and set condition codes
Forthword_ CMN_C, 0, "cmn,"
  lit_ 0xB
  end_do_ ALU_C

@ ( Rd Rs -- )
@ Rd = Rd OR Rs
@ or Rd with Rs and put result in Rd
Forthword_ ORRS_C, 0, "orrs,"
  lit_ 0xC
  end_do_ ALU_C

@ ( Rd Rs -- )
@ Rd = Rd * Rs
@ multiply Rd with Rs and put result in Rd
Forthword_ MULS_C, 0, "muls,"
  lit_ 0xD
  end_do_ ALU_C

@ ( Rd Rs -- )
@ Rd = Rd and not Rs
@ bit clear Rd using not Rs and put result in Rd
Forthword_ BICS_C, 0, "bics,"
  lit_ 0xE
  end_do_ ALU_C

@ ( Rd Rs -- )
@ Rd = not Rs
@ not Rs and put result in Rd
Forthword_ MVNS_C, 0, "mvns,"
  lit_ 0xF
  end_do_ ALU_C

@ ( Rd Rs val5 -- )
@ Rd = Rs << val5
@ logical shift left Rs by immediate val5 bits and put result in Rd
Forthword_ LSLI_C, 0, "lsls#,"
  lit_ 0x0
  end_do_ OPVALRSRD_C

@ ( Rd Rs val5 -- )
@ Rd = Rs >> val5
@ logical shift right Rs by immediate val5 bits and put result in Rd
Forthword_ LSRI_C, 0, "lsrs#,"
  lit_ 0x1
  end_do_ OPVALRSRD_C

@ ( Rd Rs val5 -- )
@ Rd = Rs >> val5
@ arithmetic shift right Rs by immediate val5 bits and put result in Rd
Forthword_ ASRI_C, 0, "asrs#,"
  lit_ 0x2
  end_do_ OPVALRSRD_C

@ ( Rd Rs val5 op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |      op      |   val5   |  Rs |  Rd |
@ compile arm thumb assembler instruction    
Forthword_ OPVALRSRD_C, 0, "opvalrsrd,"
  popy_              @ ( Rd Rs op ) Y:val5
  movs r1, #31
  ands yreg, r1      @ ( Rd Rs op ) Y:val5&31
  lsls wreg, #5      @ ( Rd Rs op:00000 )
  w_or_y_            @ ( Rd Rs op|val5&31 )
  end_do_ OPRSRD_C

@ ( Rd Rs val3 op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |        op         | val3|  Rs |  Rd |
@ compile arm thumb assembler instruction  
Forthword_ OPVRRSRD_C, 0, "opvrrsrd,"
  popy_            @ ( Rd Rs op ) Y:val3
  movs r1, #7
  ands yreg, r1    @ ( Rd Rs op ) Y:val3&7
  lsls wreg, #3    @ ( Rd Rs op:000 )
  w_or_y_          @ ( Rd Rs op:val3&7 )
  end_do_ OPRSRD_C

@ ( Rd Rs op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |            op           |  Rs |  Rd |
@ compile arm thumb assembler instruction   
Forthword_ OPRSRD_C, 0, "oprsrd,"
  @ shift left Op 6 bits
  lsls wreg, #6
  @ mask Rs with 7
  popy_
  movs r1, #0x7
  ands yreg, r1
  lsls yreg, #3
  w_or_y_
  popx_
  movs r1, #0x7
  ands xreg, r1
  w_or_x_
  end_do_ COMMA

@ ( val8 Rd op -- )
@ instruction bit pattern
@  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
@ |       op     |  Rd  |  8 bit val    |
@ compile arm thumb assembler instruction    
Forthword_ OPRDVAL_C, 0, "oprdval,"
  lsls wreg, #3
  @ mask Rd with 7
  popy_
  movs r1, #0x7
  ands yreg, r1
  w_or_y_
  @ mask val with 255
  popx_
  movs r1, #0xFF
  ands xreg, r1
  lsls wreg, #8
  w_or_x_
  b COMMA
    
