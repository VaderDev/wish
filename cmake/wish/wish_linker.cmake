#

include_guard(GLOBAL)

include(cmake/wish/wish_platform.cmake)


# -------------------------------------------------------------------------------------------------

function(wish_alternative_linker linker_name)
	if (NOT linker_name)
		return()
	endif ()

	find_program(linker_executable ld.${linker_name} ${linker_name})
	if (linker_executable)
		if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND "${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 12.0.0)
			add_link_options("-ld-path=${linker_name}")
		else ()
			add_link_options("-fuse-ld=${linker_name}")
		endif ()
		message(STATUS "Wish: Enabled alternative linker: ${linker_name}")
	else ()
		message(FATAL_ERROR "Wish: Could not enable alternative linker: ${linker_name} program was not found")
	endif ()
endfunction()
