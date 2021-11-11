.equ pc  0x0000
.equ out 0x0001
.equ sp  0x00ff
.equ r1  0x00fe
.equ r2  0x00fd
.equ r3  0x00fc

main:
	#initialize stack pointer
	mov defaultsp, sp

	#call print(text1)
	mov text1, r1
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print,pc
	.word $+1

	#call print(text2)
	mov text2, r1
	add n1, sp
	mov sp, $+5
	mov $+6,
	mov print,pc
	.word $+1

	#exit
	mov 0,3




text1:
	.word $+1
	.string "Hello!\n"

text2:
	.word $+1
	.string "World!\n"



print: #print string from r1
	.word $+1
	# r2 = [r1]
	mov r1, $+4
	mov   , r2   # r2 is now text[0]
	# print character
	mov r2, out  # print character
	# increment r1
	add p1, r1   # go to text[1]
	# test if character is not 1
	mov n1, r3   # r3 is now 0xffff
	add r2, r3   # add text[0] to r3 , if text[0] was not 0, it will overflow and F will be set
	# jump if 
	mif print, pc # repeat if not 0

	#return
	mov sp, $+7  # load stack value from the stack into the mov ,0 command
	add p1, sp   # increment stack back up
	mov   , 0    # jump back

	
ptint_int: #print int from r1
	.word $+1
	

	#return
	mov sp, $+7  # load stack value from the stack into the mov ,0 command
	add p1, sp   # increment stack back up
	mov   , 0    # jump back

defaultsp: #the default value for the stack pointer
	.word 0x4000
n1: # constant negative 1
	.word -1
p1: # constant positive 1
	.word +1
