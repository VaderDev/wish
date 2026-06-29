# File: target.cmake, Created on 2017. 04. 14. 16:49, Author: Vader

include_guard(GLOBAL)

include(ExternalProject)

include(cmake/wish/wish_color.cmake)
include(cmake/wish/wish_configuration.cmake)
include(cmake/wish/wish_create.cmake)
include(cmake/wish/wish_debug.cmake)
include(cmake/wish/wish_flags.cmake)
include(cmake/wish/wish_linker.cmake)
include(cmake/wish/wish_package.cmake)
include(cmake/wish/wish_platform.cmake)
include(cmake/wish/wish_resource.cmake)
include(cmake/wish/wish_system.cmake)
include(cmake/wish/wish_version.cmake)

# -------------------------------------------------------------------------------------------------

message(STATUS "Wish: Version: ${wish_version}")

# -------------------------------------------------------------------------------------------------

macro(wish_skip_external_configures value)
	if(${value})
		wish_disable_configure_externals()
		message(STATUS "Wish: Skipping external project configurations")
	else()
		wish_enable_configure_externals()
		message(STATUS "Wish: Generating external project configurations")
	endif()
endmacro()

# Definitions --------------------------------------------------------------------------------------

# ${WISH_DATE_LONG}
# ${WISH_DATE_SHORT}
# ${WISH_TIME_LONG}
# ${WISH_TIME_SHORT}
# ${WISH_GIT_BRANCH}
# ${WISH_GIT_COMMIT_HASH}

string(LENGTH ${CMAKE_SOURCE_DIR}_ WISH_SHORT_PATH_CUTOFF)
add_definitions(-DWISH_SHORT_PATH_CUTOFF=${WISH_SHORT_PATH_CUTOFF})
add_definitions(-DWISH_SHORT_PATH_PREFIX="${CMAKE_SOURCE_DIR}/")

# -------------------------------------------------------------------------------------------------
