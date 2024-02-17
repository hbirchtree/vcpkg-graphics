vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/powervr-graphics/Native_SDK/archive/R15.1-v3.5.tar.gz
    FILENAME pvrscope.tar.gz
    SHA512 751b9643f446c63cc36169c11c6ed9136ccd4829d36deae7916fbf30daafc0c2922231a2fe0fc08ba262b2e80e5a1cd622b460ca397f7daff54d7960d1dd1cff
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

set(SYS_DIR "")
set(ARCH_DIR "")
if(${VCPKG_CMAKE_SYSTEM_NAME} STREQUAL Linux)
    set(SYS_DIR Linux)
    if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
        set(ARCH_DIR x86_32)
    elseif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x64)
        set(ARCH_DIR x86_64)
    elseif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL arm)
        set(ARCH_DIR armv7hf)
    endif()
elseif(${VCPKG_CMAKE_SYSTEM_NAME} STREQUAL Android)
    set(SYS_DIR Android)
    if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL arm)
        set(ARCH_DIR armeabi-v7a)
    elseif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL arm64)
        set(ARCH_DIR arm64-v8a)
    endif()
endif()

if(${SYS_DIR} STREQUAL "")
    message(ERROR "Prefix not set for this target architecture")
endif()

# set(LIB_PREFIX "${SOURCE_PATH}/lib/${SYS_DIR}_${ARCH_DIR}")
# set(INC_PREFIX "${SOURCE_PATH}/include")
set(LIB_PREFIX "${SOURCE_PATH}/Builds/${SYS_DIR}/${ARCH_DIR}/Lib")
set(INC_PREFIX "${SOURCE_PATH}/Builds/Include")

# Install PowerVR emulation libraries if on x86/x86_64
if(${VCPKG_TARGET_ARCHITECTURE} MATCHES "x(86|64)")
    file(INSTALL ${LIB_PREFIX}/libEGL.so DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${LIB_PREFIX}/libGLESv2.so DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${LIB_PREFIX}/libGLES_CM.so DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()
file(INSTALL ${LIB_PREFIX}/libPVRScopeDeveloper.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${INC_PREFIX}/PVRScopeStats.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE_POWERVR_SDK.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
