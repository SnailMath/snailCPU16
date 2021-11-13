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
The area below 0x100 is usually used as general purpose registers and the area from 0x100 us used for the program and for constant values.
You'll need global values, because there is no direct add or mov, you'll have to put values like 1 and -1 here...

## Instructions:
| hex            | asm        | pseudocode       | info |
| ---            | ---        | ---              | --- |
| `0000xxxxyyyy` | `mov x, y` | [x]       -> [y] | |
| `0001xxxxyyyy` | `add x, y` | [x] + [y] -> [y] | overflow sets Flag, Flag otherwise cleared. |
| `0002xxxxyyyy` | `xor x, y` | [x] ^ [y] -> [y] | |
| `0003xxxxyyyy` | `and x, y` | [x] & [y] -> [y] | |
| `0004xxxxyyyy` | `sft x, y` | [y]<<[x]  -> [y] | (`shift x, y`) shift left (right if x<0), last bit -> F |
| `0005xxxxyyyy` | `mif x, y` | [x]       -> [y] | move-if (move only if Flag is set)  |

## I need the Instruction (insert instruction here)! But it's missing! What should I do?

Everything should work with these instructions.

### Use the stack

To use the stack, you need to initialize the stack pointer first.
```
0100   0000 2000 00FF	mov initsp,sp	//initialize the stack pointer

initsp:
2000   4000		.word 0x4000
```
```
push x:
0110   0001 2002 00FF   add n1, SP	//pull down the stack pointer (using the consstant 'Constant Negative One' -1)
0113   0000 00FF 0118   mov SP , $+5	//put the stack address at offset 5 from the curren location, the destination of the next mov
0116   0000 xxxx 0000   mov x,		//The destination is overvritten by the last instruction

pop x:
0120   0000 00FF 0124   mov SP, $+4	//put this at offset 4 from the curren location, the source of the next mov
0123   0000 0000 xxxx   mov ,x		//The source is overvritten by the last instruction
0126   0001 2001 00FF   add p1, SP	//push the stack pointer back up (using the consstant 'Constant Plus One' +1)

constants:
p1: # Constant PlusOne
2001   0001             .word +1
n1: # Constant NegativeOne
2002   FFFF             .word -1
```

### call subroutines

```
call x: //call the subroutine at x
0130   0001 2002 00FF   add n1, SP	//pull down the stack pointer (using the consstant 'Constant Minus One' -1)
0133   0000 00FF 0128   mov SP, $+5	//put the stack address at offset 5 from the current location
0136   0000 013C 0000   mov $+6,	//put the returnaddress on the stack (remember the 0 was overritten)
0139   0000 xxxx 0000   mov x, PC	//put the subroutine address into the program counter(jump)(This is actually the addresses address, which is one byte before the subroutine)
013C   013D  		.word $+1	//the return address ist written here, because we don't have a move immidiate instruction.
013D   continue execution after subroutine here...

//The subroutine:
0140   0141		.word $+1	//the actual address where the actual code begins
0141   0000 0000 0000	some code	//(the code 0000 0000 0000 is a nop instruction)

return: //return from the subroutine
0144   0000 00FF 014B	mov SP, $+7	//put the stack pointer in the 2nd next instruction as a source
0147   0001 2001 00FF	add p1, SP	//put the stack pointer back up (the actual pop) (using the constant 'Constant Plus One' +1)
014A   0000 0000 0000	mov ,PC		//jump back (return) using the address, that's still there, we put the address of the address here 2 lines ago. 
```

### subtract

```
sub x-y => z : //subtract y from x and save in z
0150   0000 yyyy zzzz	mov y  , z	// create the 2's complement of y in z
0153   0002 FFFF zzzz	xor cm1, z	// (first invert)
0156   0001 FFFE zzzz	add cp1, z	// (then add 1), now z contains -y
0159   0001 xxxx zzzz	add x  , z	// now add x, z now contains x-y
```

## Assembler

The assembler is a python script that converts assembly files into machine code.

- `#`, `!` or `//` Comments, ending with `\\n`
- `.equ x y` sets the constant x to value y
- `.string "x"` an actual string
- `.word x` a one word value in the code
- `abc:` a lable (can be used as an argument for commands)
- `amov x, y` a command (must be one of the 6 in the hardware specs), x any y are values like this:
	- a number (decimal, binary or hexadecimal, anything python can calculate)
	- a constant, lable or a '$' (current location)
	- a calculation using numbers and lables with all operators that python understands `( ) + - * / ** << >> ~ ^ | &` e.g.: "lable+1" or "$+(3-2)"

just run `python asm.py test.asm test.bin` to assemble and run `snailcpu test.bin` to execute.
