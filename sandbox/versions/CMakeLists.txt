#

wish_create_library(
		TARGET versions::lib STATIC
		SOURCE lib.cpp
)

set(WISH_BUILD_VERSION_MAJOR 0 CACHE STRING "BUILD_VERSION_MAJOR")
set(WISH_BUILD_VERSION_MINOR 0 CACHE STRING "BUILD_VERSION_MINOR")
set(WISH_BUILD_VERSION_PATCH 0 CACHE STRING "BUILD_VERSION_PATCH")
set(WISH_BUILD_VERSION_NAME "version-name" CACHE STRING "BUILD_VERSION_NAME")
set(WISH_BUILD_VARIANT "development" CACHE STRING "BUILD_VARIANT")
set(WISH_BUILD_NUMBER 0 CACHE STRING "BUILD_NUMBER")
set(WISH_BUILD_DATETIME "2000-01-01T00:00:00Z" CACHE STRING "BUILD_DATETIME")
set(WISH_BUILD_UUID 00000000-0000-0000-0000-000000000000 CACHE STRING "BUILD_UUID")

wish_create_executable(
		TARGET sandbox_versions
		OUTPUT_NAME versions
		SOURCE *.cpp
		CONFIGURE_SOURCE version.cpp.in
		LINK versions::lib
)

wish_resource_mapping(
		TARGET sandbox_versions
		MAPPING_FILE wish/resource_path.hpp
		MAPPING_FUNCTION wish::resource_mappings

		RESOURCE res/*.lua
		RESOURCE "${CMAKE_SOURCE_DIR}/res/*.lua"
		RESOURCE @/res_at/*.lua

		MAPPING ../../res/global_ res/global_
		MAPPING res/rename_me.lua res/file2.lua
		MAPPING res/global_rename_me.lua res/global_file2.lua
		MAPPING res_at/at_rename_me.lua res_at/at_file2.lua
		MAPPING res/ target-res/
		MAPPING res_at/ target-res/
)

wish_package(
		TARGET sandbox_versions
		PACKAGE_DESTINATION package/versions
)
