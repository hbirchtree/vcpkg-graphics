/* Fixed-point helpers for the WMA decoder.
 *
 * Clean reimplementation of the interface the decoder expects (originally
 * from Rockbox); plain C only, no per-CPU assembly. The decoder works in two
 * fixed-point precisions: Q16.16 ("fixed32"/"fixed64") for most math, and
 * Q1.31 for MDCT coefficients (see fixmul32b in mdct.h).
 *
 * MIT licensed.
 */
#ifndef LIBWMA_WMAFIXED_H
#define LIBWMA_WMAFIXED_H

#include "types.h"
#include "mdct.h"

#define PRECISION   16
#define PRECISION64 16

#define fixtof64(x) ((float)(x) / (float)(1 << PRECISION64))
#define ftofix32(x) \
    ((fixed32)((x) * (float)(1 << PRECISION) + ((x) < 0 ? -0.5 : 0.5)))
#define itofix64(x) (IntTo64(x))
#define itofix32(x) ((x) << PRECISION)
#define fixtoi32(x) ((x) >> PRECISION)
#define fixtoi64(x) (IntFrom64(x))

fixed64 IntTo64(int x);
int     IntFrom64(fixed64 x);
fixed32 Fixed32From64(fixed64 x);
fixed64 Fixed32To64(fixed32 x);
fixed32 fixdiv32(fixed32 x, fixed32 y);
fixed64 fixdiv64(fixed64 x, fixed64 y);
fixed32 fixsqrt32(fixed32 x);
/*!
 * CORDIC sine/cosine. phase maps [0, 0xffffffff] to [0, 2*pi); returns sin
 * and writes cos, both Q1.31.
 */
long fsincos(unsigned long phase, fixed32* cos);

static inline fixed32 fixmul32(fixed32 x, fixed32 y)
{
    return (fixed32)(((fixed64)x * y) >> PRECISION);
}

static inline void vector_fmul_add_add(
    fixed32* dst, const fixed32* src0, const fixed32* src1, int len)
{
    for(int i = 0; i < len; i++)
        dst[i] += fixmul32b(src0[i], src1[i]);
}

static inline void vector_fmul_reverse(
    fixed32* dst, const fixed32* src0, const fixed32* src1, int len)
{
    for(int i = 0; i < len; i++)
        dst[i] = fixmul32b(src0[i], src1[len - 1 - i]);
}

#endif
