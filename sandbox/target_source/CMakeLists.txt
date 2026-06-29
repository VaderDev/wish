#

wish_create_library(TARGET sandbox_target_source_lib1 STATIC)
wish_source(HEADER PRIVATE lib1.hpp)
wish_source(SOURCE PRIVATE lib1.cpp)

wish_create_library(TARGET sandbox_target_source_lib2 STATIC)
wish_source(HEADER PRIVATE lib2.hpp)
wish_source(SOURCE PRIVATE lib2.cpp)

wish_create_library(TARGET sandbox_target_source_lib3 STATIC)
wish_source(HEADER PRIVATE lib3.hpp)
wish_link(PRIVATE sandbox_target_source_lib1)
wish_link(PUBLIC sandbox_target_source_lib1)

wish_create_executable(TARGET sandbox_target_source1)
wish_source(SOURCE PRIVATE main.cpp)
wish_link(PRIVATE sandbox_target_source_lib1)

wish_create_executable(TARGET sandbox_target_source2)
wish_source_target(sandbox_target_source2 SOURCE PRIVATE main.cpp)
wish_link_target(sandbox_target_source2 PRIVATE sandbox_target_source_lib2)

wish_create_executable(TARGET sandbox_target_source3)
wish_source(SOURCE PRIVATE main.cpp)
wish_link(PRIVATE sandbox_target_source_lib1)
wish_link(PRIVATE sandbox_target_source_lib2 sandbox_target_source_lib3)
