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
def handleArg(index, tokens, line_nr):
    arg = []
    newindex=index
    for thistoken in tokens[index:]:
        newindex+=1 
        if thistoken=="," or thistoken=="#":
            break
        elif thistoken=="$":
            arg.append(str(dollarsign+ENTRY_POINT))
        else:
            arg.append(thistoken)
    offsets.append([outindex,arg,line_nr])
    output(12345)
    return newindex

#output the command and handle both arguments
def command(x, tokens, line_nr):
    global dollarsign
    global outindex
    global token_index
    dollarsign = outindex # save the address of the beginning of this line (needed for the $)
    output(x)
    token_index=1; #index used for evaluating args, 0 is the command, 1 is the first arg
    token_index=handleArg(token_index, tokens, line_nr)
    handleArg(token_index, tokens, line_nr)



####### M A I N #######

#Evaluate commandline arguments
in_filenames=[]
out_filename=""
arg_mode="in" #if we're reading input or output filenames
i=1
for thisarg in sys.argv[1:]:
    if DEBUG:
        print(f"reading arg {thisarg}")
    if arg_mode=="out": #if we're reading an output filenme
        if out_filename:
            print("Warning: Two output filenames given, using the last one.")
        out_filename=thisarg
        if DEBUG:
            print(f"out_filename: {out_filename}")
        arg_mode="in" #exit the output-filename-read-mode
    elif thisarg=="-o":
        arg_mode="out" #go into output-filemame-read-mode
    else:
        in_filenames.append(thisarg)
        if DEBUG:
            print(f"in_filenames: {in_filenames}")
    i+=1

#Check if input filenames are given
if len(in_filenames)==0:
    print("Error! No input filenames given")
    exit()

#Check if output filename is given
if not out_filename:
    out_filename = in_filenames[0] + '.bin'

# Go through all input files
lines = []
for this_infile in in_filenames:

    #Read the lines from the input file
    try:
        with open(this_infile) as f:
            lines += f.readlines()
    except:
        print(f"Error: Can't open file '{this_infile}' for reading.")
        exit()

#1st step: Go through each line
line_nr = 0
for line in lines:
    line_nr+=1

    #Convert the lines to tokens
    #tokens = line.replace("\n","").replace(","," , ").replace("+"," + ").replace("-"," - ").replace("*"," * ").replace("!"," # ").replace("#"," # ").replace("//"," # ").split();
    tokens = line.replace("\n","").replace(","," , ").replace("+"," + ").replace("-"," - ").\
            replace("*"," * ").replace("*  *","**").replace("/"," / ").replace("("," ( ").\
            replace(")"," ) ").replace(">>"," >> ").replace("<<"," << ").replace("~"," ~ ").\
            replace("^"," ^ ").replace("|"," | ").replace("&"," & ").\
            replace("!"," # ").replace("#"," # ").replace("//"," # ").split();

    #Ignore blank lines
    if(len(tokens)==0):
        continue
    #Ignore comments
    elif tokens[0]=="#":
        continue

    #save .equs
    elif tokens[0]==".equ":
        if(len(tokens)>=3):
            value = 0
            if tokens[1] in equs:
                print(f"Error in line {line_nr}: Multiple occurrances of lable or .equ \"{tokens[1]}\"")
            try:
                value = int(tokens[2],0)
            except:
                print(f"Error in line {line_nr}: '{tokens[2]}' is not a valid number. (Note: don't use lables or equs here.)")
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
        handleArg(token_index, tokens, line_nr)

    #Handle the commands
    elif  tokens[0]=="mov":
        command(0,tokens,line_nr)
    elif  tokens[0]=="add":
        command(1,tokens,line_nr)
    elif  tokens[0]=="xor":
        command(2,tokens,line_nr)
    elif  tokens[0]=="and":
        command(3,tokens,line_nr)
    elif  tokens[0]=="sft" or tokens[0]=="shift":
        command(4,tokens,line_nr)
    elif  tokens[0]=="mif":
        command(5,tokens,line_nr)

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
    #if(DEBUG):
    #    print(entry)
    i = 0 #tokenindex
    address = entry[0] # The address to replace
    tokens  = entry[1] # The tokens for this address
    line_nr = entry[2]
    #value   = 0        # The value
    expr = ""
    #mode    = "add"
    for i in range(len(tokens)):
        #if tokens[i]=="+":
        #    mode="add"
        #    if(DEBUG):
        #        print("Token add")
        #elif tokens[i]=="*":
        #    mode="mul"
        #    if(DEBUG):
        #        print("Token mul")
        #elif tokens[i]=="-":
        #    mode="sub"
        #    if(DEBUG):
        #        print("Token sub")
        if tokens[i] in equs:
            expr += str(equs[tokens[i]])
            #if(DEBUG):
            #    print(f"Token {tokens[i]} is in equs")
            #if mode=="mul":
            #    value *= equs[tokens[i]]
            #elif mode=="sub":
            #    value -= equs[tokens[i]]
            #else:
            #    value += equs[tokens[i]]
        else: #Token must be a number
            expr += tokens[i]
            #try:
            #    thisvalue = int(tokens[i],0)
            #    if(DEBUG):
            #        print(f"Token {tokens[i]} is a number (converted from string)")
            #except:
            #    thisvalue = 0;
            #    print(f"Error near line {int(address/3)}: Token '{tokens[i]}' is not a valid number!")
            #if mode=="mul":
            #    value *= thisvalue
            #elif mode=="sub":
            #    value -= thisvalue
            #else:
            #    value += thisvalue
        i+=1
    try:
        value = eval(expr)
    except:
        if(expr!=''):
            print(f"Error in line {line_nr}: Can't evaluate '{expr}'")
        value = 0
    if(DEBUG):
        #print(f"The offset at {address} in line {line_nr} was evaluated to {expr}={value}")
        #print( "@%04X%05d  %s=%d" % address %line_nr %expr %value )
        print( "%4d %04X  %9s=%3d\t%s" % (line_nr, address, expr, value, str(tokens)) )
    outlist[address] = value

if(DEBUG):
    print(f"\nthe binary data: {outlist}\n")

#save to the file
try:
    outfile =open(out_filename,"wb") #write to the file in binary
except:
    print(f"Error: Can't open file '{sys.argv[2]}' for writing.")
    exit()

if(DEBUG):
    print("Outputting to the file...")

for i in outlist:
    low  =  i     & 0xff
    high = (i>>8) & 0xff
    #if(DEBUG):
    #    print("%04X %02X %02X" % (i,high,low))
    outfile.write(bytes([high]))
    outfile.write(bytes([low]))

    
