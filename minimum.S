@ minimum.S

@ must be last word in core
Forthword_ WIPE, 0, "WIPE"
    push {lr}
   
    ldr r0, addr_dpstart
    movs wreg, #(ram_dp-sysvar_base)
    adds wreg, sysvar
    str r0, [wreg]
    
    dolit32_ EE_FORTHWORDLIST
    push_
    bl ZEROSTORE
    fourplus_
    bl ZEROSTORE
    
    @ init pause to noop
    dolit32_ NOOP
    bl PAUSEADDR
    bl STORE
    
    dolit32_ HERESTART
    bl HEREADDR
    bl STORE
    pop_lr_
    b ONLY    
