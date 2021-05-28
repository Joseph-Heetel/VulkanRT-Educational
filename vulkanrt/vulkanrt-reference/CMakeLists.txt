# CMakeList.txt : CMake project for realtimertfilters-app, include source and define
# DISCLAIMER: This was heavily inspired by Sascha Willems cmakelists file for his examples
cmake_minimum_required (VERSION 3.8)

# FILE Macros for all sources, main source and main headers
file (GLOB ALL_SOURCES "*.cpp" "*.inl" "*.h" "*.hpp")
set(MAIN_SOURCE raytracingreflections.cpp)

# find_package(OpenMP) # Multithreading API - used in some of Sascha Willems examples

#include IMGUI
file(GLOB ADD_SOURCE "../external/imgui/*.cpp")
SET(ALL_SOURCES ${ALL_SOURCES} ${ADD_SOURCE})

# wayland requires additional source files
IF(USE_WAYLAND_WSI)
	SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_BINARY_DIR}/xdg-shell-client-protocol.h ${CMAKE_BINARY_DIR}/xdg-shell-protocol.c)
ENDIF()

set(SHADER_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/shaders/")
set(SHADER_OUTPUT_DIR "${CMAKE_CURRENT_LIST_DIR}/../data/shaders/glsl/reference/")
set(SHADER_LIST "closesthit.rchit" "miss.rmiss" "raygen.rgen")

set(SHADER_COMPILE_COMMANDS)

foreach (SHADER_TO_COMPILE IN LISTS SHADER_LIST)
	set (SHADER_COMPILE_COMMANDS "${SHADER_COMPILE_COMMANDS}$ENV{VULKAN_SDK}/Bin/glslc.exe \"${SHADER_SOURCE_DIR}${SHADER_TO_COMPILE}\" -o \"${SHADER_OUTPUT_DIR}${SHADER_TO_COMPILE}.spv\" --target-env=vulkan1.2\n")
endforeach()

IF(WIN32)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.bat.in" "${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.bat")
ELSE()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.bat.in" "${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.sh")
ENDIF()



if(WIN32)
	add_executable(vulkanrt-reference WIN32 ${MAIN_CPP} ${ALL_SOURCES} ${MAIN_HEADER} ${SHADERS})
	target_link_libraries(vulkanrt-reference base ${Vulkan_LIBRARY} ${WINLIBS})
        add_custom_command(TARGET vulkanrt-reference PRE_BUILD COMMAND "${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.bat")
else(WIN32)
	add_executable(vulkanrt-reference ${MAIN_CPP} ${ALL_SOURCES} ${MAIN_HEADER} ${SHADERS})
	target_link_libraries(vulkanrt-reference base )
        add_custom_command(TARGET vulkanrt-reference PRE_BUILD COMMAND "${CMAKE_CURRENT_LIST_DIR}/compile_all_shaders.sh")
endif(WIN32)

