# Progress

I was able to add a WASM command to futhark pretty seamlessly. The tip that I could use `--runner=node` probably saved me many hours. Here is a link to the latest [code](https://github.com/philass/futhark/tree/wasm-command).
95% of The tests passed (Not using test with binary flag). 

Tests that still fail generally fit into the following categories
- WASM doesn't have enough memory
- Negative tests (exceptions or meant to fail)
- Struggle reading input

# Issues

The biggest issue that I ran into was the fact that it seems there is an issue in the emscripten compiler. This pertained to binary input being read incorrectly. I filed an issue, which goes into more detail here.

[Emscripten Bug](https://github.com/emscripten-core/emscripten/issues/12867)

This probably means that I shouldn't merge the WASM command to futhark for a while, much to my dissapointment.

Finding the exact issue and pinpointing ended up being a huge time sink. I was writing an email at 5am to you on Tuesday morning defeated. But I thought maybe I'll take
one last pass at trying to get the test suite to run. I realized I could simply remove the `-b` flag from configExtraOptions. I felt like a real idiot after that one.


# Disccusion Questions

- Should I make my own implementation of fread for bytes or just ignore? / Should i make a PR to Emscripten
- What should I do next?
