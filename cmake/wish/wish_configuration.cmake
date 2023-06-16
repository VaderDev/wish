#

include_guard(GLOBAL)

# Sets CMAKE_CONFIGURATION_TYPES and CMAKE_BUILD_TYPE
# `DEFAULT` keyword marks the default configuration type
# Sets WISH_BUILD_TYPE_IS_<build-type> and WISH_BUILD_TYPE_IS_DEFAULT to TRUE or FALSE
#
# @Usage
#	wish_configurations(
#		debug
#		dev
#		DEFAULT release
#		package
#	)
macro(wish_configurations)
	cmake_parse_arguments(arg "" "DEFAULT" "" ${ARGN})

	set(CMAKE_CONFIGURATION_TYPES "${arg_UNPARSED_ARGUMENTS};${arg_DEFAULT}" CACHE STRING "" FORCE)

	if (NOT CMAKE_BUILD_TYPE)
		set(CMAKE_BUILD_TYPE ${arg_DEFAULT})
		set(WISH_BUILD_TYPE_IS_default TRUE)
		set(WISH_BUILD_TYPE_IS_DEFAULT TRUE)
	else ()
		set(WISH_BUILD_TYPE_IS_default FALSE)
		set(WISH_BUILD_TYPE_IS_DEFAULT FALSE)
	endif ()

	string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

	foreach (build_type IN LISTS arg_UNPARSED_ARGUMENTS arg_DEFAULT)
		string(TOLOWER ${build_type} build_type_lower)
		if (CMAKE_BUILD_TYPE STREQUAL build_type_lower)
			string(TOUPPER ${build_type} build_type_upper)
			set(WISH_BUILD_TYPE_IS_${build_type_lower} TRUE)
			set(WISH_BUILD_TYPE_IS_${build_type_upper} TRUE)
		else ()
			set(WISH_BUILD_TYPE_IS_${build_type_lower} FALSE)
			set(WISH_BUILD_TYPE_IS_${build_type_upper} FALSE)
		endif ()
	endforeach ()

	set(WISH_BUILD_TYPE ${CMAKE_BUILD_TYPE})
endmacro()
