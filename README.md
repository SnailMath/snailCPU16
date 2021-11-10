# SnailCPU16

SnailCPU16 is a concept of a virtual processor by ThatLolaSnail / SnailMath.

- The CPU is a 16 bit cpu.
- There are no registers, every oerations is performed directly on the memory.
- There is a flag F
- Memory ranges from 0x0000 to 0x3FFF. Every cell is a word, not a byte. You can't accesss single bytes, only words.

## Memory Map:
| From   | To     | Usage/Function |
| ---    | ---    | ---            |
| 0x0000 | 0x3FFF | everything is RAM, unless otherwise specified (some parts have special purposes) |
| 0x0000 |        | Program counter (hardware)) |
| 0x0001 |        | Input/Outut (hardware) |
| 0x00FF |        | Stack pointer (if you want to) |
| 0x0100 | 0x3FFF | Intended for code and also variables. |

The stack could start at 0x3FFF and go down (sp is intialized to 4000, so when something is pushed, it gets first decremented and is 0x3FFF, 0x3FFE and so on...
Or initialize the stack pointer to 3F00 and use 3F00 to 3FFF (256 words) for constants and global values.
You'll need global values, because there is no direct add or mov, you'll have to put values like 1 and -1 here...

## Instructions:
| hex          | asm        | pseudocode       | info |
| ---          | ---        | ---              | --- |
| 0000xxxxyyyy | mov x, y   | [y] := [x]       | |
| 0001xxxxyyyy | add x, y   | [y] := [x] + [y] | overflow sets Flag, Flag otherwise cleared. |
| 0002xxxxyyyy | xor x, y   | [y] := [x] ^ [y] | |
| 0003xxxxyyyy | and x, y   | [y] := [x] & [y] | |
| 0004xxxxyyyy | shift x, y | [y] := [y]<<[x]  | the last bit will be put into Flag. If [x] is negative, perform a shift right instead. |
| 0005xxxxyyyy | mif x y    | [y] := [x]       | move-if (move only if Flag is set)  |

## Your are missing the Instruction (insert instruction here)! What to I do?

Everything should work with these instructions.

### Use the stack

```
push x:
0100   0001 3FFF 00FF   add const-1, SP //pull down the stack pointer
0103   0000 00FF 0108   mov SP, $+5	//put the stack address at offset 5 from the curren location, the destination of the next mov
0106   0000 xxxx FFFF   mov x, -1	//The destination is overvritten by the last instruction

pop x:
0110   0000 00FF 0114   mov SP, $+4	//put this at offset 4 from the curren location, the source of the next mov
0113   0000 xxxx FFFF   mov -1, x	//The source is overvritten by the last instruction
0116   0001 3FFE 00FF   add const+1, SP //push the stack pointer back up

constants:
const-1:
3FFE   FFFF            .word +1
const-1:
3FFF   FFFF            .word -1
```

### call subroutines

```
call x: //call the subroutine at x
0120   0001 3FFF 00FF   add const-1, SP //pull down the stack pointer
0123   0000 00FF 0128   mov SP, $+5     //put the stack address at offset 5 from the current location
0126   0000 012D FFFF   mov retadrr, -1 //put the returnaddress on the stack (remember the -1 was overritten)
0129   0000 012C 0000   mov x, PC       //put the subroutine address (from 012D) into the program counter (jump)
012C   xxxx 012E  //the subroutine address and the return address ist written here, because we don't have a move immidiate instruction.
012E   continue execution after subroutine here...

return: //return from the subroutine
0130   0000 00FF 0137   mov SP, $+7     //put the stack pointer in the 2nd next instruction as a source
0133   0001 3FFE 00FF   add const+1, SP //put the stack pointer back up (the actual pop)
0136   0000 FFFF 0000   mov -1, PC      //jump back (return) using the address, that's still there, we put the address of the address here 2 lines ago. 
```


