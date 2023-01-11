cmake_minimum_required(VERSION 3.20)

include (${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/mcu-project.cmake)
mcu_project_zephyr()

project(zephyr-example)

mcu_executable_zephyr(zephyr-example)
target_sources(zephyr-example PRIVATE app.c)
