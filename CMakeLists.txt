#

cmake_minimum_required(VERSION 3.20)
project(wish)

#set(CMAKE_VERBOSE_MAKEFILE on)
#set(CMAKE_BUILD_TYPE DEBUG)
#set(CMAKE_BUILD_TYPE RELEASE)

include(cmake/wish.cmake)

# --------------------------------------------------------------------------------------------------

wish_configurations(DEFAULT Release Dev Debug)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Processor count: ${WISH_PROCESSOR_COUNT}")
message(STATUS "CXX compiler id: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CXX compiler version: ${CMAKE_CXX_COMPILER_VERSION}")
#message(STATUS "Git branch: ${WISH_GIT_BRANCH}")
#message(STATUS "Git commit: ${WISH_GIT_COMMIT_HASH}")

# Paths --------------------------------------------------------------------------------------------

set(PATH_EXT_IDE ext)
set(PATH_EXT     ${CMAKE_SOURCE_DIR}/ext)
set(PATH_EXT_SRC ${CMAKE_SOURCE_DIR}/ext_src)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/${CMAKE_BUILD_TYPE})

# --- Options --------------------------------------------------------------------------------------

option(FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
wish_force_colored_output(${FORCE_COLORED_OUTPUT})

option(SKIP_EXTERNAL_CONFIGURES "Do not configure external projects only use the fake interface targets" FALSE)
wish_skip_external_configures(${SKIP_EXTERNAL_CONFIGURES})

# --- Flags ----------------------------------------------------------------------------------------

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

wish_compiler_flags(
	GNU -fcoroutines
	GNU -m64
	GNU -std=c++23
)

wish_optimization_flags()

# Includes Directories -----------------------------------------------------------------------------

include_directories(app)
include_directories(src)

# === External ====================================================================================

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

find_package(OpenGL REQUIRED)

wish_group(group_external ext) # --- External -----------------------------------------------------

wish_create_external(
	NAME catch
	GIT_REPOSITORY https://github.com/catchorg/Catch2
	GIT_TAG v3.0.1
	CMAKE_ARGS
        -DCATCH_INSTALL_DOCS=OFF
        -DCATCH_INSTALL_EXTRAS=OFF
	LINK Catch2Main Catch2
)

wish_create_external(
	NAME fmt
	GIT_REPOSITORY https://github.com/fmtlib/fmt.git
	GIT_TAG 8.1.1
	CMAKE_ARGS
		-DFMT_DOC=OFF
		-DFMT_TEST=OFF
		-DBUILD_SHARED_LIBS=OFF
	LINK fmt
)

wish_create_external(
	NAME lua
	GIT_REPOSITORY https://github.com/walterschell/Lua.git
	GIT_TAG 14f98e5fdcde3ccd7ea9188181dd7e50660a2999 # v5.4.4
	CMAKE_ARGS
		-DLUA_ENABLE_SHARED=OFF
		-DLUA_BUILD_BINARY=OFF
		-DLUA_BUILD_COMPILER=OFF
		-DLUA_SUPPORT_DL=OFF
	LINK lua_static
)

wish_create_external(
	NAME sol2
	GIT_REPOSITORY https://github.com/ThePhD/sol2.git
	GIT_TAG v3.3.0
	CMAKE_ARGS
#		-DSOL2_BUILD_LUA=ON
#		-DSOL2_LUA_VERSION="5.4.4"
		-DSOL2_DOCS=OFF
	LINK ext_lua
)

#wish_create_external(
#	NAME vide
#	GIT_REPOSITORY https://github.com/cpplibv/vide.git
#	GIT_TAG 0a8204b7d4e2ae83540cb8418efd21157f8202ab
#	CMAKE_ARGS
#        -DJUST_INSTALL_VIDE=ON
#)

# === Targets =====================================================================================

wish_group(group_application app) # --- Application -----------------------------------------------

wish_create_executable(
	TARGET codegen
	SOURCE app/codegen/codegen_main.cpp
	LINK   ext_fmt ext_sol2
#	LINK   ext_fmt ext_range libv_lua libv_utility libv_algo
)

#wish_group(group_example example) # --- Example ---------------------------------------------------

wish_group(group_generator generator) # --- Generator ---------------------------------------------

wish_generator(
	TARGET  codegen
	COMMAND codegen
#	OUTPUT REPLACE ".in.lua" ".hpp"
	OUTPUT REPLACE ".inh.lua" ".hpp"
	OUTPUT REPLACE ".ins.lua" ".hpp"
	OUTPUT REPLACE ".ins.lua" ".cpp"
)

wish_group(group_library lib) # --- Library -------------------------------------------------------

wish_create_library(
	TARGET libA STATIC
	SOURCE src/libA/*.cpp
	GENERATE codegen src/libA/*.in?.lua
	LINK   Threads::Threads
)

wish_create_library(
	TARGET libB STATIC
	SOURCE src/libB/*.cpp
	LINK   Threads::Threads
)

wish_group(group_sandbox sandbox) # --- Sandbox ---------------------------------------------------

wish_create_executable(
	TARGET sandboxA
	SOURCE src/main.cpp
	LINK   libA Threads::Threads
)

wish_create_executable(
	TARGET sandboxB
	SOURCE src/main.cpp
	LINK   libA Threads::Threads
)

wish_group(group_test test) # --- Test ------------------------------------------------------------

wish_create_executable(
	TARGET test_libA
	SOURCE test/libA/*.cpp
	LINK   ext_catch libA
)

# -------------------------------------------------------------------------------------------------

wish_create_ide_target()

