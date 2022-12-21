#
# mcu-project component library apis 
#
# component layout
# 
#   ├── include
#   │   └── <headers>
#   ├── src
#   │   └── <sources>
#   ├── priv
#   │   └── <private-sources>
#   ├── tests
#   │   └── <test-sources>
#   └── CMakeLists.txt
#
# function & macros
#
#   mcu_interface_library(<target> <sources ...>)
#   mcu_library(<target> <sources ...>)
#   mcu_link_libraries(<target> <link-targets ...>)
#   mcu_compile_definitions(<target> <definitions ...>)
#

# mcu_interface_library(<target> <sources ...>)
function(mcu_interface_library target)
    add_library(${target} INTERFACE)
    target_include_directories(${target} INTERFACE include .)
    target_sources(${target} INTERFACE ${ARGN})
endfunction()

# mcu_static_library(<target> <sources ...>)
function(mcu_static_library target)
    add_library(${target} STATIC)
    target_include_directories(${target} PUBLIC include . PRIVATE priv)
    target_sources(${target} PRIVATE ${ARGN})
endfunction()

# mcu_library(<target> <sources ...>)
macro(mcu_library target)
    if(NOT "${ARGN}" STREQUAL "")
        mcu_static_library(${target} ${ARGN})
    else()
        mcu_interface_library(${target} ${ARGN})
    endif()
endmacro()

# mcu_link_libraries(<target> <link-targets ...>)
function(mcu_link_libraries target)
    get_property(is_interface TARGET ${target} PROPERTY TYPE)

    if(${is_interface} STREQUAL "INTERFACE_LIBRARY")
        target_link_libraries(${target} INTERFACE ${ARGN})
    else()
        target_link_libraries(${target} PUBLIC ${ARGN})
    endif()
endfunction()

function (mcu_compile_definitions target)
    get_property(is_interface TARGET ${target} PROPERTY TYPE)

    if(${is_interface} STREQUAL "INTERFACE_LIBRARY")
        target_compile_definitions(${target} INTERFACE ${ARGN})
    else()
        target_compile_definitions(${target} PUBLIC ${ARGN})
    endif()
endfunction()

include (FetchContent)

FetchContent_Declare(
    unitytest
    GIT_REPOSITORY      https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG             v2.5.2 
)

# FetchContent_MakeAvailable(unitytest myCompanyIcons)
FetchContent_GetProperties(unitytest)
if(NOT unitytest_POPULATED)
    # Fetch the content using previously declared details
    FetchContent_Populate(unitytest)

    option (UNITY_EXTENSION_FIXTURE ON CACHE)
    set (UNITY_EXTENSION_FIXTURE ON)
    
    # Bring the populated content into the build
    add_subdirectory(${unitytest_SOURCE_DIR})
endif()

function (mcu_add_test target test_name)
    add_executable(${target}-${test_name} ${ARGN})
    target_link_libraries(${target}-${test_name} PUBLIC ${target} unity::framework)
    add_test(NAME ${target}-${test_name} COMMAND ${target}-${test_name})
endfunction()
