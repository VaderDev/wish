#

wish_create_library(
	TARGET sandbox_smart_aliases::lib STATIC
	SOURCE lib.cpp
)

wish_create_executable(
	TARGET sandbox_smart_aliases_main_named
	SOURCE main.cpp
	LINK sandbox_aliases_lib
)

wish_create_executable(
	TARGET sandbox_smart_aliases_main_aliased
	SOURCE main.cpp
	OUTPUT_NAME sandbox_named
	LINK sandbox_aliases::lib
)
