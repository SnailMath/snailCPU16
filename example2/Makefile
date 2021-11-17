
SOURCES:=$(wildcard *.asm)

BINARY:=example2.bin

CPU:=../snailcpu

all: $(BINARY)

clean:
	rm -f example2.bin
	rm -f *~ .*~

run: $(BINARY) $(CPU)
	$(CPU) $(BINARY)

$(BINARY): $(SOURCES)
	python ../asm.py $(SOURCES) -o $@

$(CPU): ../snailcpu.cpp
	cd .. ; make

.PHONY : clean all
