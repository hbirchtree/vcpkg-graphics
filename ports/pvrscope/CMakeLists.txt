cmake_minimum_required(VERSION 3.0)
project(pvrscope LANGUAGES C)

add_library(pvrscope STATIC INTERFACE)
set_property(TARGET pvrscope PROPERTY IMPORTED_LOCATION "lib/libPVRScopeDeveloper.a")

set(PVR_PREFIX "" STRING CACHE "")

install(
  TARGETS pvrscope
  EXPORT pvrscope
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(TARGETS pvrscope LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(
  FILES ${CMAKE_CURRENT_SOURCE_DIR}/lib/${PVR_PREFIX}/libPVRScopeDeveloper.a
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(
  FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/PVRScopeStats.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/pvrscopeConfigVersion.cmake
  VERSION 5.9
  COMPATIBILITY SameMinorVersion
)

export(
  EXPORT pvrscope
  FILE ${CMAKE_CURRENT_BINARY_DIR}/pvrscopeTargets.cmake
  NAMESPACE pvrscope::
)
install(EXPORT pvrscope DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pvrscope)
install(
  EXPORT pvrscope
  FILE pvrscopeTargets.cmake
  NAMESPACE pvrscope::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pvrscope
)
install(FILES pvrscopeConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/pvrscopeConfigVersion.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pvrscope
)
