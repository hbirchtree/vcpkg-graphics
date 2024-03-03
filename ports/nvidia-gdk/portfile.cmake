vcpkg_download_distfile(INSTALLER
    URLS http://developer.download.nvidia.com/compute/cuda/7.5/Prod/gdk/gdk_linux_amd64_352_79_release.run
    FILENAME nvidia-gdk.run
    SHA512 1f1d41c5b7bbc5ebc85a05e595d7fcd9e04fdcecece620c2e571eb83a38b5741965e2d5a0abe4fdd28c5e63fc6a4a3b82fe2f459fd2f33e38ad7b2025728a5c9
)

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/usr)
    execute_process(
        COMMAND chmod +x ${INSTALLER}
    )
    vcpkg_execute_required_process(
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "build-${TARGET_TRIPLET}"
        COMMAND ${INSTALLER} --silent --installdir=${CURRENT_BUILDTREES_DIR}
    )
endif()

file(INSTALL ${CURRENT_BUILDTREES_DIR}/usr/src/gdk/nvml/lib/libnvidia-ml.so DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/usr/src/gdk/nvml/lib/libnvidia-ml.so.1 DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/usr/include/nvidia DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
