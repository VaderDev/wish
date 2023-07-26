#

include_guard(GLOBAL)

# -------------------------------------------------------------------------------------------------

# cmake -B build/dev .
# cmake --build build/dev --target sandbox_versions
# cmake --install build/dev --prefix . --component sandbox_versions

# Experimental packaging feature
function(wish_package)
	cmake_parse_arguments(PARSE_ARGV 0 arg "" "TARGET;PACKAGE_DESTINATION" "")

	if (NOT arg_PACKAGE_DESTINATION)
		message(FATAL_ERROR "PACKAGE_DESTINATION missing")
	endif ()

	install(
		TARGETS ${arg_TARGET}
		DESTINATION "."
		COMPONENT ${arg_TARGET}
	)

	if (WISH_BUILD_TYPE_IS_PACKAGE)
		# Convenience package_<target> wrapped to package the given install component
		add_custom_target(package_${arg_TARGET}
			DEPENDS ${arg_TARGET}
			COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --prefix ${CMAKE_SOURCE_DIR}/${arg_PACKAGE_DESTINATION} --component ${arg_TARGET}
		)
	endif()
endfunction()

# -------------------------------------------------------------------------------------------------
