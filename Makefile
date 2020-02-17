# Makefile

CFLAGS += -Og -g
#LDFLAGS += 
LDLIBS += -ldl -lm

INCS = *.S
OBJS = main.o input.o if.o

all: if

if : $(OBJS)

if.o : $(INCS)

lst: if
	objdump -D -S if > lst.txt

clean:
	rm -vf if *.o
