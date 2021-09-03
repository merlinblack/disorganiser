cmake_minimum_required(VERSION 3.0)
project(disorganiser)

set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/sdl2)

add_subdirectory(lua)
find_package( SDL2 REQUIRED )
find_package( SDL2_image REQUIRED )
find_package( SDL2_ttf REQUIRED )

file(GLOB SRCS src/*.cpp src/bindings/*.cpp manualbind/src/*.cpp)
file(GLOB HDRS src/*.h src/bindings/*.h manualbind/src/*.h)

include_directories(
    src
    src/bindings
    manualbind/src
    ${Lua_INCLUDE_DIRS}
    )

# we don't want to copy if we're building in the source dir
if (NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    # list of directories for which we add a copy rule
    set(data_SHADOW scripts media)

    foreach(item IN LISTS data_SHADOW)
        message(STATUS "Configure directory: " ${item})
        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${item}"
            #COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/${item}" "${CMAKE_CURRENT_BINARY_DIR}/${item}"
            COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_CURRENT_SOURCE_DIR}/${item}" "${CMAKE_CURRENT_BINARY_DIR}/${item}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${item}"
        )
    endforeach()
endif()

add_executable (disorganiser
    ${SRCS}
    ${HDRS}
    )

target_include_directories(disorganiser PRIVATE "${SDL2_INCLUDE_DIRS}/..")

target_link_libraries(disorganiser
    ${Lua_LIBRARIES}
    SDL2::Main SDL2::Image SDL2::TTF
    )

set_property(TARGET disorganiser PROPERTY CXX_STANDARD 17)
set_property(TARGET disorganiser PROPERTY CXX_STANDARD_REQUIRED ON)

add_custom_target(data-target ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/media" "${CMAKE_CURRENT_BINARY_DIR}/scripts")

include(GitVersioning)
enable_git_versioning(disorganiser)
