@ interpret_number.S

@ ( addr len -- [n] [addr len] f )
@ recognizer for integer numbers
Forthword_ REC_NUM, 0, "rec#"
    push {lr}
    bl TWOOVER
    to_r_
    to_r_
    @ try converting to a number
    bl NUMBER              @ ( [n] f )
    zerosense_
    beq.n REC_NONUMBER

      bl STATEFETCH        @ ( n state )
      zerosense_
      beq.n REC_NUMBER_OK
        bl LIT

REC_NUMBER_OK:
      r_drop_
      r_drop_
      true_                @ ( n true )
      pop {pc}

REC_NONUMBER:
    r_from_
    r_from_
    zero_                  @ ( 0 )
    pop {pc}

