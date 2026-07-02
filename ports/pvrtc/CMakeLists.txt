# Port-supplied build: upstream (harumazzz/pvrtc) only defines an INTERFACE
# include dir for in-tree use and no install() rules. Same sources, real
# PUBLIC include dir + install/export so vcpkg/find_package can consume it.
cmake_minimum_required(VERSION 3.20)
project(pvrtc VERSION 1.0.0 LANGUAGES CXX)

add_library(pvrtc STATIC
    Rgba32.cpp
    ColorRGBA.cpp
    ColorRGB.cpp
    Packet.cpp
    Morton.cpp
    Common.cpp
    Encode.cpp
    Decode.cpp
)

target_compile_features(pvrtc PRIVATE cxx_std_17)

target_include_directories(pvrtc
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/pvrtc>
)

install(TARGETS pvrtc EXPORT unofficial-pvrtc-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES
    Rgba32.h
    ColorRGB.h
    ColorRGBA.h
    Packet.h
    Morton.h
    Common.h
    Encode.h
    Decode.h
    DESTINATION include/pvrtc
)

install(EXPORT unofficial-pvrtc-targets
    NAMESPACE unofficial::pvrtc::
    DESTINATION share/unofficial-pvrtc
    FILE unofficial-pvrtc-config.cmake
)
