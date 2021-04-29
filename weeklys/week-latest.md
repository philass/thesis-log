# Status Report

I made a big break through which had stalled my progress for weeks. There was an almost undocumented flag, that needed to be passed into the compiler for 64 bit numbers to be handled correctly. This meant that when data was copied into the emscripten heap, the dimension arguments would corrupt the memory on the heap. I just wanted to add this because, it felt like such an accomplishment when I found the compiler flag 1000 deep in a settings source file.

With this breakthrough, the WASM backend with the server implementation is almost completely functional.

## Missing parts
- Implementation for opaque types
- Error Handling
- Running tests concurrently


I was able to pass all the tests in the examples directory (except 1) that didn't include Opaque return types

```
futhark test . --backend=wasm --runner=node --concurrency=1
```
Gives
```
┌──────────┬────────┬────────┬───────────┐
│          │ passed │ failed │ remaining │
├──────────┼────────┼────────┼───────────┤
│ programs │ 34     │ 1      │ 0/35      │
├──────────┼────────┼────────┼───────────┤
│ runs     │ 56     │ 1      │ 0/57      │
└──────────┴────────┴────────┴───────────┘
```


## Questions

How should I go about handling errors?
Any quick tips for concurrency issues when running tests

# Small issue

One of the tests didn't free a variable correctly. Here is the program run in debug mode. 

```
Now testing: rosettacode/filter.fut
<<< %%% OK
>>> outputs main
<<< []i32
<<< %%% OK
>>> inputs main
<<< []i32
<<< %%% OK
>>> restore /private/var/folders/3n/crzyvnhn3zb41jwbjzfm6tm40000gn/T/futhark-input19865-1 in0 []i32
<<< %%% OK
>>> call main out0 in0
<<< %%% OK
>>> free in0
<<< %%% OK
>>> store /private/var/folders/3n/crzyvnhn3zb41jwbjzfm6tm40000gn/T/futhark-output19865-2 out0
<<< %%% OK
>>> free out0
<<< %%% OK
>>> restore /private/var/folders/3n/crzyvnhn3zb41jwbjzfm6tm40000gn/T/futhark-input19865-3 in0 []i32
<<< %%% OK
>>> call main out0 in0
<<< %%% OK
>>> free in0
<<< %%% OK
>>> store /private/var/folders/3n/crzyvnhn3zb41jwbjzfm6tm40000gn/T/futhark-output19865-4 out0
<<< %%% OK
>>> restore /private/var/folders/3n/crzyvnhn3zb41jwbjzfm6tm40000gn/T/futhark-input19865-5 in0 []i32
<<< %%% OK
>>> call main out0 in0
<<< %%% FAILURE
<<< Variable already exists: out0
```

# Logistics

With regards to the due date of the thesis. My thesis is due on the 15th of June. Quoting from the DIKU website...
```The starting date for the second contract is the day after the first contract expired.```
There is still some logistics I have to complete, namely resubmitting a new updated problem statement. I will take care of this within the week. And I will keep you out of this process as much as I can.
