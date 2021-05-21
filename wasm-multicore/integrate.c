#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>
#include <math.h>

#define NUM_THREADS 4
#define GRANULARITY 10000
static double interval;
static double sums[NUM_THREADS];

void *thread(void *ptr)
{
    
    int index = (int) ptr;
    double bottom = index * (interval / NUM_THREADS);
    double top = bottom + (interval / NUM_THREADS);
    double sum = 0;
    for (int i = 0; i < GRANULARITY;  i++) {
      double x = bottom + (top - bottom) / GRANULARITY * i;
      sum += sin(x);
    }
    sums[index] = sum / GRANULARITY;
    return  ptr;
}

int main(int argc, char **argv)
{
    // create the thread objs
//    if (argc != 2) {
//      exit(1);
//    }

//    interval = atof(argv[1]);
//   
    interval = 3.6;

    pthread_t workers[NUM_THREADS];
    for (long i = 0; i < NUM_THREADS; i++) {
      pthread_create(&workers[i], NULL, *thread, (void *) i);
    }
    // start the threads
    // wait for threads to finish
    for (long i = 0; i < NUM_THREADS; i++) {
      pthread_join(workers[i], NULL);
    }

    double result = 0;
    for (int i = 0; i < NUM_THREADS; i++) {
      result += sums[i];
    }
    printf("%f\n", result);

    return 0;
} 
