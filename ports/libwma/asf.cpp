/* ASF data packet reader; see asf.h. Fresh C++20 implementation against the
 * public ASF specification (payload parsing per section 5.2). The interface
 * stays C so the C decoder sources can include asf.h.
 *
 * MIT licensed.
 */
#include "asf.h"

#include <cstring>
#include <optional>
#include <span>

namespace {

using bytes = std::span<const uint8_t>;

/* Cursor over one packet; reads fail sticky-false once out of bounds */
struct reader
{
    bytes  data;
    size_t pos{0};
    bool   ok{true};

    size_t remaining() const
    {
        return ok ? data.size() - pos : 0;
    }

    uint8_t u8()
    {
        if(remaining() < 1)
        {
            ok = false;
            return 0;
        }
        return data[pos++];
    }

    void skip(size_t n)
    {
        if(remaining() < n)
            ok = false;
        else
            pos += n;
    }

    /* ASF length-type field: 00 = absent, 01 = u8, 10 = u16le, 11 = u32le */
    uint32_t length_type(unsigned type)
    {
        static constexpr size_t sizes[4] = {0, 1, 2, 4};
        size_t                  n        = sizes[type & 3];
        if(remaining() < n)
        {
            ok = false;
            return 0;
        }
        uint32_t value = 0;
        for(size_t i = 0; i < n; i++)
            value |= uint32_t{data[pos + i]} << (8 * i);
        pos += n;
        return value;
    }
};

struct payload_header
{
    int      stream;
    bool     compressed; /* u8-length-prefixed sub-payloads follow */
    uint32_t length;
};

std::optional<payload_header> parse_payload_header(
    reader& r, uint8_t property_flags, bool multiple, unsigned payload_lt)
{
    payload_header out{};
    out.stream = r.u8() & 0x7F;
    r.length_type(property_flags >> 4); /* media object number */
    r.length_type(property_flags >> 2); /* offset into media object */
    uint32_t replicated = r.length_type(property_flags);

    out.compressed = replicated == 1;
    if(out.compressed)
        r.u8(); /* presentation time delta */
    else
        r.skip(replicated);

    if(multiple)
        out.length = r.length_type(payload_lt);
    else
        out.length = static_cast<uint32_t>(r.remaining());

    if(!r.ok || out.length > r.remaining())
        return std::nullopt;
    return out;
}

} // namespace

extern "C" int asf_read_packet(
    uint8_t**           audiobuf,
    int*                audiobufsize,
    int*                packetlength,
    asf_waveformatex_t* wfx,
    asf_io_t*           io)
{
    uint8_t* buf  = *audiobuf;
    auto     size = static_cast<size_t>(wfx->packet_size);

    *audiobufsize = 0;
    *packetlength = 0;

    if(!buf || size < 4)
        return ASF_ERROR_INTERNAL;
    if(io->fread(buf, 1, size, io->ctx) != size)
        return ASF_ERROR_EOF;
    *packetlength = static_cast<int>(size);

    reader r{.data = bytes(buf, size)};

    /* Optional error-correction prefix */
    if(buf[0] & 0x80)
    {
        if(buf[0] & 0x60) /* opaque/large EC data: not in media files */
            return ASF_ERROR_INVALID_VALUE;
        r.skip(1 + (buf[0] & 0x0F));
    }

    uint8_t length_flags   = r.u8();
    uint8_t property_flags = r.u8();
    bool    multiple       = length_flags & 0x01;

    r.length_type(length_flags >> 5); /* explicit packet length */
    r.length_type(length_flags >> 1); /* sequence, deprecated */
    uint32_t padding = r.length_type(length_flags >> 3);
    r.skip(6); /* send time (u32 ms) + duration (u16 ms) */

    if(!r.ok || padding > size - r.pos)
        return ASF_ERROR_INVALID_LENGTH;
    r.data = r.data.first(size - padding);

    unsigned payload_count = 1;
    unsigned payload_lt    = 0;
    if(multiple)
    {
        uint8_t flags = r.u8();
        payload_count = flags & 0x3F;
        payload_lt    = flags >> 6;
    }

    /* Gather this packet's payloads for the audio stream; they always sit
     * after the headers already consumed, so compacting toward the buffer
     * start never overtakes the read position */
    size_t out = 0;
    for(unsigned i = 0; r.ok && i < payload_count; i++)
    {
        auto payload =
            parse_payload_header(r, property_flags, multiple, payload_lt);
        if(!payload)
            return ASF_ERROR_INVALID_LENGTH;

        if(payload->stream == wfx->audiostream)
        {
            if(payload->compressed)
            {
                size_t end = r.pos + payload->length;
                while(r.pos < end)
                {
                    size_t sublen = r.u8();
                    if(sublen == 0 || !r.ok || r.pos + sublen > end)
                        return ASF_ERROR_INVALID_LENGTH;
                    std::memmove(buf + out, buf + r.pos, sublen);
                    out += sublen;
                    r.pos += sublen;
                }
            } else
            {
                std::memmove(buf + out, buf + r.pos, payload->length);
                out += payload->length;
                r.skip(payload->length);
            }
        } else
        {
            r.skip(payload->length);
        }
    }
    if(!r.ok)
        return ASF_ERROR_INVALID_LENGTH;

    *audiobufsize = static_cast<int>(out);
    return static_cast<int>(out);
}
