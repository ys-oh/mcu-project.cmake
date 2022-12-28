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

################################################################
# stm32 cubemx project
################################################################

macro(mcu_project_stm core)
    STRING(TOLOWER ${core} core_)

    if ("${core_}" STREQUAL "f0")
        set (opt_cpu "-mcpu=cortex-m0")
        set (opt_fpu "")
    elseif ("${core_}" STREQUAL "g4")
        set (opt_cpu "-mcpu=cortex-m4")
        set (opt_fpu "-mfpu=fpv4-sp-d16 -mfloat-abi=hard")
    else()
        message (FATAL_ERROR "${core} is not supported in this project.")
    endif()

    find_program(C_BUILD arm-none-eabi-gcc)
    if (C_BUILD-NOTFOUND)
        message (FATAL_ERROR "compiler(arm-none-eabi-gcc) is not found.")
    endif()

    # default toolchain options
    set (CMAKE_SYSTEM_NAME Generic)
    set (CMAKE_SYSTEM_PROCESSOR arm)

    set (CMAKE_ASM_COMPILER         arm-none-eabi-gcc)
    set (CMAKE_C_COMPILER           arm-none-eabi-gcc)
    set (CMAKE_CXX_COMPILER         arm-none-eabi-g++)

    set (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    set (CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

    set (CMAKE_USER_MAKE_RULES_OVERRIDE_C)
    set (CMAKE_USER_MAKE_RULES_OVERRIDE_CXX)
    set (CMAKE_USER_MAKE_RULES_OVERRIDE_ASM)

    SET (CMAKE_C_OUTPUT_EXTENSION_REPLACE 1)
    SET (CMAKE_CXX_OUTPUT_EXTENSION_REPLACE 1)
    SET (CMAKE_ASM_OUTPUT_EXTENSION_REPLACE 1)

    # CMAKE_C_COMPILE_OBJECT
    set (CMAKE_C_COMPILER_WORKS 1)
    set (CMAKE_CXX_COMPILER_WORKS 1)
    set (CMAKE_ASM_COMPILER_WORKS 1)

    set (CMAKE_C_FLAGS  "${opt_cpu} -mthumb ${opt_fpu} -fdata-sections -ffunction-sections")
    set (CMAKE_CXX_FLAGS "${opt_cpu} -mthumb ${opt_fpu} -fdata-sections -ffunction-sections")
    set (CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs -lc -lm -lstdc++ -lsupc++ -Wl,--gc-sections,--print-memory-usage")
endmacro()

function(mcu_executable_stm target)
    add_executable(${target} ${ARGN})

    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND echo 'Finished building ${target}'
        COMMAND arm-none-eabi-size ${target}
        COMMAND arm-none-eabi-objdump -h -S ${target} > ${target}.list
        COMMAND arm-none-eabi-objcopy -O binary -S ${target} ${target}.bin
        COMMAND arm-none-eabi-objcopy -O ihex -S ${target} ${target}.hex
        # COMMAND arm-none-eabi-objcopy -O srec -S ${PROJECT_NAME}.elf ${PROJECT_NAME}.srec
    )
endfunction()

################################################################
# zephyr project functions & macros
################################################################
macro(mcu_project_zephyr)
    find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
endmacro()

function(mcu_executable_zephyr target)
    if ("${target}" STREQUAL "app")
        target_sources(${target} ${ARGN})
    else()
        add_library(${target})
        target_sources(${target} PRIVATE ${ARGN})
        target_link_libraries(app PRIVATE ${target})
    endif()
endfunction()

