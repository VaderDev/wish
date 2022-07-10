# File: target.cmake, Created on 2017. 04. 14. 16:49, Author: Vader


include(ExternalProject)
include(cmake/wish_create.cmake)
include(cmake/wish_date.cmake)
include(cmake/wish_git.cmake)
include(cmake/wish_util.cmake)
include(cmake/wish_compiler_flags.cmake)


# -------------------------------------------------------------------------------------------------

macro(wish_force_colored_output value)
    if (${value})
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            message(STATUS "Force colored output: GCC")
            add_compile_options(-fdiagnostics-color=always)
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            message(STATUS "Force colored output: Clang")
            add_compile_options(-fcolor-diagnostics)
        else()
            message(STATUS "Force colored output: False (Unknown compiler)")
        endif()
    else()
        message(STATUS "Force colored output: False")
    endif()
endmacro()

# -------------------------------------------------------------------------------------------------

macro(wish_skip_external_configures value)
#    if(${SKIP_EXTERNAL_CONFIGURES})
    if(value)
        wish_disable_configure_externals()
        message(STATUS "Skipping external project configurations")
    else()
        wish_enable_configure_externals()
        message(STATUS "Generating external project configurations")
    endif()
endmacro()

# -------------------------------------------------------------------------------------------------

macro(wish_optimization_flags)
    if(CMAKE_BUILD_TYPE STREQUAL "debug")
        add_compile_options(-Og)
        add_compile_options(-ggdb3)

    elseif(CMAKE_BUILD_TYPE STREQUAL "dev")
        add_compile_options(-O3)

    elseif(CMAKE_BUILD_TYPE STREQUAL "release")
        add_compile_options(-O3)
        add_compile_options(-flto)
        SET(CMAKE_AR "gcc-ar")
        SET(CMAKE_NM "gcc-nm")
        SET(CMAKE_RANLIB "gcc-ranlib")
    #	add_definitions(-DNDEBUG)
        wish_static_link_std()

    else()
        message(WARNING "Failed to identify [${CMAKE_BUILD_TYPE}] as a build type")
    endif()
endmacro()

# -------------------------------------------------------------------------------------------------
