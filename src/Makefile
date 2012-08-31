
all: libget.so tester suid

BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib
CC=gcc

libget.so: trap_so.c
	rm -f libget.so*
	gcc -fPIC -shared -Wl,-soname,libget.so.1 -o libget.so.1.0  trap_so.c -ldl
	ln -s libget.so.1.0 libget.so.1
	ln -s libget.so.1 libget.so

install: libget.so
	mkdir -p $(BINDIR)
	mkdir -p $(LIBDIR)
	install -t $(LIBDIR) libget.so*
clean:
	rm -f libget.so* *.o tester suid
