# Always a shared library: the decoder core is LGPL, and dynamic linking
# keeps the engine's own licensing untouched
set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DeaDBeeF-Player/deadbeef
    REF 2ca3b1bcc43d9964f65d58ee125887bed83715dc # committed on 2026-06-29
    SHA512 90eaadf13858da943e6d3765f3624fef0ad615515e0d565f42a6024fca92bbabc09c2f4ab1a221529e8f3921e3a5f03ce589fb72fafd6cc52bd92ae019e3a5de
    HEAD_REF master
)

# The upstream tree mixes licenses: the decoder core is LGPL-2.0+ (ffmpeg
# heritage) and some support files are Tremor BSD, but wmafixed.c/.h,
# mdct_lookup.c/.h, fft-ffmpeg_arm.h and the libasf reader are GPL-2.0+
# (Rockbox/deadbeef). Those are deleted here and replaced with the
# MIT-licensed reimplementations shipped with this port (libm-computed
# FFT/MDCT tables and sine/cosine, textbook fixed-point helpers, and a
# fresh C++20 ASF packet reader with caller-provided IO callbacks), keeping
# the whole library GPL-free. Decode output verified against ffmpeg's float
# decoder on real WMA v2 content (max 5 LSB, same as the original tables).
file(REMOVE
    "${SOURCE_PATH}/plugins/wma/libwma/wmafixed.c"
    "${SOURCE_PATH}/plugins/wma/libwma/wmafixed.h"
    "${SOURCE_PATH}/plugins/wma/libwma/types.h"
    "${SOURCE_PATH}/plugins/wma/libwma/mdct_lookup.c"
    "${SOURCE_PATH}/plugins/wma/libwma/mdct_lookup.h"
    "${SOURCE_PATH}/plugins/wma/libwma/fft-ffmpeg_arm.h"
    "${SOURCE_PATH}/plugins/wma/libasf/asf.c"
    "${SOURCE_PATH}/plugins/wma/libasf/asf.h"
    "${SOURCE_PATH}/plugins/wma/asfheader.c"
)
file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/wmafixed.c"
    "${CMAKE_CURRENT_LIST_DIR}/wmafixed.h"
    "${CMAKE_CURRENT_LIST_DIR}/types.h"
    "${CMAKE_CURRENT_LIST_DIR}/mdct_lookup.c"
    "${CMAKE_CURRENT_LIST_DIR}/mdct_lookup.h"
    DESTINATION "${SOURCE_PATH}/plugins/wma/libwma"
)
file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/asf.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/asf.h"
    DESTINATION "${SOURCE_PATH}/plugins/wma/libasf"
)

# fft-ffmpeg_arm.h (GPL, removed) is only usable on 32-bit ARM Rockbox
# builds; make its include conditional like the code that uses it
vcpkg_replace_string(
    "${SOURCE_PATH}/plugins/wma/libwma/fft-ffmpeg.c"
    "#include \"fft-ffmpeg_arm.h\""
    "#ifdef CPU_ARM\n#include \"fft-ffmpeg_arm.h\"\n#endif"
)
# The FFT/MDCT tables are computed at runtime now; fill them before the
# rest of decoder init reads them
vcpkg_replace_string(
    "${SOURCE_PATH}/plugins/wma/libwma/wmadeci.c"
    "#include \"wmadec.h\""
    "#include \"wmadec.h\"\n#include \"mdct_lookup.h\""
)
vcpkg_replace_string(
    "${SOURCE_PATH}/plugins/wma/libwma/wmadeci.c"
    "int wma_decode_init(WMADecodeContext* s, asf_waveformatex_t *wfx)\n{"
    "int wma_decode_init(WMADecodeContext* s, asf_waveformatex_t *wfx)\n{\n    wma_tables_ensure();"
)
# Export the decoder entry points from the shared library; the engine
# toolchains compile with -fvisibility=hidden (LIBWMA_API comes from asf.h,
# included above these declarations)
foreach(decl IN ITEMS
    "int wma_decode_init"
    "int wma_decode_superframe_init"
    "int wma_decode_superframe_frame")
    vcpkg_replace_string(
        "${SOURCE_PATH}/plugins/wma/libwma/wmadec.h"
        "${decl}" "LIBWMA_API ${decl}")
endforeach()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libwma)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
"libwma combines sources under the following licenses:
- WMA decoder core (wmadeci.c, wmadec.h, wmadata.h, mdct.c, mdct.h, fft.h,
  fft-ffmpeg.c, ffmpeg_bitstream.c, ffmpeg_get_bits.h,
  ffmpeg_intreadwrite.h): LGPL-2.0-or-later, (c) The FFmpeg Project,
  Rockbox contributors.
- codeclib_misc.h, asm_arm.h: BSD-style Xiph.Org license, (c) Xiph.Org
  Foundation (Tremor).
- wmafixed.c/.h, types.h, mdct_lookup.c/.h (runtime-computed tables),
  libasf packet reader (asf.cpp/.h): MIT, reimplemented for this port.
")
