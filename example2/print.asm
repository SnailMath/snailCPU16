mov main,jump #Jump to the main.
#The order of the .asm files won't be important if we have this line in every file.


#################
### P R I N T ###
#################

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


###########################
### P R I N T _ U I N T ###
###########################
	
print_uint: #print int from r1
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


###############################
### P R I N T _ U I N T _ L N ###
###############################

print_uint_ln:
	.word $+1
	#call print_uint(r1)
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print_uint,jump
	.word $+1
	#print newline character
	mov p1e1, out #reuse the 10 from the print_uint subroutine as the \n, which is also 10
	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

###############################
### P R I N T _ I N T _ L N ###
###############################

print_int_ln:
	.word $+1
	mov r1,r2
	sft p1,r2 #get the highest bit of the number
	mif pilnegativ,jump
	#positiv
		mov plus,out
		mov print_uint_ln,jump
	#negariv
pilnegativ:
	.word $+1
		mov minus,out
		xor n1,r1
		add p1,r1
		mov print_uint_ln,jump

#########################
### P R I N T _ I N T ###
#########################
print_int:
	.word $+1
	mov r1,r2
	sft p1,r2 #get the highest bit of the number
	mif pinegativ,jump
	#positiv
		mov plus,out
		mov print_int,jump
	#negariv
pinegativ:
	.word $+1
		mov minus,out
		xor n1,r1
		add p1,r1
		mov print_int,jump


#########################
### C o n s t a n t s ###
#########################

plus:
	.word ord('+')
minus:
	.word ord('-')

ascnum:
	.word ord('0')-1 #This value is needed for the ascii conversion. It simultaniously adds '0' and subracts 1, it is used when we counted one too high
ascnum2:
	.word ord('0') #This is needed for the last digit, this makes a lot easier.

#The jump addresses inside the print_uint and the powers of 10
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
 
n1: # constant negative 1
	.word -1
p1: # constant positive 1
	.word +1
null: #constant 0
	.word 0
