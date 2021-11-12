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

```
push x:
0100   0001 3FFF 00FF   add cm1, SP	//pull down the stack pointer (using the consstant 'Constant Minus One' -1)
0103   0000 00FF 0108   mov SP , $ +5	//put the stack address at offset 5 from the curren location, the destination of the next mov
0106   0000 xxxx FFFF   mov x  , -1	//The destination is overvritten by the last instruction

pop x:
0110   0000 00FF 0114   mov SP , $ +4	//put this at offset 4 from the curren location, the source of the next mov
0113   0000 xxxx FFFF   mov -1 , x	//The source is overvritten by the last instruction
0116   0001 3FFE 00FF   add cp1, SP	//push the stack pointer back up (using the consstant 'Constant Plus One' +1)

constants:
cp1: # ConstantPlusOne
3FFE   0001             .word +1
cm1: # ConstantMinusOne
3FFF   FFFF             .word -1
```

### call subroutines

```
call x: //call the subroutine at x
0120   0001 3FFF 00FF   add cm1, SP	 //pull down the stack pointer (using the consstant 'Constant Minus One' -1)
0123   0000 00FF 0128   mov SP , $ +5	 //put the stack address at offset 5 from the current location
0126   0000 012D FFFF   mov retadrr, -1 //put the returnaddress on the stack (remember the -1 was overritten)
0129   0000 012C 0000   mov x, PC	 //put the subroutine address (from 012D) into the program counter (jump)
012C   xxxx 012E  //the subroutine address and the return address ist written here, because we don't have a move immidiate instruction.
012E   continue execution after subroutine here...

return: //return from the subroutine
0130   0000 00FF 0137   mov SP , $ +7	//put the stack pointer in the 2nd next instruction as a source
0133   0001 3FFE 00FF   add cp1, SP	//put the stack pointer back up (the actual pop) (using the constant 'Constant Plus One' +1)
0136   0000 FFFF 0000   mov -1 , PC	//jump back (return) using the address, that's still there, we put the address of the address here 2 lines ago. 
```

### subtract

```
sub x-y => z : //subtract y from x and save in z
0140   0000 yyyy zzzz	mov y  , z	// create the 2's complement of y in z
0143   0002 FFFF zzzz	xor cm1, z	// (first invert)
0146   0001 FFFE zzzz	add cp1, z	// (then add 1), now z contains -y
0149   0001 xxxx zzzz	add x  , z	// now add x, z now contains x-y
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
