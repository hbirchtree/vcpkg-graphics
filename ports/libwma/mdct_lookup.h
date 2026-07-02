/* FFT/MDCT lookup tables, computed at runtime from libm (see
 * mdct_lookup.c). Call wma_tables_ensure() before use; wma_decode_init
 * does this. MIT licensed.
 */
#ifndef LIBWMA_MDCT_LOOKUP_H
#define LIBWMA_MDCT_LOOKUP_H

#include <stdint.h>

#include <libasf/asf.h> /* LIBWMA_API */

#ifdef __cplusplus
extern "C" {
#endif

extern LIBWMA_API int32_t  sincos_lookup0[1026];
extern LIBWMA_API int32_t  sincos_lookup1[1024];
extern LIBWMA_API uint16_t revtab[1 << 12];

LIBWMA_API void wma_tables_ensure(void);

#ifdef __cplusplus
}
#endif

#endif
