# Compiling Futhark to WASM

The preliminary experimentation for compiling Futhark programs to WASM is done on the sequential C backend. We start by trying to get the following futhark program `test_emcc.fut` to compile to WASM.

```futhark
let main = 1
```

Then we run

```bash
futhark c test_emcc.fut # Generates test_emcc.c
gcc test_emcc.c
```

When compiled with clang everything is hunky dory. However when we run it with the emscripten compiler, we run into some issues.

```bash
emcc test_emcc.c
```

```bash
test_emcc.c:225:34: error: invalid output constraint '=a' in asm
  __asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
                                 ^
test_emcc.c:2145:5: error: use of undeclared identifier '__uint128_t'
    __uint128_t aa = a;
    ^
test_emcc.c:2146:5: error: use of undeclared identifier '__uint128_t'
    __uint128_t bb = b;
    ^
test_emcc.c:2148:12: error: use of undeclared identifier 'aa'
    return aa * bb >> 64;
           ^
test_emcc.c:2148:17: error: use of undeclared identifier 'bb'
    return aa * bb >> 64;
                ^
5 errors generated.
```
There are two different issues. 

Firstly WASM does not support [__asm__ __volatile__](https://github.com/emscripten-core/emscripten/issues/6339)

Secondly WASM does not support [__uint128](https://github.com/emscripten-core/emscripten/issues/5630)
