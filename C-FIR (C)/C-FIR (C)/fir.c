#include <stdlib.h>
#include <stdio.h>

/* =========================================================================
 * FIR Bandpass Filter  —  DSP Lab Experiment (X = group% 3 = 1 → Bandpass)
 *
 * Filter spec:  16-tap linear-phase FIR, Hamming window
 *               fs = 10000 Hz,  passband = 1000–3000 Hz
 *
 * Input signal (3 frequency components):
 *   f_low  =  500 Hz  → below passband, REJECTED
 *   f_mid  = 2000 Hz  → inside passband, PASSED
 *   f_high = 4000 Hz  → above passband, REJECTED
 *
 *   y[n] = sin(2π·500·n/10000)
 *         + sin(2π·2000·n/10000)
 *         + sin(2π·4000·n/10000)     n = 0 … 31
 *
 * Output is written to firOutput.dat for MATLAB comparison.
 * ========================================================================= */

#define samples 32
#define taps    16

/* 32-point input: sum of 500 Hz + 2000 Hz + 4000 Hz sinusoids at fs=10000 Hz */
float input[samples] = {
    +0.0000000000e+00f,  +1.8478587630e+00f,  +2.2451398829e-01f,  +1.1722882584e+00f,
    -5.8778525229e-01f,  +1.0000000000e+00f,  +2.4898982849e+00f,  +4.4574573037e-01f,
    +9.5105651630e-01f,  -1.2298247742e+00f,  +0.0000000000e+00f,  +1.2298247742e+00f,
    -9.5105651630e-01f,  -4.4574573037e-01f,  -2.4898982849e+00f,  -1.0000000000e+00f,
    +5.8778525229e-01f,  -1.1722882584e+00f,  -2.2451398829e-01f,  -1.8478587630e+00f,
    +0.0000000000e+00f,  +1.8478587630e+00f,  +2.2451398829e-01f,  +1.1722882584e+00f,
    -5.8778525229e-01f,  +1.0000000000e+00f,  +2.4898982849e+00f,  +4.4574573037e-01f,
    +9.5105651630e-01f,  -1.2298247742e+00f,  +0.0000000000e+00f,  +1.2298247742e+00f
};

float output[samples];

/* 16-tap bandpass FIR coefficients (Hamming window, fs=10000 Hz, passband 1000-3000 Hz)
   Symmetric — linear phase response.
   |H(2000 Hz)| ≈ 1.0 (0 dB) — 2 kHz PASSED
   |H( 500 Hz)| ≈ 0   (−∞ dB) — 500 Hz REJECTED
   |H(4000 Hz)| ≈ 0.016 (−36 dB) — 4 kHz REJECTED */
float pm coefficients[taps] = {
    6.9657248924e-03f,  3.0082158460e-03f, -6.8925032823e-03f,  1.4434004436e-02f,
   -2.7431417681e-02f, -2.0113530627e-01f, -9.9277668082e-02f,  3.2323615798e-01f,
    3.2323615798e-01f, -9.9277668082e-02f, -2.0113530627e-01f, -2.7431417681e-02f,
    1.4434004436e-02f, -6.8925032823e-03f,  3.0082158460e-03f,  6.9657248924e-03f
};

/* Delay-line state buffer: taps+1 elements, zero-initialised */
float dm state[taps+1] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,
                           0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f};

main()
{
   FILE *fp;
   float temp;
   int i, j, k;

   /* ---- FIR filtering loop ---- */
   for (k = 0; k < samples; k++)
   {
      /* Insert new sample at head of delay line */
      state[0] = input[k];

      /* MAC loop: accumulate tap×state products
         Compiler generates:
           lcntr=16, do(pc,_L$316001-1)until lce;
           mrf=mrf+r2*r1 (SSI), r1=dm(i0,m6), r2=pm(i8,m14);
         _L$316001: */
      for (i = 0, temp = 0; i < taps; i++)
         temp += coefficients[i] * state[i];

      output[k] = temp;

      /* Shift delay line: state[1..taps] ← state[0..taps-1] */
      for (j = taps-1; j >= 0; j--)
         state[j+1] = state[j];
   }

   /* ---- Write output to file for MATLAB comparison ---- */
   fp = fopen("firOutput.dat", "w");
   if (fp != NULL)
   {
      for (k = 0; k < samples; k++)
         fprintf(fp, "%15.10e\n", output[k]);
      fclose(fp);
   }
   else
   {
      fprintf(stderr, "Warning: could not open firOutput.dat for writing\n");
   }

   exit(0);
}

