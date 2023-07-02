#

include_guard(GLOBAL)

# RESOURCE paths starting with / will be interpreted as relative to CMAKE_SOURCE_DIR
function(wish_resource_mapping)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG" "TARGET;MAPPING_FILE;MAPPING_FUNCTION;RELATIVE" "RESOURCE;MAPPING")

	if (NOT arg_TARGET)
		message(FATAL_ERROR "TARGET missing")
	endif ()
	if (NOT arg_MAPPING_FILE)
		set(arg_MAPPING_FILE wish/resource_path.hpp)
	endif ()
	if (NOT arg_MAPPING_FUNCTION)
		set(arg_MAPPING_FUNCTION wish::resource_path)
	endif ()
	if (NOT arg_RELATIVE)
		set(arg_RELATIVE ${CMAKE_CURRENT_SOURCE_DIR})
	endif ()

	# GLOB
	# Remap / to relative to CMAKE_SOURCE_DIR
	set(arg_RESOURCE_root ${arg_RESOURCE})
	list(FILTER arg_RESOURCE_root INCLUDE REGEX "^/")
	list(FILTER arg_RESOURCE EXCLUDE REGEX "^/")
	file(GLOB_RECURSE physical_files LIST_DIRECTORIES false RELATIVE "${arg_RELATIVE}" CONFIGURE_DEPENDS ${arg_RESOURCE})
	set(virtual_files ${physical_files})

	foreach (resource IN LISTS arg_RESOURCE_root)
		file(GLOB_RECURSE matching_physical LIST_DIRECTORIES false RELATIVE "${arg_RELATIVE}" CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}${resource}")
		file(GLOB_RECURSE matching_virtual LIST_DIRECTORIES false RELATIVE "${CMAKE_SOURCE_DIR}" CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}${resource}")
		list(APPEND physical_files ${matching_physical})
		list(APPEND virtual_files ${matching_virtual})
	endforeach ()

	# Replace
	set(logical_files ${virtual_files})
	set(next_if_from 1)
	set(from)
	foreach (rule IN LISTS arg_MAPPING)
		if (next_if_from)
			set(next_if_from 0)
			set(from ${rule})
			continue()
		endif ()
		set(next_if_from 1)

		set(temp)
		foreach (it IN LISTS logical_files)
			string(REPLACE "${from}" "${rule}" value "${it}")
			list(APPEND temp "${value}")
		endforeach ()
		set(logical_files ${temp})
	endforeach ()

	# Register install files
	foreach (it_match it_target IN ZIP_LISTS physical_files logical_files)
		cmake_path(SET target_path ${it_target})
		cmake_path(GET target_path FILENAME target_filename)
		cmake_path(GET target_path PARENT_PATH target_dir)

		install(FILES "${arg_RELATIVE}/${it_match}" DESTINATION "./${target_dir}" RENAME "${target_filename}" COMPONENT ${arg_TARGET})
	endforeach ()

	# Build configure mapping string
	set(mapping_string)
	foreach (it_match it_target IN ZIP_LISTS physical_files logical_files)
		set(mapping_string "${mapping_string}\t\t{\"${it_target}\", \"${it_match}\"},\n")
	endforeach ()

	# Generate resource mapping source files
	string(REGEX MATCH "([^:]+)$" MAPPING_FUNCTION "${arg_MAPPING_FUNCTION}")
	string(REGEX REPLACE "^(.*)::[^:]+$" "\\1" NAMESPACE_MATCH "${arg_MAPPING_FUNCTION}")
	if (NAMESPACE_MATCH STREQUAL MAPPING_FUNCTION)
		set(NAMESPACE_BEGIN "")
		set(NAMESPACE_END "")
	else ()
		set(NAMESPACE_BEGIN "namespace ${NAMESPACE_MATCH} {")
		set(NAMESPACE_END "} // namespace ${NAMESPACE_MATCH}")
	endif ()

	set(mapping_source_code_hpp [=[
// Generated source file. Do not edit.

#pragma once

// std
#include <span>
#include <string_view>
#include <utility>


@NAMESPACE_BEGIN@

// -------------------------------------------------------------------------------------------------

void change_current_path(int argc, const char* const* argv);
void change_current_path(int argc, const wchar_t* const* argv);

#if WISH_ENABLE_RESOURCE_MAPPING

[[nodiscard]] std::span<std::pair<std::string_view, std::string_view>> @MAPPING_FUNCTION@();

#else

[[nodiscard]] constexpr inline std::span<std::pair<std::string_view, std::string_view>> @MAPPING_FUNCTION@() {
	return {};
}

#endif

// -------------------------------------------------------------------------------------------------

@NAMESPACE_END@
]=])

	set(mapping_source_code_cpp [=[
// Generated source file. Do not edit.

// hpp
#include <@arg_MAPPING_FILE@>
// std
#include <filesystem>
#if WISH_ENABLE_RESOURCE_MAPPING
#	include <unordered_map>
#endif

@NAMESPACE_BEGIN@

// -------------------------------------------------------------------------------------------------

#if WISH_ENABLE_RESOURCE_MAPPING

static std::pair<std::string_view, std::string_view> mapping_array[]{
@mapping_string@};

std::span<std::pair<std::string_view, std::string_view>> @MAPPING_FUNCTION@() {
	return mapping_array;
}

#endif

void change_current_path(int argc, const char* const* argv) {
	if (argc < 1)
		return;
	std::error_code ignore;
	std::filesystem::current_path(std::filesystem::path(argv[0]).parent_path(), ignore);
#if not WISH_BUILD_PACKAGE
	std::filesystem::current_path(WISH_PATH_TO_CURRENT_SOURCE, ignore);
#endif
}

// -------------------------------------------------------------------------------------------------

@NAMESPACE_END@

]=])

	file(CONFIGURE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_MAPPING_FILE}" CONTENT "${mapping_source_code_hpp}" @ONLY)
	file(CONFIGURE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_MAPPING_FILE}.cpp" CONTENT "${mapping_source_code_cpp}" @ONLY)
	target_include_directories(${arg_TARGET} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/")
	target_sources(${arg_TARGET} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_MAPPING_FILE}.cpp")

	# Debug
	if (arg_DEBUG OR __wish_global_debug)
		message("Resource Mapping:")
		message("	TARGET:           ${arg_TARGET}")
		message("	MAPPING_FILE:     ${arg_MAPPING_FILE}")
		message("	MAPPING_FUNCTION: ${arg_MAPPING_FUNCTION}")
		message("	RELATIVE:         ${arg_RELATIVE}")
		message("	RESOURCE:         ${arg_RESOURCE}")
		message("	MAPPING:          ${arg_MAPPING}")
		message("	physical_files:   ${physical_files}")
		message("	logical_files:     ${logical_files}")
		message("	mapping_string:\n${mapping_string}")
	endif ()
endfunction()
