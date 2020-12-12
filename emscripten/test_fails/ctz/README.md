# Test Failures

Seems that this has to do with big numbers. The test that breaks things is listed below

```futhark
-- ==
-- entry: ctzi64
-- input { [0i64, 18446744073709551615i64, 9223372036854775808i64] } output { [64, 0, 63] }
```

A simple experiment. We create the following `test.fut` file.

```futhark
let main (xs : []i64) = xs
```
With the following `test.txt` (The same dataset as the test that breaks)
```
[0i64, 18446744073709551615i64, 9223372036854775808i64]
```
Running it gives the following
```
futhark wasm test.fut 
node test < test.txt
# gives
[0i64, -1i64, -9223372036854775808i64]
```
That seemns to be a problem...



