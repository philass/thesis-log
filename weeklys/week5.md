 # Progress

Got the whole Futhark test suite to pass. Interesting to think that basically all the issues came down to 32bit and 64 bit compatibility issues, and utf8 decoding. As always my code can be seen on this [branch](https://github.com/diku-dk/futhark/tree/wasm).

# In progress

So far my work has centered around, getting the test suite to pass. As discussed before, in practice WASM will be used as a library. I am currently working on making a demo application in this [repo](https://github.com/philass/WebHark). Hopefully it will be done before our meeting tommorow. Working on this, brought to my intention how unintuitive, using the library by itself is. This is mainly because Javascript/WASM doesn't have a simple way to work with pointers, arrays, and structs. 

Its possible that providing a wrappers/runtime with the C library may be essential for making it practical to work with the WASM backend as a library.


I personally the Python backends have a very nice API, and would like to model the Javascript API after that. Would really like input on this.

# Next Steps

I would really love to move past the WASM-C backend and onto the next thing. But I really do think hammering out an elegent API/runtime for the WASM --library, will be essential for any WASM backend to be usable. 
