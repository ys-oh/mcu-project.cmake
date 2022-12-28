# CMake based MCU build system

Simple MCU project build system

Suppored MCU Frameworks
- [X] stm
- [X] zephyr
- [ ] esp-idf
- [ ] arduino
- [ ] mbedos

cmake mcu project apis
```cmake
# project apis
mcu_project_<platform>
mcu_executable_<platform>

# library apis
mcu_library
mcu_link_libraries
mcu_compile_definitions
```

examples
- [stm](./examples/stm-app/README.md)
- [zephyr](./examples/zephyr-app/README.md)


## Project API

mcu-project project apis

```cmake
mcu_project_<platform>(<platform-options ...>)
mcu_executable_<platform>(<target> <sources ...>)
```

- mcu_project_\<platform\> : top-level platform declare
- mcu_executable_\<platform\> : project add


Simple Example
```cmake
cmake_minimum_required(VERSION 3.20)

include (mcu-project)
mcu_project_zephyr()

project(myproject)

add_subdirectory(mylib)

mcu_executable_zephyr(myproject main.c)
target_link_library(myproject PUBLIC mylib)

```
## Library API

mcu-project component library apis

```
component layout

  ├── include
  │   └── <headers>
  ├── src
  │   └── <sources>
  ├── priv
  │   └── <private-sources>
  ├── tests
  │   └── <test-sources>
  └── CMakeLists.txt

apis
  mcu_library(<target> <sources ...>)
  mcu_link_libraries(<target> <link-targets ...>)
  mcu_compile_definitions(<target> <definitions ...>)

```

CMakeLists.txt (in component library folder)
```cmake
mcu_library(mylib src/mylib.c priv/mylib-priv.c)
```

