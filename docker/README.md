# Docker
Here are some commands for running useful docker setups.


## Valgrind

For debugging some C its useful to have valgrind. This is not readily available on MACOS. Here is the docker command for it.
```
docker run -t -i -v `pwd`:`pwd` -w `pwd` messeb/valgrind /bin/bash
```
This also mounts the file system. So we can run the following if we had `test.c` if we had it in our local directory.
```
cc -g -O3 -fsanitize=address test.c
```
