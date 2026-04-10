#include <stdlib.h>
#include <stdio.h>

#define samples 32
#define taps 16

/* Input signal: y[n] = sin(2*pi*4000*n/10000) + sin(2*pi*2000*n/10000)
   f1=4000Hz, f2=2000Hz, fs=10000Hz, N=32 samples (Section 2.2 Step 1) */
float input[samples] = {
    0.0000000000e+00f,  1.5388417686e+00f, -3.6327126400e-01f,  3.6327126400e-01f,
   -1.5388417686e+00f,  0.0000000000e+00f,  1.5388417686e+00f, -3.6327126400e-01f,
    3.6327126400e-01f, -1.5388417686e+00f,  0.0000000000e+00f,  1.5388417686e+00f,
   -3.6327126400e-01f,  3.6327126400e-01f, -1.5388417686e+00f,  0.0000000000e+00f,
    1.5388417686e+00f, -3.6327126400e-01f,  3.6327126400e-01f, -1.5388417686e+00f,
    0.0000000000e+00f,  1.5388417686e+00f, -3.6327126400e-01f,  3.6327126400e-01f,
   -1.5388417686e+00f,  0.0000000000e+00f,  1.5388417686e+00f, -3.6327126400e-01f,
    3.6327126400e-01f, -1.5388417686e+00f,  0.0000000000e+00f,  1.5388417686e+00f
};

float output[samples];

/* Bandpass FIR filter coefficients: 16 taps, fs=10000Hz, passband 1000-3000Hz
   Passes f2=2000Hz, rejects f1=4000Hz (Section 2.2 Step 2) */
float pm coefficients[taps] = {
    6.9657248924e-03f,  3.0082158460e-03f, -6.8925032823e-03f,  1.4434004436e-02f,
   -2.7431417681e-02f, -2.0113530627e-01f, -9.9277668082e-02f,  3.2323615798e-01f,
    3.2323615798e-01f, -9.9277668082e-02f, -2.0113530627e-01f, -2.7431417681e-02f,
    1.4434004436e-02f, -6.8925032823e-03f,  3.0082158460e-03f,  6.9657248924e-03f
};

float dm state[taps+1] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,
                           0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f};

main()
{
   float temp;

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

      for (j = taps-1; j > 1; j--)
         state[j+1] = state[j];
   }
    exit(0);
}

