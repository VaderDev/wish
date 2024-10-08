# File: target.cmake, Created on 2017. 04. 14. 16:49, Author: Vader

include_guard(GLOBAL)

include(cmake/wish/wish_version.cmake)

# --- Options --------------------------------------------------------------------------------------

set(__wish_configure_externals 1)
macro(wish_enable_configure_externals)
	set(__wish_configure_externals 1)
endmacro()
macro(wish_disable_configure_externals)
	set(__wish_configure_externals 0)
endmacro()

set(__wish_global_debug 0)
macro(wish_enable_debug)
	set(__wish_global_debug 1)
endmacro()
macro(wish_disable_debug)
	set(__wish_global_debug 0)
endmacro()

# --- Group ----------------------------------------------------------------------------------------

set(__wish_current_group)

function(wish_group name)
	set(__wish_current_group ${name} PARENT_SCOPE)

	if (NOT TARGET ${name})
		add_custom_target(${name})
	endif ()
	foreach (alias IN ITEMS ${ARGN})
		if (NOT TARGET ${alias})
			add_custom_target(${alias} DEPENDS ${name})
		endif ()
	endforeach ()
endfunction()

macro(__wish_add_member_to_group target)
	if(__wish_current_group)
		add_dependencies(${__wish_current_group} ${target})
	endif()
endmacro()

# --- IDE / Build info -----------------------------------------------------------------------------

set(__wish_external_include_directories "" CACHE STRING "" FORCE)
set(__wish_external_defines "" CACHE STRING "" FORCE)
set(__wish_external_raw_arguments "wish_version(${wish_version})" CACHE STRING "" FORCE)

## Creates wish_ide target that can be used to obtain various information for IDEs
function(wish_create_ide_target)
	if (NOT PROJECT_IS_TOP_LEVEL)
		return()
	endif ()

	# TODO P5: list targets / libraries / executables
	add_custom_target(wish_ide
		COMMAND ${CMAKE_COMMAND} -E echo "External include directories:"
		COMMAND ${CMAKE_COMMAND} -E echo "${__wish_external_include_directories}"
		COMMAND ${CMAKE_COMMAND} -E echo "External defines:"
		COMMAND ${CMAKE_COMMAND} -E echo "${__wish_external_defines}"
		VERBATIM
	)

	add_custom_target(wish
		COMMAND ${CMAKE_COMMAND} -E echo "Wish version: ${wish_version}"
	)

	file(WRITE "${CMAKE_BINARY_DIR}/__wish_external_raw_arguments.new.txt" "${__wish_external_raw_arguments}")
	add_custom_target(wish_ext_lazy
		# TODO P1: Different folder for different build types on ext is bypassed (ext currently built by build/release)
		# TODO P3: Its working, but would be nice, if not a re-entering call would execute it
		#			Creating a custom target for every external would improve this
		#			This would also mean that only the touched external are tried to be rebuilt
		#			Careful with multiple custom targets as USES_TERMINAL could force being serial
		USES_TERMINAL
		COMMAND ${CMAKE_COMMAND} -E compare_files "${CMAKE_BINARY_DIR}/__wish_external_raw_arguments.new.txt" "${CMAKE_BINARY_DIR}/__wish_external_raw_arguments.old.txt" || ${CMAKE_COMMAND} --build . --target ext -- -j 3
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/__wish_external_raw_arguments.new.txt" "${CMAKE_BINARY_DIR}/__wish_external_raw_arguments.old.txt"
	)
endfunction()

# --- External -------------------------------------------------------------------------------------

## Defines get_NAME for fetching the ExternalProject and ext_NAME as lightweight INTERFACE target
## Unrecognized parameters after INCLUDE_DIR, LINK or DEFINE are forbidden.
function(wish_create_external)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG;NO_GROUP;SKIP_CONFIGURE_AND_BUILD;SKIP_CONFIGURE;SKIP_BUILD" "NAME" "INCLUDE_DIR;LINK;DEFINE")

	set(temp_list ${__wish_external_raw_arguments})
	list(APPEND temp_list ${ARGN})
	set(__wish_external_raw_arguments "${temp_list}" CACHE STRING "" FORCE)

	# options
	set(command_str_configure)
	set(command_str_build)
	if(arg_SKIP_CONFIGURE_AND_BUILD OR arg_SKIP_CONFIGURE)
		set(command_str_configure "CONFIGURE_COMMAND;echo;\"Skipping configure...\"")
	endif()
	if(arg_SKIP_CONFIGURE_AND_BUILD OR arg_SKIP_BUILD)
		set(command_str_build "BUILD_COMMAND;echo;\"Skipping build...\"")
	endif()

	if(__wish_configure_externals)
		# add
		ExternalProject_Add(
			get_${arg_NAME}
			PREFIX ${PATH_EXT_SRC}/${arg_NAME}
			CMAKE_ARGS
				-DCMAKE_INSTALL_PREFIX=${PATH_EXT}/${arg_NAME}
			#GIT_SHALLOW 1 # shallow fetch is not possible as long as SHA tags are used
			DOWNLOAD_EXTRACT_TIMESTAMP 1
			EXCLUDE_FROM_ALL 1

			# USES_TERMINAL will serialize the download steps so the parallel connections are not dropped by overwhelmed/angered servers
			USES_TERMINAL_DOWNLOAD 1

			${command_str_configure}
			${command_str_build}
			${arg_UNPARSED_ARGUMENTS}
		)
	endif()
	add_library(ext_${arg_NAME} INTERFACE)

	# include
	if(NOT arg_INCLUDE_DIR)
		list(APPEND arg_INCLUDE_DIR include)
	endif()
	set(temp_list ${__wish_external_include_directories})
	foreach(var_include IN LISTS arg_INCLUDE_DIR)
		target_include_directories(ext_${arg_NAME} SYSTEM INTERFACE ${PATH_EXT}/${arg_NAME}/${var_include})
		list(APPEND temp_list ${PATH_EXT_IDE}/${arg_NAME}/${var_include})
	endforeach()
	set(ENV{__wish_external_include_directories} "${temp_list}")

	# link
	if(arg_LINK)
		target_link_directories(ext_${arg_NAME} INTERFACE ${PATH_EXT}/${arg_NAME}/lib)
		target_link_libraries(ext_${arg_NAME} INTERFACE ${arg_LINK})
	endif()

	set(temp_list ${__wish_external_defines})
	foreach(var_define IN LISTS arg_DEFINE)
		target_compile_definitions(ext_${arg_NAME} INTERFACE -D${var_define})
		list(APPEND temp_list ${var_define})
	endforeach()
	set(ENV{__wish_external_defines} "${temp_list}")

	# group
	if (NOT ${arg_NO_GROUP} AND ${__wish_configure_externals})
		__wish_add_member_to_group(get_${arg_NAME})
	endif()

	# debug
	if(arg_DEBUG OR __wish_global_debug)
		message("External target: ext_${arg_NAME}, get_${arg_NAME}")
		message("	Name      : ${arg_NAME}")
		message("	Define    : ${arg_DEFINE}")
		message("	ExtDir    : ${PATH_EXT}/${arg_NAME}")
		message("	ExtSource : ${PATH_EXT_SRC}/${arg_NAME}")
		message("	IncludeDir: ${arg_INCLUDE_DIR}")
		message("	Link      : ${arg_LINK}")
		message("	SkipCfg   : ${arg_SKIP_CONFIGURE}")
		message("	SkipBld   : ${arg_SKIP_BUILD}")
		message("	SkipCfgBld: ${arg_SKIP_CONFIGURE_AND_BUILD}")
		message("	Unparsed  : ${arg_UNPARSED_ARGUMENTS}")
		message("	NoGroup   : ${arg_NO_GROUP}")
		message("	Group     : ${__wish_current_group}")
	endif()
endfunction()

# --- Generate ------------------------------------------------------------------------------------

set(__wish_generators "")
# __wish_generator_depends_${generator_name} stores additional DEPENDS for the generator custom command
# __wish_generator_command_${generator_name} stores the generator commands
# __wish_generator_output_rules_${generator_name} stores the generator input -> outputs rewrite rules

function(wish_generator)
	# TODO P2: Improve PLUGIN support, currently only a single glob expression can be specified
	#			due to the limitations of the OUTPUT rule parsing
	cmake_parse_arguments(PARSE_ARGV 0 arg "" "TARGET;COMMAND;PLUGIN" "")

	set(temp_list ${__wish_generators})
	list(APPEND temp_list ${arg_TARGET})
	set(__wish_generators ${temp_list} PARENT_SCOPE)

	# Command
	set(__wish_generator_command_${arg_TARGET} ${arg_COMMAND} PARENT_SCOPE)

	# Depends
	if (arg_PLUGIN)
		file(GLOB_RECURSE plugin_files LIST_DIRECTORIES false CONFIGURE_DEPENDS ${arg_PLUGIN})
		set(__wish_generator_depends_${arg_TARGET} ${plugin_files} PARENT_SCOPE)
	endif ()

	# Have to hand parse outputs, as list of list as argument is not yet supported...
	set(output_rules ${arg_UNPARSED_ARGUMENTS})
	list(POP_FRONT output_rules)
	set(__wish_generator_output_rules_${arg_TARGET} ${output_rules} PARENT_SCOPE)
endfunction()

function(__wish_generate out_generated_outputs)
	cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "${__wish_generators}")

#	# debug
#	if(arg_DEBUG OR __wish_global_debug)
#		message("wish_generate")
#		message("	__wish_generators	  : ${__wish_generators}")
#		message("arg_enum	 : ${arg_enum}")
#		message("arg_codegen	 : ${arg_codegen}")
#		message("	ARGN				   : ${ARGN}")
#	endif()

	set(generated_outputs "")

	foreach(generator IN LISTS __wish_generators)
#		message("foreach generator	 : ${generator}")
#		message("foreach ${arg_${generator}}	 : ${arg_${generator}}")
##		if (NOT ${arg_${generator}})
		if (NOT arg_${generator})
			continue()
		endif()

		file(GLOB_RECURSE matching_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_${generator}})

		foreach(matching_file IN LISTS matching_files)
			set(output_files_rel "")
			set(output_files_abs "") # For CMake/Ninja to properly track dependencies output has to use abs path
			set(output_rules_left ${__wish_generator_output_rules_${generator}})
			while(output_rules_left)
				list(FIND output_rules_left "OUTPUT" end_index)

				list(SUBLIST output_rules_left 0 ${end_index} output_rule)
				# Use ${output_rule} list
				string(${output_rule} output_file ${matching_file})

				if (${output_file} STREQUAL ${matching_file})
					# if the output_file rule would match the matching_file the rule does not fit (and it would lead to circle dep anyways)
#					if(arg_DEBUG OR __wish_global_debug)
#						message("skipping ${matching_file} for generation, rule did not fit")
#					endif()
				else()
					list(APPEND output_files_rel ${output_file})
					list(APPEND output_files_abs ${CMAKE_CURRENT_SOURCE_DIR}/${output_file})
					if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${output_file}")
						file(TOUCH "${CMAKE_CURRENT_SOURCE_DIR}/${output_file}")
						file(TOUCH "${matching_file}") # Touch the input file to force generation of the output
					endif()
				endif()

				# Jump to next segment
				if (${end_index} EQUAL -1)
					set(output_rules_left "")
				else()
					math(EXPR end_index_p_1 "${end_index}+1")
					list(SUBLIST output_rules_left ${end_index_p_1} -1 output_rules_left)
				endif()
			endwhile()

			add_custom_command(
					OUTPUT  ${output_files_abs}
					COMMAND ${__wish_generator_command_${generator}} ${matching_file} ${output_files_rel}
					DEPENDS ${generator} ${matching_file} ${__wish_generator_depends_${generator}}
					WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			)

			list(APPEND generated_outputs ${output_files_abs})
		endforeach()
	endforeach()

	set(${out_generated_outputs} ${generated_outputs} PARENT_SCOPE)

#	if(arg_DEBUG OR __wish_global_debug)
#		message("out_generated_outputs : ${out_generated_outputs}")
#		message("generated_outputs	 : ${generated_outputs}")
#	endif()
endfunction()

# --- Executable -----------------------------------------------------------------------------------

function(wish_create_executable)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG;NO_GROUP" "TARGET;OUTPUT_NAME" "SOURCE;CONFIGURE_SOURCE;OBJECT;GENERATE;LINK")

	# check
	if(NOT arg_SOURCE AND NOT arg_OBJECT)
		message(FATAL_ERROR "At least one SOURCE or OBJECT should be given.")
	endif()

	# generated files
	if(arg_GENERATE)
		__wish_generate(generated_outputs ${arg_GENERATE})
	endif()

	# glob
	file(GLOB_RECURSE matching_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_SOURCE})
	if(arg_CONFIGURE_SOURCE)
		file(GLOB_RECURSE matching_configure_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_CONFIGURE_SOURCE})
	endif()
	foreach(obj IN LISTS arg_OBJECT)
		list(APPEND matching_sources $<TARGET_OBJECTS:${obj}>)
	endforeach()

	# add
	set(every_source ${matching_sources} ${generated_outputs})
	list(REMOVE_DUPLICATES every_source)

	add_executable(${arg_TARGET} ${every_source})
	target_link_libraries(${arg_TARGET} ${arg_LINK})
	target_link_libraries(${arg_TARGET} ${obj})

	# properties
	if (arg_OUTPUT_NAME)
		set_target_properties(${arg_TARGET} PROPERTIES OUTPUT_NAME "${arg_OUTPUT_NAME}")
	endif ()

	# Set the following preprocessor defines:
	#	WISH_BUILD_PACKAGE [0/1] - 1 if the current build types is "package", 0 otherwise
	#	WISH_ENABLE_RESOURCE_MAPPING [0/1] - 0 if the current build types is "package", 1 otherwise
	#	WISH_PATH_TO_CURRENT_SOURCE [string] - relative path from the binary to the cmake current source directory
	#	WISH_PATH_TO_SOURCE [string] - relative path from the binary to the cmake source directory
	if (CMAKE_BUILD_TYPE STREQUAL "package")
		target_compile_definitions(${arg_TARGET} PRIVATE WISH_BUILD_PACKAGE=1)
		target_compile_definitions(${arg_TARGET} PRIVATE WISH_ENABLE_RESOURCE_MAPPING=0)
	else ()
		target_compile_definitions(${arg_TARGET} PRIVATE WISH_BUILD_PACKAGE=0)
		target_compile_definitions(${arg_TARGET} PRIVATE WISH_ENABLE_RESOURCE_MAPPING=1)
	endif ()

	file(RELATIVE_PATH path_to_current_source "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
	file(RELATIVE_PATH path_to_source "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_SOURCE_DIR}")

	# Append '/' at the end of the paths when they are not empty and missing the '/'
	if(path_to_current_source AND NOT path_to_current_source MATCHES "/$")
	    string(APPEND path_to_current_source "/")
	endif()
	if(path_to_source AND NOT path_to_source MATCHES "/$")
	    string(APPEND path_to_source "/")
	endif()

	target_compile_definitions(${arg_TARGET} PRIVATE WISH_PATH_TO_CURRENT_SOURCE="${path_to_current_source}")
	target_compile_definitions(${arg_TARGET} PRIVATE WISH_PATH_TO_SOURCE="${path_to_source}")

	# configure files
	if(matching_configure_sources)
		foreach(in_file IN LISTS matching_configure_sources)
			string(REGEX REPLACE "\\.in$" "" out_file ${in_file})
			# in_file  is in CMAKE_CURRENT_SOURCE_DIR
			# out_file is in CMAKE_CURRENT_BINARY_DIR
			configure_file(${in_file} ${out_file} @ONLY USE_SOURCE_PERMISSIONS)
			target_sources(${arg_TARGET} PRIVATE ${out_file})
		endforeach()
	endif()

	# group
	if (NOT ${arg_NO_GROUP})
		__wish_add_member_to_group(${arg_TARGET})
	endif()

	# debug
	if(arg_DEBUG OR __wish_global_debug)
		message("Executable target: ${arg_TARGET}")
		message("	Glob      : ${arg_SOURCE}")
		message("	ConfSource: ${arg_CONFIGURE_SOURCE}")
		message("	Source    : ${matching_sources}")
		message("	Object    : ${arg_OBJECT}")
		message("	Link      : ${arg_LINK}")
		message("	NoGroup   : ${arg_NO_GROUP}")
		message("	Group     : ${__wish_current_group}")
	endif()
endfunction()

# --- Library --------------------------------------------------------------------------------------

function(wish_create_library)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG;NO_GROUP;STATIC;SHARED;INTERFACE" "TARGET" "ALIAS;SOURCE;CONFIGURE_SOURCE;OBJECT;GENERATE;LINK")

	# check
#	if(NOT arg_SOURCE AND NOT arg_OBJECT)
#		message(FATAL_ERROR "At least one SOURCE or OBJECT should be given.")
#		# TODO P5: Target might be INTERFACE
#	endif()

	# Detect and remap alias named target
	if (${arg_TARGET} MATCHES "::")
		list(APPEND arg_ALIAS ${arg_TARGET})
		string(REPLACE "::" "_" arg_TARGET ${arg_TARGET})
	endif()

	# generated files
	if(arg_GENERATE)
		__wish_generate(generated_outputs ${arg_GENERATE})
	endif()

	# glob
	if(arg_SOURCE)
		file(GLOB_RECURSE matching_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_SOURCE})
	endif()
	if(arg_CONFIGURE_SOURCE)
		file(GLOB_RECURSE matching_configure_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_CONFIGURE_SOURCE})
	endif()
	foreach(obj IN LISTS arg_OBJECT)
		list(APPEND matching_sources $<TARGET_OBJECTS:${obj}>)
	endforeach()

	# add_library
	set(every_source ${matching_sources} ${target_objects} ${generated_outputs})
	list(REMOVE_DUPLICATES every_source)

	if(arg_STATIC)
		add_library(${arg_TARGET} STATIC ${every_source})
		target_link_libraries(${arg_TARGET} ${arg_LINK})
	elseif(arg_SHARED)
		add_library(${arg_TARGET} SHARED ${every_source})
		target_link_libraries(${arg_TARGET} ${arg_LINK})
	elseif(arg_INTERFACE)
		add_library(${arg_TARGET} INTERFACE ${every_source})
		target_link_libraries(${arg_TARGET} INTERFACE ${arg_LINK})
	else()
		message(FATAL_ERROR "Library has to be either STATIC, SHARED or INTERFACE")
	endif()

#	add_library(${arg_TARGET} $<IF:$<BOOL:${arg_STATIC}>,"STATIC",""> $<IF:$<BOOL:${arg_INTERFACE}>,"INTERFACE",""> ${matching_sources} ${target_objects})
#	target_link_libraries(${arg_TARGET} $<IF:$<BOOL:${arg_INTERFACE}>,"INTERFACE",""> ${arg_LINK})

	# configure files
	if(matching_configure_sources)
		foreach(in_file IN LISTS matching_configure_sources)
			string(REGEX REPLACE "\\.in$" "" out_file ${in_file})
			# in_file  is in CMAKE_CURRENT_SOURCE_DIR
			# out_file is in CMAKE_CURRENT_BINARY_DIR
			configure_file(${in_file} ${out_file} @ONLY USE_SOURCE_PERMISSIONS)
			target_sources(${arg_TARGET} PRIVATE ${out_file})
		endforeach()
	endif()

	# alias
	foreach(alias IN LISTS arg_ALIAS)
		add_library(${alias} ALIAS ${arg_TARGET})
	endforeach()

	# group
	if (NOT ${arg_NO_GROUP})
		__wish_add_member_to_group(${arg_TARGET})
	endif()

	# debug
	if(arg_DEBUG OR __wish_global_debug)
		message("Library target: ${arg_TARGET}")
		message("	Glob      : ${arg_SOURCE}")
		message("	Source    : ${matching_sources}")
		message("	ConfSource: ${arg_CONFIGURE_SOURCE}")
		message("	Object    : ${arg_OBJECT}")
		message("	Generate  : ${arg_GENERATE}")
		message("	Generated : ${generated_outputs}")
		message("	Alias     : ${arg_ALIAS}")
		message("	Link      : ${arg_LINK}")
		message("	Static    : ${arg_STATIC}")
		message("	Shared    : ${arg_SHARED}")
		message("	Interface : ${arg_INTERFACE}")
		message("	NoGroup   : ${arg_NO_GROUP}")
		message("	Groug     : ${__wish_current_group}")
	endif()
endfunction()

# --- Object ---------------------------------------------------------------------------------------

function(wish_create_object)
	cmake_parse_arguments(PARSE_ARGV 0 arg "DEBUG;NO_GROUP" "TARGET" "SOURCE;CONFIGURE_SOURCE;OBJECT;GENERATE;LINK")

	# check
	if(NOT arg_SOURCE AND NOT arg_OBJECT)
		message(FATAL_ERROR "At least one SOURCE or OBJECT should be given.")
	endif()

	# generated files
	if(arg_GENERATE)
		__wish_generate(generated_outputs ${arg_GENERATE})
	endif()

	# glob
	file(GLOB_RECURSE matching_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_SOURCE})
	if(arg_CONFIGURE_SOURCE)
		file(GLOB_RECURSE matching_configure_sources LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${arg_CONFIGURE_SOURCE})
	endif()
	foreach(obj IN LISTS arg_OBJECT)
		list(APPEND matching_sources $<TARGET_OBJECTS:${obj}>)
	endforeach()

	# add
	set(every_source ${matching_sources} ${generated_outputs})
	list(REMOVE_DUPLICATES every_source)

	add_library(${arg_TARGET} OBJECT ${every_source})

	# configure files
	if(matching_configure_sources)
		foreach(in_file IN LISTS matching_configure_sources)
			string(REGEX REPLACE "\\.in$" "" out_file ${in_file})
			# in_file  is in CMAKE_CURRENT_SOURCE_DIR
			# out_file is in CMAKE_CURRENT_BINARY_DIR
			configure_file(${in_file} ${out_file} @ONLY USE_SOURCE_PERMISSIONS)
			target_sources(${arg_TARGET} PRIVATE ${out_file})
		endforeach()
	endif()

	# group
	if (NOT ${arg_NO_GROUP})
		__wish_add_member_to_group(${arg_TARGET})
	endif()

	# debug
	if(arg_DEBUG OR __wish_global_debug)
		message("Object target: ${arg_TARGET}")
		message("	Glob      : ${arg_SOURCE}")
		message("	Source    : ${matching_sources}")
		message("	ConfSource: ${arg_CONFIGURE_SOURCE}")
		message("	Generate  : ${arg_GENERATE}")
		message("	Generated : ${generated_outputs}")
		message("	Link      : ${arg_LINK}")
		message("	Object    : ${arg_OBJECT}")
		message("	NoGroup   : ${arg_NO_GROUP}")
		message("	Group     : ${__wish_current_group}")
	endif()
endfunction()

# --------------------------------------------------------------------------------------------------
