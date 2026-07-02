# Port-supplied build for the libwma decoder + libasf packet reader living
# inside the deadbeef source tree; upstream only builds them as a deadbeef
# plugin.
cmake_minimum_required(VERSION 3.19)
project(libwma C CXX)

# Exports are marked explicitly with LIBWMA_API (see asf.h): the engine
# toolchains compile everything with -fvisibility=hidden
set(WMA_DIR plugins/wma)

add_library(wma SHARED
    ${WMA_DIR}/libasf/asf.cpp
    ${WMA_DIR}/libwma/ffmpeg_bitstream.c
    ${WMA_DIR}/libwma/fft-ffmpeg.c
    ${WMA_DIR}/libwma/mdct.c
    ${WMA_DIR}/libwma/mdct_lookup.c
    ${WMA_DIR}/libwma/wmadeci.c
    ${WMA_DIR}/libwma/wmafixed.c
)

target_compile_features(wma PRIVATE cxx_std_20)

set_target_properties(wma PROPERTIES
    VERSION 0.1.0
    SOVERSION 0
    WINDOWS_EXPORT_ALL_SYMBOLS ON
)

target_include_directories(wma
    PRIVATE ${WMA_DIR} ${WMA_DIR}/libwma
    INTERFACE $<INSTALL_INTERFACE:include>
)

include(CheckLibraryExists)
check_library_exists(m sin "" LIBWMA_HAVE_LIBM)
if(LIBWMA_HAVE_LIBM)
    target_link_libraries(wma PRIVATE m)
endif()

install(TARGETS wma EXPORT unofficial-libwma-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES
    ${WMA_DIR}/libwma/wmadec.h
    ${WMA_DIR}/libwma/types.h
    ${WMA_DIR}/libwma/ffmpeg_get_bits.h
    ${WMA_DIR}/libwma/ffmpeg_intreadwrite.h
    DESTINATION include/libwma
)
install(FILES ${WMA_DIR}/libasf/asf.h DESTINATION include/libasf)

install(EXPORT unofficial-libwma-targets
    NAMESPACE unofficial::libwma::
    DESTINATION share/unofficial-libwma
    FILE unofficial-libwma-config.cmake
)
