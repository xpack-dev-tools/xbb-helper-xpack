# TIPS & TRICKS

```txt
error: too many arguments to function 'g'; expected 0, have 2
  321 |         (*g)(yy, dd);
      |         ~^~~ ~~
```

Add `-std=gnu17` to CFLAGS:

```c
CFLAGS="${XBB_CFLAGS_NO_W} -std=gnu17"
```
