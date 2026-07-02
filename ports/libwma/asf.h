/* Minimal ASF stream types + packet reader for feeding the WMA decoder.
 * Fresh implementation against the public ASF specification; IO goes through
 * caller-provided callbacks so the source can be a file, memory, or anything
 * else.
 *
 * MIT licensed.
 */
#ifndef LIBASF_ASF_H
#define LIBASF_ASF_H

#include <inttypes.h>
#include <stddef.h>

/* Explicit export marker: the engine toolchains compile with
 * -fvisibility=hidden, and this is a shared library */
#if defined(_WIN32)
#define LIBWMA_API
#else
#define LIBWMA_API __attribute__((visibility("default")))
#endif

/* ASF codec IDs (WAVEFORMATEX wFormatTag values) */
#define ASF_CODEC_ID_WMAV1    0x160
#define ASF_CODEC_ID_WMAV2    0x161
#define ASF_CODEC_ID_WMAPRO   0x162
#define ASF_CODEC_ID_WMAVOICE 0x00A

enum asf_error_e
{
    ASF_ERROR_INTERNAL       = -1, /* incorrect input to API calls */
    ASF_ERROR_OUTOFMEM       = -2,
    ASF_ERROR_EOF            = -3,
    ASF_ERROR_IO             = -4,
    ASF_ERROR_INVALID_LENGTH = -5,
    ASF_ERROR_INVALID_VALUE  = -6,
    ASF_ERROR_INVALID_OBJECT = -7,
    ASF_ERROR_OBJECT_SIZE    = -8,
    ASF_ERROR_SEEKABLE       = -9,
    ASF_ERROR_SEEK           = -10,
    ASF_ERROR_ENCRYPTED      = -11
};

/*!
 * Audio stream description, filled by the caller from the ASF header
 * objects (File Properties for packet_size, the audio Stream Properties'
 * WAVEFORMATEX for the rest).
 */
struct asf_waveformatex_s
{
    uint32_t packet_size;
    uint32_t max_packet_size;
    int      audiostream; /*!< stream number of the audio stream to read */
    uint16_t codec_id;
    uint16_t channels;
    uint32_t rate;
    uint32_t bitrate;
    uint16_t blockalign;
    uint16_t bitspersample;
    uint16_t datalen;
    uint64_t numpackets;
    uint8_t  data[46]; /*!< codec-specific data trailing WAVEFORMATEX */
    uint64_t play_duration;
    uint64_t send_duration;
    uint64_t preroll;
    uint32_t flags;
    int32_t  first_frame_timestamp;
};
typedef struct asf_waveformatex_s asf_waveformatex_t;

/*!
 * IO callbacks with stdio semantics: fread returns items read, fseek
 * returns 0 on success, whence is SEEK_SET/CUR/END.
 */
typedef struct asf_io_s
{
    size_t  (*fread)(void* ptr, size_t size, size_t nmemb, void* ctx);
    int     (*fseek)(void* ctx, int64_t offset, int whence);
    int64_t (*ftell)(void* ctx);
    int64_t (*fgetlength)(void* ctx);
    void*   ctx;
} asf_io_t;

#ifdef __cplusplus
extern "C" {
#endif

/*!
 * Reads the next data packet from the current position and gathers the
 * payloads of wfx->audiostream into *audiobuf.
 *
 * On entry *audiobuf must point to caller storage of at least
 * wfx->packet_size bytes; on success it is updated to the start of the
 * audio data and *audiobufsize to its length. *packetlength receives the
 * remaining on-disk packet size, so the caller can skip to the next packet
 * regardless of the return value.
 *
 * Returns the number of audio bytes gathered, 0 if the packet holds no
 * audio payloads, or a negative asf_error_e value.
 */
LIBWMA_API int asf_read_packet(
    uint8_t**           audiobuf,
    int*                audiobufsize,
    int*                packetlength,
    asf_waveformatex_t* wfx,
    asf_io_t*           io);

#ifdef __cplusplus
}
#endif

#endif
