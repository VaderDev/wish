// Created by Vader on 2022.07.10..

#include <libA/common.hpp>

#include <catch2/catch_test_macros.hpp>


TEST_CASE("test0", "[test.module]") {
	CHECK(true);
}

TEST_CASE("test1", "[test.module]") {
	SECTION("A") {
		CHECK(true);
	}
	SECTION("B") {
		CHECK(false);
	}
	CHECK(true);
}

