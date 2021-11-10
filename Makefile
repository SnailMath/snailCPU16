all: snailcpu
clean:
	rm snailcpu

snailcpu: snailcpu.cpp
	gcc snailcpu.cpp -o snailcpu

