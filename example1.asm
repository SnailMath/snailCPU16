.equ jump 0x0000 #The pc aka program couner, move to this register to jump
.equ out  0x0001
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
	#initialize stack pointer
	mov defaultsp, sp

    ###########################
    # H e l l o   W o r l d ! #
    ###########################

	#call print(text1)
	mov text1, r1	#move char pointer into r1
	add n1, sp	#add stack element
	mov sp, $+5	#prepare the next mov
	mov $+6,	#move the return address onto the stack
	mov print,jump	#jump into the subroutine
	.word $+1	#the acatual return address


    #####################
    # F i b o n a c c i #
    #####################

	#init variables
	mov p1, r5	#r5 = first number
	mov p1, r6	#r6 = second number
loop:			#r7 = sum
	#add r5+r6=>r7
	mov r5,r7
	add r6,r7
	#break if overflow
	mif break1,jump
	#print_int_ln(r5)
	mov r6,r1
	add n1,sp
	mov sp,$+5
	mov $+6,
	mov print_int_ln,jump
	.word $+1
	#move all values one place down
	mov r6,r5
	mov r7,r6
	#jump back up
	mov $+3,jump
	.word loop
break1:
	.word $+1



	#exit
	mov ,exit



text1:
	.word $+1
	.string "Hello World!\n00001\n00001\n"


print: #print string from r1
	.word $+1    # The address of the print routine is stored here, it start 1 word furher down.
	# r2 = [r1]
	mov r1, $+4
	mov   , r2	# r2 is now text[0]
	# print character
	mov r2, out	# print character
	# increment r1
	add p1, r1	# go to text[1]
	# test if character is not 1
	mov n1, r3	# r3 is now 0xffff
	add r2, r3	# add text[0] to r3 , if text[0] was not 0, it will overflow and F will be set
	# jump if 
	mif print,jump	# repeat if not 0

	#return
	mov sp, $+7  # load stack value from the stack into the mov ,0 command
	add p1, sp   # increment stack back up
	mov   , 0    # jump back

	
print_int: #print int from r1
	.word $+1
	#print 10_000th place
	mov ascnum, r2 	# don't set this to 0, set this digit to '0'-1 instead, so we don't have to subtract 1 and add '0' later
prir4:
	add p1, r2	#add 1 to this digit
	add n1e4, r1	#subtract 10000 from the number
	mif prir4a,jump#if we are haven't reached 0: repeat, if we are below 0: continue
	add p1e4,r1	#add 10_000 back, don't subtract 1 from the digit and don't add '0' to convert to ascii, because we initialized it to '0'-1
	mov r2, out	#print this digit
	#print 1_000th place
	mov ascnum, r2
prir3:
	add p1, r2
	add n1e3, r1
	mif prir3a,jump
	add p1e3,r1
	mov r2, out
	#print 100th place
	mov ascnum, r2
prir2:
	add p1, r2
	add n1e2, r1
	mif prir2a,jump
	add p1e2,r1
	mov r2, out
	#print 10th place
	mov ascnum, r2
prir1:
	add p1, r2
	add n1e1, r1
	mif prir1a,jump
	add p1e1,r1
	mov r2, out
	#print 1st place
	mov ascnum2, r2
	add r1, r2
	mov r2, out	
	#return
	mov sp, $+7  # load stack value from the stack into the mov ,0 command
	add p1, sp   # increment stack back up
	mov   , 0    # jump back

ascnum:
	.word ord('0')-1 #This value is needed for the ascii conversion. It simultaniously adds '0' and subracts 1, it is used when we counted one too high
ascnum2:
	.word ord('0') #This is needed for the last digit, this makes a lot easier.
#The jump addresses inside the print_int and the powers of 10
prir4a:
	.word prir4
n1e4:
	.word -10_000
p1e4:
	.word +10_000
prir3a:
	.word prir3
n1e3:
	.word -1_000
p1e3:
	.word +1_000
prir2a:
	.word prir2
n1e2:
	.word -100
p1e2:
	.word +100
prir1a:
	.word prir1
n1e1:
	.word -10
p1e1:
	.word +10

print_int_ln:
	.word $+1
	#call print_int(r1)
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print_int,jump
	.word $+1
	#print newline character
	mov p1e1, out #reuse the 10 from the print_int subroutine as the \n, which is also 10
	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

#General 
defaultsp: #the default value for the stack pointer
	.word 0x4000
n1: # constant negative 1
	.word -1
p1: # constant positive 1
	.word +1
