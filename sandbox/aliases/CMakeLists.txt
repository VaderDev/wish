#

wish_create_library(
	TARGET sandbox_aliases_lib STATIC
	ALIAS sandbox_aliases::lib
	SOURCE lib.cpp
)

wish_create_executable(
	TARGET sandbox_aliases_main_named
	SOURCE main.cpp
	LINK sandbox_aliases_lib
)

wish_create_executable(
	TARGET sandbox_aliases_main_aliased
	SOURCE main.cpp
	LINK sandbox_aliases::lib
)
