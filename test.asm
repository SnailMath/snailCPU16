! Define the equ for the port
.equ pc   0
.equ out  1
.equ quit 3

main:
mov text+0,out #print H
mov text+1,out #print e
mov text+2,out #print l
mov a_main2, pc # jump down

a_main2:
.word main2
text:
.string "Hello!\n"

main2:
mov text+3,out #print l
mov text+4,out #print o
mov text+5,out #print !
mov text+6,out #print \n

mov 0,quit #stop the program
