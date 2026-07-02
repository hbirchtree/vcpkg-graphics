/* FFT/MDCT lookup tables, computed at runtime instead of being shipped as
 * static data:
 *
 * - sincos_lookup0[2i], [2i+1] = round(sin, cos(i * pi/2048) * 2^31),
 *   clamped to INT32_MAX, for i = 0..512; sincos_lookup1 is the same at
 *   half-step offsets (i + 0.5).
 * - revtab is the split-radix FFT input permutation for N = 4096 (ffmpeg
 *   convention, inverse variant).
 *
 * With a correctly-rounded libm the sincos values are identical to the
 * classic pregenerated tables; a sloppy libm can differ by 1 LSB in Q1.31
 * (~ -186 dB), which is far below the decoder's own noise floor.
 *
 * MIT licensed.
 */
#include "mdct_lookup.h"

#include <math.h>

int32_t  sincos_lookup0[1026];
int32_t  sincos_lookup1[1024];
uint16_t revtab[1 << 12];

static int32_t q31(double v)
{
    double scaled = v * 2147483648.0; /* 2^31 */
    if(scaled >= 2147483647.0)
        return INT32_MAX;
    return (int32_t)floor(scaled + 0.5);
}

static int split_radix_permutation(int i, int n)
{
    if(n <= 2)
        return i & 1;
    int m = n >> 1;
    if(!(i & m))
        return split_radix_permutation(i, m) * 2;
    m >>= 1;
    /* inverse-transform variant */
    if(!(i & m))
        return split_radix_permutation(i, m) * 4 + 1;
    return split_radix_permutation(i, m) * 4 - 1;
}

void wma_tables_ensure(void)
{
    static volatile int done = 0;
    if(done)
        return;

    static const double step = 3.14159265358979323846 / 2048.0;
    for(int i = 0; i <= 512; i++)
    {
        sincos_lookup0[2 * i]     = q31(sin(i * step));
        sincos_lookup0[2 * i + 1] = q31(cos(i * step));
    }
    for(int i = 0; i < 512; i++)
    {
        sincos_lookup1[2 * i]     = q31(sin((i + 0.5) * step));
        sincos_lookup1[2 * i + 1] = q31(cos((i + 0.5) * step));
    }
    for(int i = 0; i < 4096; i++)
        revtab[-split_radix_permutation(i, 4096) & 4095] = (uint16_t)i;

    done = 1;
}
