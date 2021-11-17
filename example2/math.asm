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


divide:
	.word $+1
	#divide
	mov r2,r3
	xor n1,r3
	add p1,r3 #r3 is now the 2's complemnt of r2
	mov n1,r4
divloop:
	add p1,r4
	add r3,r1
	mif a_divloop,jump
	
	mov r4,r1

	#return
	mov sp, $+7
	add p1, sp
	mov   , 0

a_divloop:
	.word divloop

a_mulloop:
	.word mulloop
p16:
	.word 16
