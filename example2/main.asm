mov main,jump #Jump to the main.
#The order of the .asm files won't be important if we have this line in every file.

.equ jump 0x0000 #The pc aka program couner, move to this register to jump
.equ out  0x0001
.equ in   0x0001
.equ exit 0x0003
.equ sp   0x00FF
#Registers that you don't need to preserve during subroutine calls
.equ r1   0x00fe
.equ r2   0x00fd
.equ r3   0x00fc
.equ r4   0x00fb
#Registers that you DO need to preserve during subroutine calls (just push them and pop them)
.equ r5   0x00fa
.equ r6   0x00f9
.equ r7   0x00f8
.equ r8   0x00f7

main:
	.word $+1
	#initialize stack pointer
	mov defaultsp, sp

    ###########################
    # H e l l o   W o r l d ! #
    ###########################

	##call print(text1)
	#mov text1, r1	#move char pointer into r1
	#add n1, sp	#add stack element
	#mov sp, $+5	#prepare the next mov
	#mov $+6,	#move the return address onto the stack
	#mov print,jump	#jump into the subroutine
	#.word $+1	#the acatual return address

    ###################
    # S u b t r a c t #
    ###################
	mov num1, r1
	mov num2, r2
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov subtract,jump
	.word $+1
	#result is still in r1
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print_int_ln,jump
	.word $+1

    ###################
    # M u l t i p l y #
    ###################
	mov num1, r1
	mov num2, r2
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov multiply,jump
	.word $+1
	#result is still in r1
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print_int_ln,jump
	.word $+1

    ###############
    # D i v i d e #
    ###############
	mov num1, r1
	mov num2, r2
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov divide,jump
	.word $+1
	#result is still in r1
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print_int_ln,jump
	.word $+1

#    #####################
#    # F i b o n a c c i #
#    #####################
#
#	#init variables
#	mov p1, r5	#r5 = first number
#	mov p1, r6	#r6 = second number
#loop:			#r7 = sum
#	#add r5+r6=>r7
#	mov r5,r7
#	add r6,r7
#	#break if overflow
#	mif break1,jump
#	#print_int_ln(r5)
#	mov r6,r1
#	add n1,sp
#	mov sp,$+5
#	mov $+6,
#	mov print_int_ln,jump
#	.word $+1
#	#move all values one place down
#	mov r6,r5
#	mov r7,r6
#	#jump back up
#	mov $+3,jump
#	.word loop
#break1:
#	.word $+1



	#exit
	mov ,exit

num1:
	.word 1234
num2:
	.word 23


text1:
	.word $+1
	.string "Hello World!\n00001\n00001\n"


defaultsp: #the default value for the stack pointer
	.word 0x4000
