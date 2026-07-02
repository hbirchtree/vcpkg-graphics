vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harumazzz/pvrtc
    REF b34330e88691fc8441dbee332f5992effdb0a567 # committed on 2025-11-08
    SHA512 60c7f3f402cc9116ac019ed4f333bb030bc51e79d0cbe74be293874ae90c3c9b265e01a9cc11eed4b70038db23997d6cb45c3ee5b4daece9818997aa2d9095c4
    HEAD_REF master
)

# Upstream's CMakeLists.txt builds the static library with an INTERFACE-only
# include dir and no install() rules at all (in-tree-consumer only) -- replace
# it with a vcpkg-installable build (same source files, real install rules).
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-pvrtc)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
