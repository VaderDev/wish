// Created by Vader on 2022.07.10..

#include <iostream>

#include "version.hpp"


int main() {
	std::cout << "Hello Versions!" << std::endl;

	std::cout << "version_number: " << build.version_number << std::endl;
	std::cout << "version_name: " << build.version_name << std::endl;
	std::cout << "variant: " << build.variant << std::endl;
	std::cout << "build_number: " << build.build_number << std::endl;
	std::cout << "build_time: " << build.build_time << std::endl;
	std::cout << "build_uuid: " << build.build_uuid << std::endl;
}
