#

include_guard(GLOBAL)

include(cmake/wish/wish_platform.cmake)

# --- Flags -------------------------------------------------------------------------------------

function(_aux_wish_collect_platform_flags compile_or_link_flag output)
	set(result)

	set(compilers msvc clang gnu)
	set(conditions version_less version_greater version_equal version_less_equal version_greater_equal)
	string(TOLOWER "${CMAKE_CONFIGURATION_TYPES}" build_types)

	set(cursor_compiler_id)
	set(cursor_condition)
	set(cursor_condition_version)
	set(cursor_build_type)
	set(i 0)

	list(LENGTH ARGN argc)
	while (i LESS argc)
		list(GET ARGN ${i} arg)
		string(TOLOWER ${arg} arg_lower)
		math(EXPR i ${i}+1)

		if (arg_lower IN_LIST build_types)
			set(cursor_build_type ${arg_lower})

		elseif (arg_lower IN_LIST compilers)
			set(cursor_compiler_id ${arg})
			set(cursor_condition)
			set(cursor_condition_version)

		elseif (arg_lower IN_LIST conditions)
			set(cursor_condition ${arg})
			set(cursor_condition_version)

			if (i LESS argc) # Just ignore the last unfinished condition
				list(GET ARGN ${i} cursor_condition_version)
			endif ()

			math(EXPR i ${i}+1) # extra token consumed for version

		else ()
			if (NOT cursor_build_type OR CMAKE_BUILD_TYPE STREQUAL "${cursor_build_type}")
				if (CMAKE_CXX_COMPILER_ID MATCHES ${cursor_compiler_id})
					if (CMAKE_CXX_COMPILER_VERSION ${cursor_condition} ${cursor_condition_version})
						if (compile_or_link_flag)
							add_compile_options(${arg})
						else ()
							add_link_options(${arg})
						endif ()
						set(result "${result}${arg} ")
					endif ()
				endif ()
			endif ()
		endif ()
	endwhile ()

	set(${output} ${result} PARENT_SCOPE)
endfunction()

# -------------------------------------------------------------------------------------------------

# @Usage
#	wish_warning(
#		MSVC  /Wall
#		Clang -Weverything
#		GNU   -Wall
#		GNU   -Wextra
#		GNU VERSION_GREATER 7.0 -Wduplicated-branches
#	)
function(wish_warning)
	_aux_wish_collect_platform_flags(true flags ${ARGV})
	message(STATUS "Wish: Warning flags: ${flags}")
endfunction()

# -------------------------------------------------------------------------------------------------

# @Usage
#	wish_compiler_flags(
#		GNU VERSION_LESS 13.0 -fcoroutines
#	)
function(wish_compiler_flags versioned_flag_list)
	_aux_wish_collect_platform_flags(true flags ${ARGV})
	message(STATUS "Wish: Compiler flags: ${flags}")
endfunction()

# -------------------------------------------------------------------------------------------------

# @Usage
#	wish_linker_flags(
#		GNU -mwindows
#		GNU VERSION_LESS 13.0 -mwindows
#		Release -mwindows
#		Release GNU -mwindows
#		Release GNU VERSION_LESS 13.0 -mwindows
#	)
function(wish_linker_flags versioned_flag_list)
	_aux_wish_collect_platform_flags(false flags ${ARGV})
	message(STATUS "Wish: Linker flags: ${flags}")
endfunction()

# -------------------------------------------------------------------------------------------------

set(WISH_ENABLED_LTO FALSE)

macro(wish_enable_lto)
	if (WISH_COMPILER_IS_GNU)
		add_compile_options(-flto)
		set(CMAKE_AR "gcc-ar")
		set(CMAKE_NM "gcc-nm")
		set(CMAKE_RANLIB "gcc-ranlib")
	else ()
		message(WARNING "Wish: LTO Support for ${WISH_COMPILER} is not yet implemented.")
		return()
	endif ()

	set(WISH_ENABLED_LTO TRUE)
	message(STATUS "Wish: Enabled LTO: ${WISH_COMPILER}")
endmacro()

# -------------------------------------------------------------------------------------------------

macro(wish_optimization_flags)
	wish_compiler_flags(
			debug GNU -Og
			debug GNU -ggdb3

			dev GNU -O3

			release GNU -O3
			release GNU -DNDEBUG

			package GNU -O3
			package GNU -DNDEBUG
	)
	wish_linker_flags(
			release GNU -static
			package GNU -static
	)
	if (WISH_BUILD_TYPE_IS_release OR WISH_BUILD_TYPE_IS_package)
		wish_enable_lto()
	endif ()

	set(supported_compilers GNU)
	set(supported_build_types debug dev release package)

	if (NOT WISH_COMPILER IN_LIST supported_compilers)
		message(WARNING "Wish: Default optimization flags for \"${WISH_COMPILER}\" is not implemented.")
	endif ()
	if (NOT WISH_BUILD_TYPE IN_LIST supported_build_types)
		message(WARNING "Wish: Default optimization flags for \"${WISH_BUILD_TYPE}\" is not implemented.")
	endif ()
endmacro()

# -------------------------------------------------------------------------------------------------
