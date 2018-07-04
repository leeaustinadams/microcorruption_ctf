0010 <__trap_interrupt>
0010:  3041           ret
4400 <__init_stack>
4400:  3140 0044      mov	#0x4400, sp
4404 <__low_level_init>
4404:  1542 5c01      mov	&0x015c, r5
4408:  75f3           and.b	#-0x1, r5
440a:  35d0 085a      bis	#0x5a08, r5
440e <__do_copy_data>
440e:  3f40 0000      clr	r15
4412:  0f93           tst	r15
4414:  0724           jz	#0x4424 <__do_clear_bss+0x0>
4416:  8245 5c01      mov	r5, &0x015c
441a:  2f83           decd	r15
441c:  9f4f f446 0024 mov	0x46f4(r15), 0x2400(r15)
4422:  f923           jnz	#0x4416 <__do_copy_data+0x8>
4424 <__do_clear_bss>
4424:  3f40 0102      mov	#0x201, r15
4428:  0f93           tst	r15
442a:  0624           jz	#0x4438 <main+0x0>
442c:  8245 5c01      mov	r5, &0x015c
4430:  1f83           dec	r15
4432:  cf43 0024      mov.b	#0x0, 0x2400(r15)
4436:  fa23           jnz	#0x442c <__do_clear_bss+0x8>
4438 <main>
4438:  b012 5e45      call	#0x455e <login>
443c <__stop_progExec__>
443c:  32d0 f000      bis	#0xf0, sr
4440:  fd3f           jmp	#0x443c <__stop_progExec__+0x0>
4442 <__ctors_end>
4442:  3040 f246      br	#0x46f2 <_unexpected_>
4446 <conditional_unlock_door>
4446:  0412           push	r4
4448:  0441           mov	sp, r4
444a:  2453           incd	r4
444c:  2183           decd	sp
444e:  c443 fcff      mov.b	#0x0, -0x4(r4)
4452:  3e40 fcff      mov	#0xfffc, r14
4456:  0e54           add	r4, r14
4458:  0e12           push	r14
445a:  0f12           push	r15
445c:  3012 7e00      push	#0x7e
4460:  b012 fc45      call	#0x45fc <INT>
4464:  5f44 fcff      mov.b	-0x4(r4), r15
4468:  8f11           sxt	r15
446a:  3152           add	#0x8, sp
446c:  3441           pop	r4
446e:  3041           ret
4470 .strings:
4470: "Enter the password to continue."
4490: "Remember: passwords are between 8 and 16 characters."
44c5: "Due to some users abusing our login system, we have"
44f9: "restricted passwords to only alphanumeric characters."
452f: "Access granted."
453f: "That password is not correct."
455d: ""
455e <login>
455e:  0b12           push	r11
4560:  3150 f0ff      add	#0xfff0, sp
4564:  3f40 7044      mov	#0x4470 "Enter the password to continue.", r15
4568:  b012 6046      call	#0x4660 <puts>
456c:  3f40 9044      mov	#0x4490 "Remember: passwords are between 8 and 16 characters.", r15
4570:  b012 6046      call	#0x4660 <puts>
4574:  3f40 c544      mov	#0x44c5 "Due to some users abusing our login system, we have", r15
4578:  b012 6046      call	#0x4660 <puts>
457c:  3f40 f944      mov	#0x44f9 "restricted passwords to only alphanumeric characters.", r15
4580:  b012 6046      call	#0x4660 <puts>
4584:  3e40 0002      mov	#0x200, r14
4588:  3f40 0024      mov	#0x2400, r15
458c:  b012 5046      call	#0x4650 <getsn>
4590:  5f42 0024      mov.b	&0x2400, r15            ; read a byte of input
4594:  0e43           clr	r14                     ; set index to zero
4596:  7c40 0900      mov.b	#0x9, r12
459a:  7d40 1900      mov.b	#0x19, r13
459e:  073c           jmp	#0x45ae <login+0x50>
45a0:  0b41           mov	sp, r11
45a2:  0b5e           add	r14, r11                ; r11 is stack pointer + index
45a4:  cb4f 0000      mov.b	r15, 0x0(r11)           ; write input byte to stack pointer + index
45a8:  5f4e 0024      mov.b	0x2400(r14), r15        ; load a byte of input to r15
45ac:  1e53           inc	r14                     ; move r14 to the next byte of input
45ae:  4b4f           mov.b	r15, r11                ; put the input in r11
45b0:  7b50 d0ff      add.b	#0xffd0, r11            ; subtract 47 from input
45b4:  4c9b           cmp.b	r11, r12                ; compare to 9 (check if it's one of 10 valid digits)
45b6:  f42f           jc	#0x45a0 <login+0x42>    ; then go to read next input byte
45b8:  7b50 efff      add.b	#0xffef, r11            ; subtract another 17 from input (now 64)
45bc:  4d9b           cmp.b	r11, r13                ; compare to 25 (check if it's one of 26 valid uppercase characters)
45be:  f02f           jc	#0x45a0 <login+0x42>    ; then go to read next input byte
45c0:  7b50 e0ff      add.b	#0xffe0, r11            ; subtract another 32 from input (now 96)
45c4:  4d9b           cmp.b	r11, r13                ; compare to 25 (check if it's one of 26 valid lowercase characters)
45c6:  ec2f           jc	#0x45a0 <login+0x42>    ; then go to read next input byte
45c8:  c143 0000      mov.b	#0x0, 0x0(sp)           ; else write zero to sp
45cc:  3d40 0002      mov	#0x200, r13
45d0:  0e43           clr	r14
45d2:  3f40 0024      mov	#0x2400, r15
45d6:  b012 8c46      call	#0x468c <memset>        ; zap 512 bytes to zero
45da:  0f41           mov	sp, r15
45dc:  b012 4644      call	#0x4446 <conditional_unlock_door> ; test the password
45e0:  0f93           tst	r15
45e2:  0324           jz	#0x45ea <login+0x8c>
45e4:  3f40 2f45      mov	#0x452f "Access granted.", r15
45e8:  023c           jmp	#0x45ee <login+0x90>
45ea:  3f40 3f45      mov	#0x453f "That password is not correct.", r15
45ee:  b012 6046      call	#0x4660 <puts>
45f2:  3150 1000      add	#0x10, sp
45f6:  3b41           pop	r11
45f8:  3041           ret
45fa <__do_nothing>
45fa:  3041           ret
45fc <INT>
45fc:  1e41 0200      mov	0x2(sp), r14
4600:  0212           push	sr
4602:  0f4e           mov	r14, r15
4604:  8f10           swpb	r15
4606:  024f           mov	r15, sr
4608:  32d0 0080      bis	#0x8000, sr
460c:  b012 1000      call	#0x10
4610:  3241           pop	sr
4612:  3041           ret
4614 <putchar>
4614:  2183           decd	sp
4616:  0f12           push	r15
4618:  0312           push	#0x0
461a:  814f 0400      mov	r15, 0x4(sp)
461e:  b012 fc45      call	#0x45fc <INT>
4622:  1f41 0400      mov	0x4(sp), r15
4626:  3150 0600      add	#0x6, sp
462a:  3041           ret
462c <getchar>
462c:  0412           push	r4
462e:  0441           mov	sp, r4
4630:  2453           incd	r4
4632:  2183           decd	sp
4634:  3f40 fcff      mov	#0xfffc, r15
4638:  0f54           add	r4, r15
463a:  0f12           push	r15
463c:  1312           push	#0x1
463e:  b012 fc45      call	#0x45fc <INT>
4642:  5f44 fcff      mov.b	-0x4(r4), r15
4646:  8f11           sxt	r15
4648:  3150 0600      add	#0x6, sp
464c:  3441           pop	r4
464e:  3041           ret
4650 <getsn>
4650:  0e12           push	r14
4652:  0f12           push	r15
4654:  2312           push	#0x2
4656:  b012 fc45      call	#0x45fc <INT>
465a:  3150 0600      add	#0x6, sp
465e:  3041           ret
4660 <puts>
4660:  0b12           push	r11
4662:  0b4f           mov	r15, r11
4664:  073c           jmp	#0x4674 <puts+0x14>
4666:  1b53           inc	r11
4668:  8f11           sxt	r15
466a:  0f12           push	r15
466c:  0312           push	#0x0
466e:  b012 fc45      call	#0x45fc <INT>
4672:  2152           add	#0x4, sp
4674:  6f4b           mov.b	@r11, r15
4676:  4f93           tst.b	r15
4678:  f623           jnz	#0x4666 <puts+0x6>
467a:  3012 0a00      push	#0xa
467e:  0312           push	#0x0
4680:  b012 fc45      call	#0x45fc <INT>
4684:  2152           add	#0x4, sp
4686:  0f43           clr	r15
4688:  3b41           pop	r11
468a:  3041           ret
468c <memset>                   ; r13 # of bytes to write, r14 value to write to each byte, r15 address to start writing at
468c:  0b12           push	r11
468e:  0a12           push	r10
4690:  0912           push	r9
4692:  0812           push	r8
4694:  0b4f           mov	r15, r11                ; r11 points to destination
4696:  3d90 0600      cmp	#0x6, r13
469a:  082c           jc	#0x46ac <memset+0x20>   ; if r13 <= 6
469c:  043c           jmp	#0x46a6 <memset+0x1a>   ; else
469e:  cb4e 0000      mov.b	r14, 0x0(r11)           ; write byte value to destination
46a2:  1b53           inc	r11                     ; increment destination
46a4:  3d53           add	#-0x1, r13              ; decrement byte count
46a6:  0d93           tst	r13
46a8:  fa23           jnz	#0x469e <memset+0x12>   ; if r13 != 0, continue
46aa:  1e3c           jmp	#0x46e8 <memset+0x5c>   ; if r13 == 0, return
46ac:  4a4e           mov.b	r14, r10
46ae:  0a93           tst	r10
46b0:  0324           jz	#0x46b8 <memset+0x2c>   ; if value to write is zero
46b2:  0c4a           mov	r10, r12
46b4:  8c10           swpb	r12                     ; swap upper and lower bytes of r12
46b6:  0adc           bis	r12, r10                ; r10 = r12 | r10 now r10 has the byte value to write in upper and lower byte
46b8:  1fb3           bit	#0x1, r15               ; test low bit of destination address
46ba:  0524           jz	#0x46c6 <memset+0x3a>   ; if address is even
46bc:  3d53           add	#-0x1, r13              ; decrement byte count
46be:  cf4e 0000      mov.b	r14, 0x0(r15)           ; write one byte to get to even address
46c2:  0b4f           mov	r15, r11
46c4:  1b53           inc	r11                     ; increment destination
46c6:  0c4d           mov	r13, r12                ; now that destination is even,
46c8:  12c3           clrc                          ; clear carry bit
46ca:  0c10           rrc	r12                     ; divide by 2
46cc:  084b           mov	r11, r8                 ; r8 is now destination
46ce:  094c           mov	r12, r9                 ; r9 is now number of words to write
46d0:  884a 0000      mov	r10, 0x0(r8)            ; write two bytes (as one word) to destination
46d4:  2853           incd	r8                      ; increment destination
46d6:  3953           add	#-0x1, r9               ; decrement word count
46d8:  fb23           jnz	#0x46d0 <memset+0x44>   ; while count > 0
46da:  0c5c           add	r12, r12                ; double r12 to get back to byte count
46dc:  0c5b           add	r11, r12                ;
46de:  1df3           and	#0x1, r13
46e0:  0d99           cmp	r9, r13
46e2:  0224           jeq	#0x46e8 <memset+0x5c>   ; if at end, return
46e4:  cc4e 0000      mov.b	r14, 0x0(r12)           ; else write one more byte
46e8:  3841           pop	r8                      ;
46ea:  3941           pop	r9
46ec:  3a41           pop	r10
46ee:  3b41           pop	r11
46f0:  3041           ret
46f2 <_unexpected_>
46f2:  0013           reti	pc
