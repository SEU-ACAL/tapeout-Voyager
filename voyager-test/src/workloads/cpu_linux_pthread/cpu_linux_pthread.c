#ifndef _GNU_SOURCE
	#define _GNU_SOURCE             /* See feature_test_macros(7) */
#endif
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdint.h>
#include <time.h>

#define BOOM_ID 0



int voyager_pthread_setaffinity(uint64_t phart_id){
	pthread_t thread_id = pthread_self();
	cpu_set_t cpu_id;
	int s;

	CPU_ZERO(&cpu_id);
	CPU_SET(phart_id, &cpu_id); 
	s = pthread_setaffinity_np(thread_id, sizeof(cpu_id), &cpu_id);
	
	return s;
} 

struct timespec start, end;
uint64_t csr_cycle[2];
uint64_t csr_instret[2];

/* Apply the constructor attribute to myStartupFun() so that it
     is executed before main() */
void gcStartup (void) __attribute__ ((constructor));


 /* Apply the destructor attribute to myCleanupFun() so that it
    is executed after main() */
void gcCleanup (void) __attribute__ ((destructor));
 
void gcStartup (void)
{
    // Bound current thread to BOOM
    if (voyager_pthread_setaffinity(BOOM_ID) != 0){
		printf ("[Boom-C%x]: Pthread_setaffinity failed.", BOOM_ID);
	} else{
		printf ("[Boom-C%x]: Initialised!\r\n", BOOM_ID);
	}

	clock_gettime(CLOCK_MONOTONIC_RAW, &start); // get start time
}
  
void gcCleanup (void)
{	

	clock_gettime(CLOCK_MONOTONIC_RAW, &end); // get end time
	double elapsed = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9; // calculate elapsed time in seconds
	

	printf("==== Execution time: %f seconds ==== \r\n", elapsed);
}