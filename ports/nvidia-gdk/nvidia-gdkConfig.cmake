get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" REALPATH BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

if(NOT TARGET nvidia-gdk::NVML)
    add_library(nvidia-gdk::NVML SHARED IMPORTED)
endif()
set_target_properties(nvidia-gdk::NVML
    PROPERTIES
        IMPORTED_LOCATION ${_IMPORT_PREFIX}/lib/libnvidia-ml.so
        IMPORTED_NO_SONAME FALSE
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
)

