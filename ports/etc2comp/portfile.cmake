vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/etc2comp
    REF 39422c1aa2f4889d636db5790af1d0be6ff3a226
    SHA512 88dfccc41e8abc1a22e716e6b06e3fa7116ec636c8a543f0048fe35c8597fec9ca2146f6e3f00e29756ef6ddc73d35e6a2aeef0417836ecae44c139f16dc63dd
    HEAD_REF main
    PATCHES
        omit-etctool.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME etc2comp CONFIG_PATH share/etc2comp )

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
