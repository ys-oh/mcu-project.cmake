cmake_minimum_required(VERSION 3.16)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include (../../cmake/mcu-project.cmake)
mcu_project_esp(esp32)

project(esp-app)

mcu_executable_esp(esp-app app.cpp)