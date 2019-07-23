# Makefile
INCS = *.S

all: if

if :  main.o input.o if.o
	gcc -Os -g -ldl -lm -o $@ $+

if.o : if.S $(INCS)
	as -o $@ $<

lst: if
	objdump -h -x -D -S if > lst.txt

clean:
	rm -vf if *.o
