mov main,jump #Jump to the main.
#The order of the .asm files won't be important if we have this line in every file.


#inputs are r1, r2, ...
#output is r1
#r1 to r4 can be used

subtract:
	.word $+1
	#subtract
	xor n1, r2 #1's complement of the 2nd number
	add p1, r2 #add 1 to get the 2's complement
	add r2, r1 #add this number (now negative) to number 1
	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

multiply:
	.word $+1
	#multiply
	mov null,r3
	mov p16,r4
mulloop:
	sft n1,r2 #The bottom most bit is now in the Flag
	mif mulyes,jump
mulback:
	sft p1,r1
	#decrement
	add n1,r4
	mif a_mulloop,jump

	mov r3, r1
	
	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

mulyes:
	.word $+1
	add r1, r3
	mov $+3,jump
	.word mulback


divide: #The new divide
	#divide
	.word $+1
	#r1 divident r2 divisor r3 divisorbackup r4 bit counter/leading 0's r5 result r6 negative divisor
	#back up the divisor
	mov r2,r3 
 	#check if the divisor is 0
	add n1,r2
	mif nodiverr,jump
		mov diverr,jump
	nodiverr:
	.word $+1

	mov r3, r2  # restore the divisor (destroyed by the ==0 test)
	mov null,r5 # init result to 0
	mov n1, r4  # init the leading-0's-counter to -1
	#count leading 0's
divl1:
		add p1,r4
		sft p1,r2 #shift left and count up
		mif divl1break,jump # break if we reached the first non-0 bit
	mov $+3,jump #loop
	.word divl1
divl1break:
	.word $+1

	#now we've got the number of leading 0's in r4

	#now check how often the number fits into the divient
divl2:
		sft p1,r5 #shift the result to the left to make space for the new digit on the right
		mov r3,r2 #restore the divisor	
		sft r4,r2 #first shift the divisor left (aka ignore the leading 0's in the first run of the loop)
		#subtract divisor from the divident. (This works eiter 0 or 1 times)
		mov r2,r6 #create the negarive of the divisor
		xor n1,r6
		add p1,r6 #r6 is now the negative of the divisor
		add r6,r1 #subtract
		mif asubworked,jump #test if the subtraction worked
		#sub didn't work
			#if the subtraction was less than 0, we have to undo it.
			add r2,r1
			mov adivifend,jump
		#sub did work
		subworked:
			#if the subtraction worked, the number fits in there 1 times, so this bit is a 1
			add p1,r5
		divifend:
		#decrement the shift counter, so we compare one byte further right
		add n1,r4
		#if r4 wasn't 0, repeat.
	mif adivl2,jump

	#put the rest in r2 and the result in r1
	mov r1,r2
	mov r5,r1

	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

adivl2:
	.word divl2
asubworked:
	.word subworked
adivifend:
	.word divifend
diverr: #Print division error message!
	.word $+1
	mov $+6,r1
	mov print,jump
	.word $+1
	.string "Division by 0!\n"

a_mulloop:
	.word mulloop
p16:
	.word 16
