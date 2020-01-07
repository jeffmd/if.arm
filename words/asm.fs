\ arm thumb assembler instructions

rword _w inlined
  ] 0 [
  _bxlr ,

rword _r1 inlined
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
  ] 4 [
  _bxlr ,

rword _d2 inlined
  ] 8 [
  _bxlr ,

rword _r0 inlined
  ] 0 [
  _bxlr ,

rword _r1 inlined
  ] 4 [
  _bxlr ,

rword _r2 inlined
  ] 8 [
  _bxlr ,

\ move immediate into register
( Rd val8 -- )
: _movsi
  d= 4 _oprdval
;

\ compare immediate with register
( Rd val8 -- )
: _cmpsi
  d= 5 _oprdval
;

\ add immediate to register
( Rd val8 -- )
: _addsi
  d= 6 _oprdval
;

\ subtract immediate from register
( Rd val8 -- )
: _subsi
  d= 7 _oprdval
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
  d= $0 _opvalrsrd
;

\ logical shift right Rs by immediate val5 bits and put result in Rd
\ Rd = Rs >> val5
( Rd Rs val5 -- )
: _lsrsi
  d= $1 _opvalrsrd
;

\ arithmetic shift right Rs by immediate val5 bits and put result in Rd
\ Rd = Rs >> val5
( Rd Rs val5 -- asrsi )
: _asrsi
  d= $2 _opvalrsrd
;

\ add registers
\ Rd = Rd + Rs
( Rd Rs -- add )
: _add
  d= 0 _ophirsrd
;

\ compare registers
\ Rd = Rs
( Rd Rs -- cmp )
: _cmp
  d= 1 _ophirsrd
;

\ move values between registers
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
( Rd Rs offset -- )
: _str
  d= %01100 _opvalrsrd
;

\ store 8bit value in Rd to memory location pointed to by Rs + immediate offset
( Rd Rs offset -- )
: _strb
  d= %01110 _opvalrsrd
;

\ load Rd with 32bit value from memory pointed to by Rs + immediate offset
( Rd Rs offset -- )
: _ldr
  d= %01101 _opvalrsrd
;

\ load Rd with 8bit value from memory pointed to by Rs + immediate offset
( Rd Rs offset -- )
: _ldrb
  d= %01111 _opvalrsrd
;

\ store 16bit value in Rd to memory location pointed to by Rs + immediate offset
( Rd Rs offset -- )
: _strh
  d= %10000 _opvalrsrd
;

\ load Rd with 16bit value from memory pointed to by Rs + immediate offset
( Rd Rs offset -- )
: _ldrh
  d= %10001 _opvalrsrd
;

