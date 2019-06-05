# Latest upstream package provides both CMake and autotools building.
# Unfortunately Linux distros and homebrew build the package with autotools,
# so they do not ship the CMake Config file, but only the pkg-config files.
# vcpkg and Conan do ship Config files.
# So try config files first, and then use the regular find_library / find_path dance with pkg-config
# paths as hints.

find_package(WebP QUIET)
if(TARGET WebP::webp AND TARGET WebP::webpdemux)
    set(WrapWebP_FOUND ON)
    add_library(WrapWebP::WrapWebP INTERFACE IMPORTED)
    target_link_libraries(WrapWebP::WrapWebP INTERFACE WebP::webp WebP::webpdemux)
    return()
endif()

find_package(PkgConfig)
pkg_check_modules(PC_WebP libwebp)
pkg_check_modules(PC_WebPDemux libwebpdemux)

find_library(WebP_LIBRARY NAMES "webp"
                          HINTS ${PC_WebP_LIBDIR})
find_library(WebP_demux_LIBRARY NAMES "webpdemux"
                                HINTS ${PC_WebPDemux_LIBDIR})

find_path(WebP_INCLUDE_DIR NAMES "webp/decode.h"
                                 HINTS ${PC_WebP_INCLUDEDIR})
find_path(WebP_demux_INCLUDE_DIR NAMES "webp/demux.h"
                                 HINTS ${PC_WebPDemux_INCLUDEDIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(WebP DEFAULT_MSG WebP_INCLUDE_DIR WebP_LIBRARY
                                                   WebP_demux_INCLUDE_DIR WebP_demux_LIBRARY)

mark_as_advanced(WebP_INCLUDE_DIR WebP_LIBRARY WebP_INCLUDE_DIR WebP_demux_LIBRARY)
if(WebP_FOUND)
    set(WrapWebP_FOUND ON)
    add_library(WrapWebP::WrapWebP INTERFACE IMPORTED)
    target_link_libraries(WrapWebP::WrapWebP INTERFACE ${WebP_LIBRARY} ${WebP_demux_LIBRARY})
    target_include_directories(WrapWebP::WrapWebP
                               INTERFACE ${WebP_INCLUDE_DIR} ${WebP_demux_INCLUDE_DIR})
endif()
