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

if(WIN32)
	add_executable(vulkanrt-reference WIN32 ${MAIN_CPP} ${ALL_SOURCES} ${MAIN_HEADER} ${SHADERS})
	target_link_libraries(vulkanrt-reference base ${Vulkan_LIBRARY} ${WINLIBS})
else(WIN32)
	add_executable(vulkanrt-reference ${MAIN_CPP} ${ALL_SOURCES} ${MAIN_HEADER} ${SHADERS})
	target_link_libraries(vulkanrt-reference base )
endif(WIN32)

