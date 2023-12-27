cmake_minimum_required(VERSION 3.0)
project(bc7enc LANGUAGES C CXX)

add_library(bc7enc STATIC)

target_sources(
  bc7enc
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/bc7decomp.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/bc7enc.c
)

install(
  TARGETS bc7enc
  EXPORT bc7enc
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(TARGETS bc7enc LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(
  FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/bc7decomp.h
    ${CMAKE_CURRENT_SOURCE_DIR}/bc7enc.h
    ${CMAKE_CURRENT_SOURCE_DIR}/rgbcx.h
    ${CMAKE_CURRENT_SOURCE_DIR}/rgbcx_table4.h
  DESTINATION ${CMAKE_INSTALL_PREFIX}/include/bc7enc
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/bc7encConfigVersion.cmake
  VERSION 1.0
  COMPATIBILITY SameMinorVersion
)

export(
  EXPORT bc7enc
  FILE ${CMAKE_CURRENT_BINARY_DIR}/bc7encTargets.cmake
  NAMESPACE bc7enc::
)
install(EXPORT bc7enc DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/bc7enc)
install(
  EXPORT bc7enc
  FILE bc7encTargets.cmake
  NAMESPACE bc7enc::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/bc7enc
)
install(FILES bc7encConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/bc7encConfigVersion.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/bc7enc
)
