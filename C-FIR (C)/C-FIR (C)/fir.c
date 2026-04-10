#include <stdlib.h>
#include <stdio.h>

#define samples 10
#define taps 16

int input[samples] = {1,2,3,0,0,6,7,8,9,10};
int output[samples];
int pm coefficients[taps] = {3,0,0,5,0,8,0,3,0,0,0,0,0,0,0,0};
int dm state[taps+1]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

main()
{   	  
   int temp;   

   int i; 
   int j;
   int k;

   for (k = 0; k < samples; k++)
   {
      state[0] = input[k];

	  for (i = 0, temp = 0; i < taps; i++)
         temp += coefficients[i] * state[i];

		// compiler generated code for above loop:
		// lcntr=16, do(pc,_L$316001-1)until lce;
		// mrf=mrf+r2*r1 (SSI), r1=dm(i0,m6), r2=pm(i8,m14);
		// _L$316001:

      output[k] = temp;

      for (j = taps-1; j > taps; j--)
         state[j+1] = state[j];
   }
    exit(0);
}

