#

cmake_minimum_required(VERSION 3.20)
project(wish)

include(cmake/wish.cmake)

# --------------------------------------------------------------------------------------------------

#set(CMAKE_VERBOSE_MAKEFILE off)
#set(CMAKE_BUILD_TYPE DEBUG)
#set(CMAKE_BUILD_TYPE RELEASE)

if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE RELEASE)
endif()
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)
#set(CMAKE_BUILD_TYPE WISH_BUILD_TYPE_LOWER)

set(CMAKE_CONFIGURATION_TYPES "DEBUG;RELEASE;DEV" CACHE STRING "" FORCE)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Processor count: ${WISH_PROCESSOR_COUNT}")
message(STATUS "CXX compiler id: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CXX compiler version: ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Git branch: ${WISH_GIT_BRANCH}")
message(STATUS "Git commit: ${WISH_GIT_COMMIT_HASH}")

# TODO ---------------------------------------------------------------------------------------------

# TODO P3: wish: add support for skipping library build/links via directly amending the sources of a dependency (only for DEV build)
# TODO P4: wish: inheritance for wish_create_executable and create_library
# TODO P5: wish: modernize based on (GLOB will stay tho): https://www.youtube.com/watch?v=bsXLMQ6WgIk
# TODO P5: wish: flag or build options to turn on/off sanitizes
# TODO P5: wish: Recommended configure flags: -G"Ninja" -DCMAKE_BUILD_TYPE=DEV -DSKIP_EXTERNAL_CONFIGURES=TRUE -DFORCE_COLORED_OUTPUT=TRUE

# Paths --------------------------------------------------------------------------------------------

set(PATH_EXT_IDE ext)
set(PATH_EXT     ${CMAKE_SOURCE_DIR}/ext)
set(PATH_EXT_SRC ${CMAKE_SOURCE_DIR}/ext_src)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE})

# Warning flags ------------------------------------------------------------------------------------

wish_warning(
	MSVC /Wall

	Clang -Weverything
	Clang -Wmissing-override
	Clang -Wconversion

	GNU -Wall
	GNU -Warray-bounds
	GNU -Wcast-align=strict
	GNU -Wcast-qual
	GNU -Wconversion
	GNU -Wdelete-non-virtual-dtor
	GNU -Wdouble-promotion
	GNU -Wduplicated-branches
	GNU -Wduplicated-cond
	GNU -Wextra
	GNU -Wlogical-op
	GNU -Wmultistatement-macros
	GNU -Wnon-virtual-dtor # Causes some false positives with efsw (suppressed)
	GNU -Wold-style-cast
	GNU -Wpedantic
	GNU -Wrestrict
	GNU -Wshadow-compatible-local
	GNU -Wsuggest-override
	GNU -Wundef

	#	more warning:
	#GNU -Wmissing-include-dirs
	#GNU -Wdisabled-optimization,
	#GNU -Wpadded,
	#GNU -Wzero-as-null-pointer-constant,
	#	maybe even:
	#GNU -Wswitch-enum, and take a look at:
	#GNU -Wunsafe-loop-optimizations,
	#GNU -Wdangling-else

	# Enablement in progress:
	# GNU -Wuseless-cast # in vec_base_t has some false positive issue with this one, but otherwise clear
	# GNU -Wfloat-equal # some in tests, and some in ui might be true positive, ui got some true positive with ratio

	# Only enable time-to-time to check on what is going on:
	# GNU -Winline
	# GNU -Wsuggest-final-methods # in signal 50+ function
	# GNU -Wsuggest-final-types # in signal 1 type

	# With GCC 12.1 some false positives warnings appeared and some do ignore the system header includes
	GNU VERSION_GREATER 12.0 -Wno-array-bounds
	GNU VERSION_GREATER 12.0 -Wno-stringop-overread
	GNU VERSION_GREATER 12.0 -Wno-stringop-overflow

	# Warnings that I don't care about
	Clang -Wno-comment
	GNU -Wno-comment
	# GNU -Wnull-dereference # Causes too many false positives as of GCC 11.2
	# GNU -Werror
)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
	add_compile_options(-fcoroutines)
endif()

# --- Options --------------------------------------------------------------------------------------

option(FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
wish_force_colored_output(${FORCE_COLORED_OUTPUT})

option(SKIP_EXTERNAL_CONFIGURES "Do not configure external projects only use the fake interface targets" FALSE)
wish_skip_external_configures(${SKIP_EXTERNAL_CONFIGURES})

wish_optimization_flags()

# Flags --------------------------------------------------------------------------------------------

add_compile_options(-m64)
add_compile_options(-std=c++23)
#set(CMAKE_CXX_STANDARD 23) # This stupid thing uses -std=gnu++23

# Tooling ------------------------------------------------------------------------------------------

# Sparing tooling from supporting requires, for now.
add_definitions("-D\"WISH_REQUIRES(...)=requires (__VA_ARGS__)\"")
#wish_add_ide_definition("WISH_REQUIRES(...)" " ")
add_definitions("-D\"IDE_IGNORE(...)=__VA_ARGS__\"")

add_definitions(-DWISH_DATE_LONG="${WISH_DATE_LONG}")
add_definitions(-DWISH_DATE_SHORT="${WISH_DATE_SHORT}")
add_definitions(-DWISH_TIME_LONG="${WISH_TIME_LONG}")
add_definitions(-DWISH_TIME_SHORT="${WISH_TIME_SHORT}")

# Definitions --------------------------------------------------------------------------------------

# Macro - Git
add_definitions(-DWISH_GIT_BRANCH="${WISH_GIT_BRANCH}")
add_definitions(-DWISH_GIT_COMMIT_HASH="${WISH_GIT_COMMIT_HASH}")
# Macro - Libv
string(LENGTH ${CMAKE_SOURCE_DIR}_ WISH_SHORT_PATH_CUTOFF)
add_definitions(-DWISH_SHORT_PATH_CUTOFF=${WISH_SHORT_PATH_CUTOFF})
add_definitions(-DWISH_SHORT_PATH_PREFIX="${CMAKE_SOURCE_DIR}/")

# Includes Directories -----------------------------------------------------------------------------

include_directories(app)
include_directories(src)

# === Package ======================================================================================

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

find_package(OpenGL REQUIRED)

## === External =====================================================================================
#
#wish_create_group(GROUP_EXTERNAL_PROJECT) # External -----------------------------------------------
#
#wish_create_external(
#	NAME vide
#	GIT_REPOSITORY https://github.com/cpplibv/vide.git
#	GIT_TAG 0a8204b7d4e2ae83540cb8418efd21157f8202ab
##	GIT_REPOSITORY /e/dev/cpp/forks/vide
##	GIT_TAG dev
#	CMAKE_ARGS
#		-DJUST_INSTALL_VIDE=ON
#)
#
#wish_end_group()
#
## === Targets ======================================================================================
#
#wish_create_group(GROUP_GENERATOR) # Generators ---------------------------------------------------
#
#wish_generator(
#	TARGET  enum
#	COMMAND enum
#	OUTPUT  REPLACE ".hpp.in.lua" ".hpp"
#)
#
#wish_generator(
#	TARGET  codegen
#	COMMAND codegen
#	OUTPUT  REPLACE ".in.lua" ".hpp"
#	OUTPUT  REPLACE ".in.lua" ".cpp"
#)
#
##wish_generator(
##	TARGET  enum_split
##	COMMAND enum --split
##	OUTPUT  REPLACE .hpp.in.lua .hpp
##	OUTPUT  REPLACE .hpp.in.lua .cpp
##	OUTPUT  REGEX REPLACE "\\.hpp\\.in\\.lua$" ".hpp"
##	OUTPUT  REGEX REPLACE "\\.hpp\\.in\\.lua$" ".cpp"
##)

wish_create_group(GROUP_LIBRARY) # Libraries -------------------------------------------------------

wish_create_library(
	TARGET libA STATIC
	SOURCE src/libA/*.cpp
	LINK   Threads::Threads
)

wish_end_group()
wish_create_group(GROUP_SANDBOX) # Sandboxes -------------------------------------------------------

wish_create_executable(
	TARGET sandbox
	SOURCE src/main.cpp
#	LINK   libvA libv_mt Threads::Threads
	LINK   libA Threads::Threads
)
wish_end_group()

## Tests --------------------------------------------------------------------------------------------
#
## TODO P5: This should be an object library, but ran into troubles with target_link_libraries against object library,
##			maybe an addition layer of interface would solve the problem
##			check on cmake, there might have been an update that improves this front
#wish_create_library(
#	TARGET obj_test_runner STATIC
#	SOURCE test/runner.cpp
#	LINK   ext_catch ext_fmt ext_boost
#)
#
#wish_create_group(GROUP_UNIT_TEST)
#
#wish_create_executable(
#	TARGET test_libv_algo
#	SOURCE test/libv/algorithm/*.cpp
#	LINK   obj_test_runner libv_algo ext_range
#)
#
#wish_end_group()

# groups -------------------------------------------------------------------------------------------

add_custom_target(group_application DEPENDS ${GROUP_APPLICATION})
add_custom_target(group_example     DEPENDS ${GROUP_EXAMPLE})
add_custom_target(group_externals   DEPENDS ${GROUP_EXTERNAL_PROJECT})
add_custom_target(group_generator   DEPENDS ${GROUP_GENERATOR})
add_custom_target(group_library     DEPENDS ${GROUP_LIBRARY})
add_custom_target(group_sandbox     DEPENDS ${GROUP_SANDBOX})
add_custom_target(group_unit_test   DEPENDS ${GROUP_UNIT_TEST})

add_custom_target(app       DEPENDS group_application)
add_custom_target(example   DEPENDS group_example)
add_custom_target(ext       DEPENDS group_externals)
add_custom_target(generator DEPENDS group_generator)
add_custom_target(lib       DEPENDS group_library)
#add_custom_target(sandbox   DEPENDS group_sandbox)
add_custom_target(test      DEPENDS group_unit_test)

wish_create_ide_target()

