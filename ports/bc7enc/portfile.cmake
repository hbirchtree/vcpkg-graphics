vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/richgel999/bc7enc/archive/f66c2e489b07138f2673a2fb3d27c1aa1d565c48.tar.gz
    FILENAME bc7enc.tar.gz
    SHA512 981eb5d7cf91359f930882feb02c6cfc897723b80d77c97f07cd5ec8f3e2c82762b5fc3ac0b8dcfb3ca215fb158495105c08914c8614bd9f55f8b37f14ff5207
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/bc7encConfig.cmake DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
