# Weekly Meeting 1

A general note. In the early email thread 3 strategies were outlined. So far my focus has been looking and working on the viability of the 3rd strategy. 

3) Generate C, and use a C-to-WebAssembly compiler

## Topics for Discussion
- Progress (Succesful compilation with Emscripten)
- Issues (Run Time issues with Multicore + Emscripten)
- Research Plan (WASM + WebGPU - Apache TVM)

## Progress

I have gotten the sequential C and multicore backend to compile with the Emscripten compiler with a few changes to the Futhark compiler.
The code is on this [branch](https://github.com/philass/futhark/tree/emcc-pass).

### Compiler changes
- Ignore asm volatile when compiled with Emscripten (WASM does not support this)
- Rewrite 64bit multiplication when compiled with Emscripten
- Add include statement when compiled with Emscripten 

I was able to run Futhark programs (Sequential C backend only!) with the following set of commands (using my branch)

```bash
futhark c program.fut
emcc program.c
node a.out.js < data.txt
```

## Issues

Though I was able to compile the Multicore backend with Emscripten after a few tweaks.
For the simplest Futhark program
```
let main = 1
```
I get the following error message when run `node a.out.js < data.txt`
```
operating system not recognised
Assertion failed: num_workers > 0, at: test.c,3987,scheduler_init
exception thrown: RuntimeError: abort(Assertion failed: num_workers > 0, at: test.c,3987,scheduler_init) at Error
    at jsStackTrace (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1950:17)
    at stackTrace (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1972:16)
    at abort (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1672:44)
    at ___assert_fail (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1978:7)
    at <anonymous>:wasm-function[47]:0x1e27
    at <anonymous>:wasm-function[39]:0x1655
    at _main (<anonymous>:wasm-function[36]:0xde3)
    at /Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1738:22
    at callMain (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5044:15)
    at doRun (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5106:23),RuntimeError: abort(Assertion failed: num_workers > 0, at: test.c,3987,scheduler_init) at Error
    at jsStackTrace (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1950:17)
    at stackTrace (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1972:16)
    at abort (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1672:44)
    at ___assert_fail (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1978:7)
    at <anonymous>:wasm-function[47]:0x1e27
    at <anonymous>:wasm-function[39]:0x1655
    at _main (<anonymous>:wasm-function[36]:0xde3)
    at /Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1738:22
    at callMain (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5044:15)
    at doRun (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5106:23)
    at abort (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1678:11)
    at ___assert_fail (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1978:7)
    at <anonymous>:wasm-function[47]:0x1e27
    at <anonymous>:wasm-function[39]:0x1655
    at _main (<anonymous>:wasm-function[36]:0xde3)
    at /Users/philiplassen/CS/thesis-log/emscripten/a.out.js:1738:22
    at callMain (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5044:15)
    at doRun (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5106:23)
    at run (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5121:5)
    at runCaller (/Users/philiplassen/CS/thesis-log/emscripten/a.out.js:5020:19)
```

This is something I am currently working on debugging.

This may be related to one of the changes I made to the compiler, which I mentioned earlier.

- Add include statement when compiled with Emscripten 

The altercation is funky as I imported sys/resource.h, which should already have been imported. However only worked when I specified inclusion with Emscripten compilation macro. This was also only relevant to the Multicore compilation, and had to do with rusage. I wonder if imports are being mangled, breaking multicore at runtime? 

## WebGPU + WASM

In looking at how WASM will call WebGPU, my investigation has centered around finding a relatively mature example project that uses WASM and WebGPU and uses them in conjuction. So far my focus has been on Apache TVM. Advertised as a compiler approach to deep learning, they provide a WebGPU/WASM backend. They detail their implementation in [here](https://tvm.apache.org/2020/05/14/compiling-machine-learning-to-webassembly-and-webgpu). I am still trying to wrap my head around the exact architecture of the project. 

The next steps I was going to take with this is to begin looking and understanding the following relevant code implementations from the project [TVM WASM/WebGPU](https://github.com/apache/incubator-tvm/tree/main/web).


## General Questions I would like to discuss.
- Is debugging the multicore compiled with Emscripten a good use of time?
- Does studying Apache TVM WebGPU/WASM implementation look like a promising use of time?
- What am I not doing that I should be doing?
