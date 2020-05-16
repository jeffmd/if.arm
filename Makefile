# Makefile
VPATH = src:include:obj

#LDFLAGS += 
LDLIBS += -ldl -lm
INCLUDES+=-Iinclude -Isrc

ASMINCS = src/*.S
OBJS = $(addprefix obj/, main.o input.o if.o)

CFLAGS +=$(INCLUDES) -g -Og -MMD -MP
BIN = if

all: $(BIN)

obj:
	@mkdir obj

if : $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS) $(LDLIBS)

obj/if.o: if.S $(ASMINCS)
	$(CC) -c $(CFLAGS) $< -o $@

obj/%.o: %.c %.d
	$(CC) -c $(CFLAGS) $< -o $@


DEPFILES = $(OBJS:.o=.d)	

$(DEPFILES):

lst: if
	objdump -D -S if > lst.txt

clean:
	@for i in $(OBJS); do (if test -e "$$i"; then ( rm -vf $$i ); fi ); done
	@rm -vf $(BIN)
