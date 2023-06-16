#

include_guard(GLOBAL)

#set(CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fuse-ld=mold")

function(__wish_set_alternate_linker linker)
	find_program(LINKER_EXECUTABLE ld.${USE_ALTERNATE_LINKER} ${USE_ALTERNATE_LINKER})
	if (LINKER_EXECUTABLE)
		if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND "${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 12.0.0)
			add_link_options("-ld-path=${USE_ALTERNATE_LINKER}")
		else ()
			add_link_options("-fuse-ld=${USE_ALTERNATE_LINKER}")
		endif ()
		message(STATUS "Wish: Enable linker: ${USE_ALTERNATE_LINKER}")
	else ()
		message(FATAL_ERROR "Could not enable linker: ${USE_ALTERNATE_LINKER} - could not find program")
		#		set(USE_ALTERNATE_LINKER "" CACHE STRING "Use alternate linker" FORCE)
	endif ()
endfunction()

set(USE_ALTERNATE_LINKER "" CACHE STRING "Use alternate linker. Leave empty for system default; alternatives are 'gold', 'lld', 'bfd', 'mold'")
if (NOT "${USE_ALTERNATE_LINKER}" STREQUAL "")
	__wish_set_alternate_linker(${USE_ALTERNATE_LINKER})
endif ()
