\ arm thumb assembler instructions

rword _w inlined
  ] 0 [
  _bxlr ,

rword _t1 inlined
  ] 1 [
  _bxlr ,

rword _x inlined
  ] 2 [
  _bxlr ,

rword _y inlined
  ] 3 [
  _bxlr ,

rword _sysvar inlined
  ] 4 [
  _bxlr ,

rword _a inlined
  ] 5 [
  _bxlr ,

rword _b inlined
  ] 6 [
  _bxlr ,

rword _dsp inlined
  ] 7 [
  _bxlr ,

rword _rsp inlined
  ] 13 [
  _bxlr ,

rword __lr inlined
  ] 14 [
  _bxlr ,

rword _pc inlined
  ] 15 [
  _bxlr ,

rword _d0 inlined
  ] 0 [
  _bxlr ,

rword _d1 inlined
  ] 1 [
  _bxlr ,

rword _d2 inlined
  ] 2 [
  _bxlr ,

rword _r0 inlined
  ] 0 [
  _bxlr ,

rword _r1 inlined
  ] 1 [
  _bxlr ,

rword _r2 inlined
  ] 2 [
  _bxlr ,

\ move immediate into register
( Rd val8 -- )
: _movsi
  d= 4 _oprdv8
;

\ compare immediate with register
( Rd val8 -- )
: _cmpsi
  d= 5 _oprdv8
;

\ add immediate to register
( Rd val8 -- )
: _addsi
  d= 6 _oprdv8
;

\ subtract immediate from register
( Rd val8 -- )
: _subsi
  d= 7 _oprdv8
;

\ and source Rs with destination Rd
\ Rd = Rd and Rs
( Rd Rs -- )
: _ands
  d= 0 _aluop
;

\ exclusive or source Rs with destination Rd
\ Rd = Rd eor Rs
( Rd Rs -- )
: _eors
  d= 1 _aluop
;

\ logical shift left Rd by Rs bits and place result in Rd
\ Rd = Rd << Rs
( Rd Rs -- )
: _lsls
  d= 2 _aluop
;

\ logical shift right Rd by Rs bits and place result in Rd
\ Rd = Rd >> Rs
( Rd Rs -- )
: _lsrs
  d= 3 _aluop
;

\ arithmetic shift right Rd by Rs and place result in Rd
\ Rd = Rd asr Rs
( Rd Rs -- )
: _asrs
  d= 4 _aluop
;

\ add Rd with Rs + carry bit and place result in Rd
\ Rd = Rd + Rs + C-bit
( Rd Rs -- )
: _adcs
  d= 5 _aluop
;

\ subtract Rs from Rd using carry bit and place result in Rd
\ Rd = Rd - Rs - NOT C-bit
( Rd Rs -- )
: _sbcs
  d= 6 _aluop
;

\ rotate Rd to the right by Rs bits and place result in Rd
\ Rd = Rd ROR Rs
( Rd Rs -- )
: _rors
  d= 7 _aluop
;

\ test Rd with Rs and set condition codes
\ condition codes = Rd AND Rs
( Rd Rs -- )
: _tst
  d= 8 _aluop
;

\ subtract Rs from 0 and place result in Rd
\ Rd = 0 - Rs
( Rd Rs -- )
: _rsbs
  d= 9 _aluop
;

\ compare Rd with Rs and set condition codes
\ condition codes = Rd - Rs
( Rd Rs -- )
: _cmp
  d= $A _aluop
;

\ test Rd + Rs and set condition codes
\ condition codes = Rd + Rs
( Rd Rs -- )
: _cmn
  d= $B _aluop
;

\ or Rd with Rs and put result in Rd
\ Rd = Rd or Rs
( Rd Rs -- )
: _orrs
  d= $C _aluop
;

\ multiply Rd with Rs and put result in Rd
\ Rd = Rd * Rs
( Rd Rs -- )
: _muls
  d= $D _aluop
;

\ bit clear Rd using not Rs and put result in Rd
\ Rd = Rd and not Rs
( Rd Rs -- )
: _bics
  d= $E _aluop
;

\ not Rs and put result in Rd
\ Rd = not Rs
( Rd Rs -- )
: _mvns
  d= $F _aluop
;

\ logical shift left Rs by immediate val5 bits and put result in Rd
\ Rd = Rs << val5
( Rd Rs val5 -- )
: _lslsi
  d= $0 _opv5rsrd
;

\ logical shift right Rs by immediate val5 bits and put result in Rd
\ Rd = Rs >> val5
( Rd Rs val5 -- )
: _lsrsi
  d= $1 _opv5rsrd
;

\ arithmetic shift right Rs by immediate val5 bits and put result in Rd
\ Rd = Rs >> val5
( Rd Rs val5 -- asrsi )
: _asrsi
  d= $2 _opv5rsrd
;

\ add hi/low registers, no effect on flags
\ Rd = Rd + Rs
( Rd Rs -- add )
: _add
  d= 0 _ophirsrd
;

\ compare hi/low registers
\ Rd = Rs
( Rd Rs -- cmp )
: _cmp
  d= 1 _ophirsrd
;

\ move values between hi/low registers
\ Rd = Rs
( Rd Rs -- mov )
: _mov
  d= 2 _ophirsrd
;

\ perform branch (plus optional state change ) to address in register
\ bx Rs
( Rs -- bxrs )
: _bx
  d= 0 d= 3 _ophirsrd
;

\ store 32bit value in Rd to memory location pointed to by Rs + immediate offset
( Rd Rs offset -- str )
: _str
  d= %01100 _opv5rsrd
;

\ store 8bit value in Rd to memory location pointed to by Rs + immediate offset
( Rd Rs offset -- strb )
: _strb
  d= %01110 _opv5rsrd
;

\ load Rd with 32bit value from memory pointed to by Rs + immediate offset
( Rd Rs offset -- ldr )
: _ldr
  d= %01101 _opv5rsrd
;

\ load Rd with 8bit value from memory pointed to by Rs + immediate offset
( Rd Rs offset -- opv5rsrd )
: _ldrb
  d= %01111 _opv5rsrd
;

\ store 16bit value in Rd to memory location pointed to by Rs + immediate offset
( Rd Rs offset -- strh )
: _strh
  d= %10000 _opv5rsrd
;

\ load Rd with 16bit value from memory pointed
\ to by Rs + immediate offset
( Rd Rs offset -- ldrh )
: _ldrh
  d= %10001 _opv5rsrd
;

\ add low registers
\ Rd = Rs + Rn
( Rd Rs Rn -- adds )
: _adds
  d= %1100 _opvrrsrd
;

\ subtract low registers
\ Rd = Rs - Rn
( Rd Rs Rn -- subs )
: _subs
  d= %1101 _opvrrsrd
;

\ add 3 bit immediate value to low register
\ and store in low register
\ Rd = Rs + val3
( Rd Rs val3 -- addis )
: _addis
  d= %1110 _opvrrsrd
;

\ subtract 3 bit immediate value from low register
\ and store in low register
\ Rd = Rs - val3
( Rd Rs val3 -- subis )
: _subis
  d= %1111 _opvrrsrd
;

\ store 32bit value in Rd to memory location pointed to by SP + immediate offset
( Rd offset -- strsp )
: _strsp
  d= %10010 _oprdv8
;

\ load Rd with 32bit value from memory pointed to by SP + immediate offset
( Rd offset -- ldrsp )
: _ldrsp
  d= %10011 _oprdv8
;

\ load Rs with 32bit value poped from Rd stack
( Rd Rs -- ldmia! )
: _ldmia!
  y=
  1 [ _w d= _y _lsls , ]
  d= %11001 _oprdv8
;

\ add 7bit word offset to stack pointer
\ 1 _addsp
\ sp = sp + 1 word (4 bytes)
( offset -- addsp )
: _addsp
  y# $7F [ _y d= _w _ands , ]
  $B000 |y
;

\ subtract 7bit word offset from stack pointer
\ 1 _subsp
\ sp = sp - 1 word (4 bytes)
( offset -- subsp )
: _subsp
  y# $7F [ _y d= _w _ands , ]
  $B080 |y
;

\ push registers onto return stack
\ list is an 8 bit value indicating which registers to push
\ r7 r6 r5 r4 r3 r2 r1 r0
( list -- push )
: _push
  y# $FF [ _y d= _w _ands , ]
  $B400 |y
;

\ pop registers from return stack
\ list is an 8 bit value indicating which registers to pop
\ r7 r6 r5 r4 r3 r2 r1 r0
( list -- pop )
: _pop
  y# $FF [ _y d= _w _ands , ]
  $BC00 |y
;
