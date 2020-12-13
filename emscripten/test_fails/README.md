This is what causes the issue in slice1.fut

```c
printf("%lld %lld %lld %lld\n", n_4105, i32_res_4118, i32_res_4119, m_4106);
ctx->error =
    msgprintf("Error: %s%lld%s%lld%s%lld%s%lld%s%lld%s%lld%s\n\nBacktrace:\n%s",
              "Index [", 0, ":", n_4105, ", ", i32_res_4118, ":", 
              i32_res_4119, "] out of bounds for array of shape [",
              n_4105, "][", m_4106, "].",
              "-> #0  slice1.fut:14:3-29\n   #1  slice1.fut:13:1-14:29\n");
```


Specifically the line 
```
"Index [", 0, ":", n_4105, ", ", i32_res_4118, ":", 
```
The `0` Actually needs to be `0LL`. This is because when it reads an int literal it tries to read 8 bytes, when there are only 4bytes, based on WASM's 32bit default. 
