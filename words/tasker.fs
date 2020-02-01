\ tasker.fs : words for managing tasks

only 
voc: Tasker
Tasker def

\ maximum number of tasks
62 con: maxtask
\ the active index into the task list
cvar: tidx#

\ count register for each task
\ is an array 
var: tcnt
maxtask dcell* allot

\ set task index
: tidx= ( n -- tidx# Y:n )
  y= tidx# c@=y
;

\ fetch task index: verifies index is valid
\ adjusts index if count is odd ?
: tidx ( -- n )
  tidx# c@ 
  \ verify index is below 63
  d= d=       ( idx idx idx )
  maxtask >   ( idx flag )
  ==0 =d      ( idx )
  ifnz
    \ greater than 62 so 0
    0 tidx=
    y
  then
;

\ get cnt address for a slot
\ idx: index of slot
: cnt& ( idx -- cntaddr Y:offset)
  dcell* y= tcnt +y
;

\ get count for a slot
\ idx: index of slot
: cnt ( idx -- cnt )
  cnt& @
;

\ get the count for current task executing
: count ( -- n )
 tidx cnt
;

\ increment tcnt array element using idx as index
: cnt++ ( idx -- cnt& Y:count )
  cnt& y=@ y+1 @=y
;

\ set tcnt array element using idx as index
: cnt= ( n idx -- )
  x=d cnt& @=x
;

\ array of task slots in ram : max 31 tasks 62 bytes
\ array is a binary process tree
\                        0                          62.5 ms
\             1                      2              125 ms
\      3           4           5           6        250 ms
\   7     8     9    10     11   12     13   14     500 ms
\ 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30   1 s
\ 31 -                                          62  2 s
var: tasks
maxtask dcell* allot

\ increment task index to next task idx
\ assume array flat layout and next idx = idx*2 + 1
: tidx++ ( -- )
  tidx *2 +1 
  \ if slot count is odd then 1+
  x= count
  y# 1 &y +x
  tidx=
;

\ get a task slot address at idx slot
: task& ( idx -- task )
  dcell* y= tasks +y 
;

\ get a task xt at idx slot
: task ( idx -- xt )
   task& @ 
;

\ store a task in a slot
\ idx is the slot index range: 0 to 62
\ addr is xt of word to be executed
: task= ( idx addr -- )
  x= =d task& @=x
;

\ store a task in a slot
\ example: 12 task: mytask
\ places xt of mytask in slot 12
: task: ( idx C: name -- )
  d= ' task=
;

\ clear task at idx slot
\ replaces task with noop
: taskclr ( idx -- )
  d= ['] noop task=
;


\ execute active task and step to next task
: taskex ( -- )
  \ increment count for task slot
  tidx d= cnt++
  d0 task exec
  tidx++
;

var: lastus
\ how often in microseconds to execute a task
\ default to 62.5/6 * 1000 us 
var: exus#

\ get execution micro second value
: exus ( -- exus )
  exus# @
;

\ set execution microsecond value
\ n is microseconds
: exus= ( n -- )
  y= exus# @=y
;

\ add offset to lastus
: lastus+= ( offset -- lastus Y:n )
  y=             ( offset Y:offset ) 
  lastus x=@
  x+y @=x        ( lastus )
;

\ execute tasks.ex if tick time expired
: tick ( -- )
  time lastus @  ( time lastms )
  y= d0 -y d0=   ( timediff timediff Y:lastms )
  d= exus u>     ( timediff flag )
  ==0
  =d             ( timediff )
  ifnz
    lastus+=     ( lastms Y:timediff )
    taskex
  else
    y# 255 &y usleep
  then
;

\ clear all tasks
: allclr ( -- )
  \ iterate 0 to 30 and clear tcnt[] and set tasks[] to noop
  0 tidx=          ( idx )
  d=y              ( 0 ? )
  begin
    0 d= d1        ( idx 0 idx )
    cnt=           ( idx ? )
    d0 taskclr     ( idx ? )
    d0 +1 d0=      ( idx+1 idx+1 )
    d= maxtask >   ( idx+1 flag ) 
    ==0
  untilnz
  d-1
;

\ start tasking
: run ( -- )
  10417 exus=
  lastus y=0 @=y
  ['] tick pause=
;

\ reset tasker
\ all tasks are reset to noop
: reset ( -- )
  allclr
  run
;

\ stop tasks from running
: stop ( -- )
  pause.clr
;
