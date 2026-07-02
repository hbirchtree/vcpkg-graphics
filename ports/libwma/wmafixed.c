/* Fixed-point helpers for the WMA decoder: Q16.16 conversions and division,
 * bit-by-bit integer square root, and libm-backed sine/cosine (the decoder
 * only calls fsincos during init, so double-precision sin/cos costs nothing
 * and beats the ~24-bit CORDIC it replaces).
 *
 * MIT licensed.
 */
#include "wmafixed.h"

#include <math.h>

fixed64 IntTo64(int x)
{
    return (fixed64)x << PRECISION64;
}

int IntFrom64(fixed64 x)
{
    return (int)(x >> PRECISION64);
}

fixed32 Fixed32From64(fixed64 x)
{
    return (fixed32)x;
}

fixed64 Fixed32To64(fixed32 x)
{
    return (fixed64)x;
}

fixed32 fixdiv32(fixed32 x, fixed32 y)
{
    if(x == 0)
        return 0;
    if(y == 0)
        return 0x7fffffff;
    return (fixed32)(((fixed64)x << PRECISION) / y);
}

fixed64 fixdiv64(fixed64 x, fixed64 y)
{
    if(x == 0)
        return 0;
    if(y == 0)
        return 0x07ffffffffffffffLL;
    return (x << PRECISION64) / y;
}

/* Classic digit-by-digit square root on the Q16.16 integer, yielding
 * floor(sqrt(v)) << 8, i.e. the Q16.16 root */
fixed32 fixsqrt32(fixed32 x)
{
    unsigned long v = (unsigned long)x;
    unsigned long r = 0;

    for(int k = 15; k >= 0; k--)
    {
        unsigned long s = r + (1UL << (k * 2));
        r >>= 1;
        if(s <= v)
        {
            v -= s;
            r |= 1UL << (k * 2);
        }
    }

    return (fixed32)(r << (PRECISION / 2));
}

/* phase maps [0, 2^32) to [0, 2*pi); returns sin and writes cos in Q1.31,
 * saturated one LSB under +-1.0 like the CORDIC version it replaces */
long fsincos(unsigned long phase, fixed32* cos_out)
{
    double angle = (double)phase * (2.0 * 3.14159265358979323846 / 4294967296.0);

    double s = sin(angle) * 2147483648.0;
    double c = cos(angle) * 2147483648.0;

    if(cos_out)
        *cos_out = c >= 2147483647.0   ? 0x7fffffff
                   : c <= -2147483648.0 ? (fixed32)0x80000000
                                        : (fixed32)floor(c + 0.5);

    return s >= 2147483647.0   ? 0x7fffffff
           : s <= -2147483648.0 ? (long)(fixed32)0x80000000
                                : (long)floor(s + 0.5);
}
