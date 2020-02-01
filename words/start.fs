\ bootstrap if: loading core words ...
emit.off
include words/boot.fs
include words/core.fs
include words/asm.fs
include words/core-inline.fs 
include words/compiler.fs 
include words/minimum.fs 
include words/vocabulary.fs
include words/debugtools.fs 
include words/tasker.fs
\ include words/gpio.fs
emit.on
