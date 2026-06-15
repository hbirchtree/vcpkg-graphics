vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/powervr-graphics/Native_SDK/archive/R26.1-v5.16.tar.gz
    FILENAME pvrtcdec.tar.gz
    SHA512 3f452cd0b87566d42bf69fd12327f637e1371f87fa98a386b969ddedaa3cc5dad67dccda9ec589137c2532b2a8fcebc60b79e0a6d7c9d6b823fb37dc7fb421b1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/pvrtcdecConfig.cmake DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
