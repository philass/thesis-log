# Progress

It seems I have actually gotten binary input to work. This was way more convoluted then I thought it would be at the onset. Its still quite possible that there is a solution that is far simpler but still what I've done seems to work. the code can be seen on the following [branch](https://github.com/philass/futhark/tree/wasm-command). Quite a few kinks that had to be worked out. Emscripten really butchers stdin and stdout for binary input. So I made two global streams for `temp.bin` and `out.bin`. The former is a copy of stdin, and the latter is to be copied to stdout at the end. This avoids the utf-8 butchering. 

## Running test suite

Running 
```bash
futhark test tests/ --backend=wasm --runner=node
```
Giving the following

![futhark test results](resources/futests.png)



# Issues

- Tuning seems like it might be a little difficult to implemement. 
- Some random errors reading both stdin and stdout (small percentage)

# Next Steps

Get to the bottom of the random failures...

