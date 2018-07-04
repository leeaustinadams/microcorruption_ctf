0010 <__trap_interrupt>
0010:  3041           ret
4400 <__init_stack>
4400:  3140 0040      mov	#0x4000, sp
4404 <__low_level_init>
4404:  1542 5c01      mov	&0x015c, r5
4408:  75f3           and.b	#-0x1, r5
440a:  35d0 085a      bis	#0x5a08, r5
440e <__do_copy_data>
440e:  3f40 8400      mov	#0x84, r15
4412:  0f93           tst	r15
4414:  0724           jz	#0x4424 <__do_clear_bss+0x0>
4416:  8245 5c01      mov	r5, &0x015c
441a:  2f83           decd	r15
441c:  9f4f 4045 0024 mov	0x4540(r15), 0x2400(r15)
4422:  f923           jnz	#0x4416 <__do_copy_data+0x8>
4424 <__do_clear_bss>
4424:  3f40 0200      mov	#0x2, r15
4428:  0f93           tst	r15
442a:  0624           jz	#0x4438 <main+0x0>
442c:  8245 5c01      mov	r5, &0x015c
4430:  1f83           dec	r15
4432:  cf43 8424      mov.b	#0x0, 0x2484(r15)
4436:  fa23           jnz	#0x442c <__do_clear_bss+0x8>
4438 <main>
4438:  b012 de44      call	#0x44de <set_up_protection>
443c:  b012 1245      call	#0x4512 <login>
4440:  0f43           clr	r15
4442 <__stop_progExec__>
4442:  32d0 f000      bis	#0xf0, sr
4446:  fd3f           jmp	#0x4442 <__stop_progExec__+0x0>
4448 <__ctors_end>
4448:  3040 3e45      br	#0x453e <_unexpected_>
444c <putchar>
444c:  0e4f           mov	r15, r14
444e:  0e12           push	r14
4450:  3180 0600      sub	#0x6, sp
4454:  3240 0080      mov	#0x8000, sr ; putchar INT 0x0
4458:  b012 1000      call	#0x10
445c:  3152           add	#0x8, sp
445e:  0f4e           mov	r14, r15
4460:  3041           ret
4462 <getsn>                    ; max chars in r14, addr in r15
4462:  0d4f           mov	r15, r13
4464:  0e12           push	r14
4466:  0d12           push	r13
4468:  3180 0600      sub	#0x6, sp
446c:  3240 0082      mov	#0x8200, sr ; gets INT 0x02
4470:  b012 1000      call	#0x10
4474:  3150 0a00      add	#0xa, sp
4478:  3041           ret
447a <puts>
447a:  0b12           push	r11
447c:  0b4f           mov	r15, r11
447e:  043c           jmp	#0x4488 <puts+0xe>
4480:  1b53           inc	r11
4482:  8f11           sxt	r15
4484:  b012 4c44      call	#0x444c <putchar>
4488:  6f4b           mov.b	@r11, r15
448a:  4f93           tst.b	r15
448c:  f923           jnz	#0x4480 <puts+0x6>
448e:  3f40 0a00      mov	#0xa, r15
4492:  b012 4c44      call	#0x444c <putchar>
4496:  0f43           clr	r15
4498:  3b41           pop	r11
449a:  3041           ret
449c <mark_page_writable>       ; page # in r15
449c:  0e4f           mov	r15, r14
449e:  1312           push	#0x1 ; 0x1 means mark writeable
44a0:  0e12           push	r14
44a2:  3180 0600      sub	#0x6, sp
44a6:  3240 0091      mov	#0x9100, sr ; INT 0x11
44aa:  b012 1000      call	#0x10
44ae:  3150 0a00      add	#0xa, sp
44b2:  3041           ret
44b4 <mark_page_executable>     ; page # in r15
44b4:  0e4f           mov	r15, r14
44b6:  0312           push	#0x0 ; 0x0 means mark executable
44b8:  0e12           push	r14
44ba:  3180 0600      sub	#0x6, sp
44be:  3240 0091      mov	#0x9100, sr ; INT 0x11
44c2:  b012 1000      call	#0x10
44c6:  3150 0a00      add	#0xa, sp
44ca:  3041           ret
44cc <turn_on_dep>
44cc:  3180 0600      sub	#0x6, sp
44d0:  3240 0090      mov	#0x9000, sr ; INT 0x10
44d4:  b012 1000      call	#0x10
44d8:  3150 0600      add	#0x6, sp
44dc:  3041           ret
44de <set_up_protection>
44de:  0b12           push	r11
44e0:  0f43           clr	r15
44e2:  b012 b444      call	#0x44b4 <mark_page_executable>   ; mark page 0x0 exe
44e6:  1b43           mov	#0x1, r11                        ; for 0x1 to 0x44 {
44e8:  0f4b           mov	r11, r15                         ;
44ea:  b012 9c44      call	#0x449c <mark_page_writable>     ;  mark page writeable
44ee:  1b53           inc	r11                              ;
44f0:  3b90 4400      cmp	#0x44, r11                       ;
44f4:  f923           jne	#0x44e8 <set_up_protection+0xa>  ; }
44f6:  0f4b           mov	r11, r15                         ; for 0x45 to 0x1000 {
44f8:  b012 b444      call	#0x44b4 <mark_page_executable>   ; mark page executable
44fc:  1b53           inc	r11                              ;
44fe:  3b90 0001      cmp	#0x100, r11                      ;
4502:  f923           jne	#0x44f6 <set_up_protection+0x18> ; }
4504:  b012 cc44      call	#0x44cc <turn_on_dep>
4508:  3b41           pop	r11
450a:  3041           ret
450c:  3041           ret
450e <conditional_unlock_door>
450e:  0f43           clr	r15
4510:  3041           ret
4512 <login>
4512:  3150 f0ff      add	#0xfff0, sp
4516:  3f40 0024      mov	#0x2400, r15
451a:  b012 7a44      call	#0x447a <puts> ; "Enter the password to continue."
451e:  3f40 2024      mov	#0x2420, r15
4522:  b012 7a44      call	#0x447a <puts> ; "Remember: passwords are between 8 and 16 characters."
4526:  3e40 3000      mov	#0x30, r14
452a:  0f41           mov	sp, r15
452c:  b012 6244      call	#0x4462 <getsn> ; call getsn to read max 48 bytes to sp
4530:  3f40 6524      mov	#0x2465, r15
4534:  b012 7a44      call	#0x447a <puts>
4538:  3150 1000      add	#0x10, sp
453c:  3041           ret
453e <_unexpected_>
453e:  0013           reti	pc
