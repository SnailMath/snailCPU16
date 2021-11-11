all: snailcpu
clean:
	rm snailcpu
	rm *~ .*~

snailcpu: snailcpu.cpp
	gcc snailcpu.cpp -o snailcpu

