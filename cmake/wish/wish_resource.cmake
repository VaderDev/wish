#

include_guard(GLOBAL)

function(wish_resource_mapping)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG" "TARGET;FILE_NAME;FUNCTION_NAME;RELATIVE" "GLOB;REPLACE")

	if (NOT arg_TARGET)
		message(FATAL_ERROR "TARGET missing")
	endif ()
	if (NOT arg_FILE_NAME)
		set(arg_FILE_NAME wish/resource_path.hpp)
	endif ()
	if (NOT arg_FUNCTION_NAME)
		set(arg_FUNCTION_NAME wish::resource_path)
	endif ()
	if (NOT arg_RELATIVE)
		set(arg_RELATIVE ${CMAKE_CURRENT_SOURCE_DIR})
	endif ()

	# GLOB
	file(GLOB_RECURSE matching_files LIST_DIRECTORIES false RELATIVE "${arg_RELATIVE}" CONFIGURE_DEPENDS ${arg_GLOB})

	# Replace
	set(target_files ${matching_files})
	set(next_if_from 1)
	set(from)
	foreach (rule IN LISTS arg_REPLACE)
		if (next_if_from)
			set(next_if_from 0)
			set(from ${rule})
			continue()
		endif ()
		set(next_if_from 1)

		set(temp)
		foreach (it IN LISTS target_files)
			string(REPLACE "${from}" "${rule}" value "${it}")
			list(APPEND temp "${value}")
		endforeach ()
		set(target_files ${temp})
	endforeach ()

	# Register install files
	foreach (it_match it_target IN ZIP_LISTS matching_files target_files)
		cmake_path(SET target_path ${it_target})
		cmake_path(GET target_path FILENAME target_filename)
		cmake_path(GET target_path PARENT_PATH target_dir)

		install(FILES "${arg_RELATIVE}/${it_match}" DESTINATION "./${target_dir}" RENAME "${target_filename}" COMPONENT ${arg_TARGET})
	endforeach ()

	# Build configure mapping string
	set(mapping_string)
	foreach (it_match it_target IN ZIP_LISTS matching_files target_files)
		set(mapping_string "${mapping_string}\t\t{\"${it_target}\", \"${it_match}\"},\n")
	endforeach ()

	# Generate resource mapping source files
	string(REGEX MATCH "([^:]+)$" FUNCTION_NAME "${arg_FUNCTION_NAME}")
	string(REGEX REPLACE "^(.*)::[^:]+$" "\\1" NAMESPACE_MATCH "${arg_FUNCTION_NAME}")
	if (NAMESPACE_MATCH STREQUAL FUNCTION_NAME)
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
#include <filesystem>
#include <string_view>


@NAMESPACE_BEGIN@

// -------------------------------------------------------------------------------------------------

void change_current_path(int argc, const char* const* argv);
void change_current_path(int argc, const wchar_t* const* argv);

#if WISH_ENABLE_RESOURCE_MAPPING

[[nodiscard]] std::string_view @FUNCTION_NAME@_sv(std::string_view virtual_path);
[[nodiscard]] std::filesystem::path @FUNCTION_NAME@(std::string_view virtual_path);

#else

[[nodiscard]] constexpr inline std::string_view @FUNCTION_NAME@_sv(std::string_view virtual_path) {
	return virtual_path;
}

[[nodiscard]] inline std::filesystem::path @FUNCTION_NAME@(std::string_view virtual_path) {
	return {virtual_path};
}

#endif

// -------------------------------------------------------------------------------------------------

@NAMESPACE_END@
]=])

	set(mapping_source_code_cpp [=[
// Generated source file. Do not edit.

// hpp
#include <@arg_FILE_NAME@>
// std
#include <filesystem>
#include <string>
#if WISH_ENABLE_RESOURCE_MAPPING
#	include <unordered_map>
#endif

@NAMESPACE_BEGIN@

// -------------------------------------------------------------------------------------------------

#if WISH_ENABLE_RESOURCE_MAPPING

std::unordered_map<std::string_view, std::string_view> mapping{
@mapping_string@};

std::string_view @FUNCTION_NAME@_sv(std::string_view virtual_path) {
	const auto it = mapping.find(virtual_path);
	if (it != mapping.end())
		return it->second;

	throw std::runtime_error("Virtual path: \"" + std::string(virtual_path) + "\" is not found in resource mapping.");
}

std::filesystem::path @FUNCTION_NAME@(std::string_view virtual_path) {
	return {@FUNCTION_NAME@_sv(virtual_path)};
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

	file(CONFIGURE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_FILE_NAME}" CONTENT "${mapping_source_code_hpp}" @ONLY)
	file(CONFIGURE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_FILE_NAME}.cpp" CONTENT "${mapping_source_code_cpp}" @ONLY)
	target_include_directories(${arg_TARGET} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/")
	target_sources(${arg_TARGET} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/__resource_mapping/${arg_FILE_NAME}.cpp")

	# Debug
	if (arg_DEBUG OR __wish_global_debug)
		message("Resource Mapping:")
		message("	TARGET:          ${arg_TARGET}")
		message("	FILE_NAME:       ${arg_FILE_NAME}")
		message("	FUNCTION_NAME:   ${arg_FUNCTION_NAME}")
		message("	RELATIVE:        ${arg_RELATIVE}")
		message("	GLOB:            ${arg_GLOB}")
		message("	REPLACE:         ${arg_REPLACE}")
		message("	matching_files:  ${matching_files}")
		message("	target_files:    ${target_files}")
		message("	mapping_string:\n${mapping_string}")
	endif ()
endfunction()
