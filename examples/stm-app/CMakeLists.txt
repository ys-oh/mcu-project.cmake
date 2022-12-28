cmake_minimum_required(VERSION 3.20)

include (${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/mcu-project.cmake)
mcu_project_stm(m4)

project(stm-example)

mcu_executable_stm(stm-example)
target_sources(stm-example PRIVATE app.c)
