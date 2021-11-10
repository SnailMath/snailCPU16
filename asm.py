#!/bin/python3
'''
A simple assembler for my snailCPU16
'''

#Important varibles:
ENTRY_POINT = 0x100

DEBUG=False
#DEBUG=True



#Imports
import sys

#Initializing variables
equs = {}       # constants like equs and lables
offsets = []    # positions where we need to put constants and lables

#The output
outlist = []
outindex =0     #The current address            (relative to the start of the bin file)
dollarsign = 0  #The start address of the code  (relative to the start of the bin file)
def output(x):
    global outlist
    global outindex
    global dollarsign
    outlist.append(x)
    outindex += 1

#Handle a single arg (starts at postion index and ends with ',', '#', or with the end of the list
def handleArg(index, tokens):
    arg = []
    loop=True
    while index<len(tokens) and loop:
        if tokens[index]=="," or tokens[index]=="#":
            loop=False
        elif tokens[index]=="$":
            arg.append(dollarsign+ENTRY_POINT)
        else:
            arg.append(tokens[index])
        index+=1 
    offsets.append([outindex,arg])
    output(12345)
    return index

#output the command and handle both arguments
def command(x, tokens):
    global dollarsign
    global outindex
    global token_index
    dollarsign = outindex # save the address of the beginning of this line (needed for the $)
    output(x)
    token_index=1; #index used for evaluating args, 0 is the command, 1 is the first arg
    token_index=handleArg(token_index, tokens)
    handleArg(token_index, tokens)



####### M A I N #######

#Check if the number of args is correct
if len(sys.argv)!=3:
    print("Usage: python asm.py input.asm output.bin")
    exit();

#Read the lines from the input file
try:
    with open(sys.argv[1]) as f:
        lines = f.readlines()
except:
    print(f"Error: Can't open file '{sys.argv[1]}' for reading.")
    exit()

#1st step: Go through each line
line_nr = 0
for line in lines:
    line_nr+=1

    #Convert the lines to tokens
    tokens = line.replace("\n","").replace(","," , ").replace("+"," + ").replace("-"," - ").replace("*"," * ").replace("!"," # ").replace("#"," # ").replace("//"," # ").split();

    #Ignore blank lines
    if(len(tokens)==0):
        continue
    #Ignore comments
    elif tokens[0]=="#":
        continue

    #save .equs
    elif tokens[0]==".equ":
        if(len(tokens)>=3):
            if tokens[1] in equs:
                print(f"Error in line {line_nr}: Multiple occurrances of lable or .equ \"{tokens[1]}\"")
            try:
                value = int(tokens[2])
            except:
                print(f"Error in line {line_nr}: '{tokens[2]}' is not a valid number. (Note: don't use lables or equs here.)")
                value = 0
            equs[tokens[1]]=value
            if(len(tokens)>3):
                if tokens[3]!="#":
                    print(f"Unrecognized characters at the end of line {line_nr}. Did you froget a comment?")
        else:
            print(f"Error in line {line_nr}. Not enough arguments for .equ")

    #put .string into the output file
    elif tokens[0]==".string":
        string_hasnt_started=True
        escapeChar=False
        for i in list(line):
            #Search fot the beginning of the string
            if string_hasnt_started:
                if i=='"':
                    string_hasnt_started=False
            #Handle escape chars
            elif escapeChar:
                if i=="n":
                    output(ord("\n"))
                else:
                    output(ord(i))
                escapeChar=False
            #Handle normal chars
            else:
                #Check if the string is finished
                if i=='"':
                    break
                #Check if the string is unterminated
                elif i=='\n':
                    print(f"Error in line {line_nr}. Unterminated String")
                #Check if we got an escape char
                elif i=="\\":
                    escapeChar=True
                #handel normal letters
                else:
                    output(ord(i))
        output(0) #Terminate the string

    #Handle .word
    elif tokens[0]==".word":
        dollarsign = outindex # save the address of the beginning of this line (needed for the $)
        token_index=1; #index used for evaluating args, 0 is the '.word', 1 is the first part of the value
        handleArg(token_index, tokens)

    #Handle the commands
    elif  tokens[0]=="mov":
        command(0,tokens)
    elif  tokens[0]=="add":
        command(1,tokens)
    elif  tokens[0]=="xor":
        command(2,tokens)
    elif  tokens[0]=="and":
        command(3,tokens)
    elif  tokens[0]=="sft" or tokens[0]=="shift":
        command(4,tokens)
    elif  tokens[0]=="mif":
        command(5,tokens)

    # Handle lables
    elif tokens[0][len(tokens[0])-1]==":":
        lable = tokens[0][0:len(tokens[0])-1]
        if lable in equs:
            print(f"Error in line {line_nr}: Multiple occurrances of lable or .equ \"{lable}\"")
        equs[lable]=outindex + ENTRY_POINT

    # Errors
    else:
        print(f"Error in line {line_nr}: Unrecognized line: {line}", end='')

if(DEBUG):
    print(f"\nequs and lables: {equs}\n\noffsets still to correct: {offsets}\n\nthe binary data: {outlist}\n")

# 2nd step: replace the offsets
for entry in offsets:
    if(DEBUG):
        print(entry)
    i = 0 #tokenindex
    address = entry[0] # The address to replace
    tokens  = entry[1] # The tokens for this address
    value   = 0        # The value
    mode    = "add"
    while i<len(tokens):
        if tokens[i]=="+":
            mode="add"
            if(DEBUG):
                print("Token add")
        elif tokens[i]=="*":
            mode="mul"
            if(DEBUG):
                print("Token mul")
        elif tokens[i]=="-":
            mode="sub"
            if(DEBUG):
                print("Token sub")
        elif tokens[i] in equs:
            if(DEBUG):
                print(f"Token {tokens[i]} is in equs")
            if mode=="mul":
                value *= equs[tokens[i]]
            elif mode=="sub":
                value -= equs[tokens[i]]
            else:
                value += equs[tokens[i]]
        else: #Token must be a number
            try:
                thisvalue = int(tokens[i])
                if(DEBUG):
                    print(f"Token {tokens[i]} is a number")
            except:
                thisvalue = 0;
                print(f"Error near line {int(address/3)}: Token '{tokens[i]}' is not a valid number!")
            if mode=="mul":
                value *= int(thisvalue)
            elif mode=="sub":
                value -= int(thisvalue)
            else:
                value += int(thisvalue) 
        i+=1
    if(DEBUG):
        print(f"The offset at {address} was evaluated to {value}")
    outlist[address] = value

if(DEBUG):
    print(f"\nthe binary data: {outlist}\n")

#save to the file
try:
    outfile =open(sys.argv[2],"wb") #write to the file in binary
except:
    print(f"Error: Can't open file '{sys.argv[2]}' for writing.")
    exit()

if(DEBUG):
    print("Outputting to the file...")

for i in outlist:
    low  =  i     & 0xff
    high = (i>>8) & 0xff
    if(DEBUG):
        print("%04X %02X %02X" % (i,high,low))
    outfile.write(bytes([high]))
    outfile.write(bytes([low]))

    
