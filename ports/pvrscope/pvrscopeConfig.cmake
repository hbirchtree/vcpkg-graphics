get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" REALPATH BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

if(NOT TARGET pvrscope::PVRScopeDeveloper)
    add_library(pvrscope::PVRScopeDeveloper STATIC IMPORTED)
endif()
if(EXISTS ${_IMPORT_PREFIX}/lib/libGLESv2.so)
    set(LINK_LIBRARIES 
        ${_IMPORT_PREFIX}/lib/libEGL.so
        ${_IMPORT_PREFIX}/lib/libGLESv2.so
        ${_IMPORT_PREFIX}/lib/libGLES_CM.so
    )
endif()
set_target_properties(pvrscope::PVRScopeDeveloper
    PROPERTIES
        IMPORTED_LOCATION ${_IMPORT_PREFIX}/lib/libPVRScopeDeveloper.a
        INTERFACE_LINK_LIBRARIES "${LINK_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
)

