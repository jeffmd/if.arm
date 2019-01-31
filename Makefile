# Makefile
INCS = *.S

all: if

if : main.o if.o input.o
	gcc -Os -g -ldl -lm -o $@ $+

if.o : $(INCS)
	as -o $@ $<

lst:
	objdump -h -x -D -S if > lst.txt

clean:
	rm -vf if *.o
