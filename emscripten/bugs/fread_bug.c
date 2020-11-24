#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  uint8_t buffer[10];
  int64_t num_elems_read = (int64_t)fread(buffer, 1, 10, stdin);
  if (num_elems_read != 10) {
    printf("Didn't get 10 elements read");
  }
  for (int i = 0; i < 10; i++) {
    printf("%d element is : %d\n", i, buffer[i]);
  }
  return 0;
  
}

  
