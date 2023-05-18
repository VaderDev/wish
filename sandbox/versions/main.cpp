// Created by Vader on 2022.07.10..

#include <filesystem>
#include <iostream>

#include "version.hpp"
#include "foo.hpp"
#include <wish/resource_path.hpp>


int main(int argc, char** argv) {
// int wmain(int argc, wchar_t** argv) { // If -municode is used
	(void) argc;

	std::cout << "Hello Versions!" << std::endl;

	wish::change_current_path(argc, argv);

	foo();
	std::cout << "argv[0]: " << argv[0] << std::endl;
	std::cout << "version_number: " << build.version_number << std::endl;
	std::cout << "version_name: " << build.version_name << std::endl;
	std::cout << "variant: " << build.variant << std::endl;
	std::cout << "build_number: " << build.build_number << std::endl;
	std::cout << "build_time: " << build.build_time << std::endl;
	std::cout << "build_uuid: " << build.build_uuid << std::endl;

	std::cout << "current_path: " << std::filesystem::current_path().generic_string() << std::endl;

	std::cout << "target-res/file0.lua:        " << wish::resource_path_sv("target-res/file0.lua") << std::endl;
	std::cout << "target-res/file1.lua:        " << wish::resource_path_sv("target-res/file1.lua") << std::endl;
	std::cout << "target-res/file2.lua:        " << wish::resource_path_sv("target-res/file2.lua") << std::endl;
	std::cout << "target-res/global_file0.lua: " << wish::resource_path_sv("target-res/global_file0.lua") << std::endl;
	std::cout << "target-res/global_file1.lua: " << wish::resource_path_sv("target-res/global_file1.lua") << std::endl;
	std::cout << "target-res/global_file2.lua: " << wish::resource_path_sv("target-res/global_file2.lua") << std::endl;

	std::cout << "Access Local  Resource: " << std::filesystem::exists(wish::resource_path_sv("target-res/file0.lua")) << std::endl;
	std::cout << "Access Global Resource: " << std::filesystem::exists(wish::resource_path_sv("target-res/global_file0.lua")) << std::endl;

	return EXIT_SUCCESS;
}
