#

include_guard(GLOBAL)

# --- Warning -----------------------------------------------------------------------------------

function(_aux_wish_collect_compiler_flags compile_or_link_flag output)
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
	while(i LESS argc)
		list(GET ARGN ${i} arg)
		string(TOLOWER ${arg} arg_lower)
		math(EXPR i ${i}+1)

		if(arg_lower IN_LIST build_types)
			set(cursor_build_type ${arg_lower})

		elseif(arg_lower IN_LIST compilers)
			set(cursor_compiler_id ${arg})
			set(cursor_condition)
			set(cursor_condition_version)

		elseif(arg_lower IN_LIST conditions)
			set(cursor_condition ${arg})
			set(cursor_condition_version)

			if(i LESS argc) # Just ignore the last unfinished condition
				list(GET ARGN ${i} cursor_condition_version)
			endif()

			math(EXPR i ${i}+1) # extra token consumed for version

		else()
			if(NOT cursor_build_type OR CMAKE_BUILD_TYPE STREQUAL "${cursor_build_type}")
				if(CMAKE_CXX_COMPILER_ID MATCHES ${cursor_compiler_id})
					if(CMAKE_CXX_COMPILER_VERSION ${cursor_condition} ${cursor_condition_version})
						if(compile_or_link_flag)
							add_compile_options(${arg})
						else()
							add_link_options(${arg})
						endif()
						set(result "${result}${arg} ")
					endif()
				endif()
			endif()
		endif()
	endwhile()

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
	_aux_wish_collect_compiler_flags(true flags ${ARGV})
	message(STATUS "Warning flags: ${flags}")
endfunction()

# -------------------------------------------------------------------------------------------------

# @Usage
#	wish_compiler_flags(
#		GNU VERSION_LESS 13.0 -fcoroutines
#	)
function(wish_compiler_flags versioned_flag_list)
	_aux_wish_collect_compiler_flags(true flags ${ARGV})
	message(STATUS "Compiler flags: ${flags}")
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
	_aux_wish_collect_compiler_flags(false flags ${ARGV})
	message(STATUS "Linker flags: ${flags}")
endfunction()

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
