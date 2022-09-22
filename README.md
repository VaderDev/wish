

## Wish - A CMake library for simplicity

NOTICE: Wish was just created, documentation, features and more info will be coming soon 

TODO: Documentation

-----

#### Release notes

TODO: Format, place

- Version 4.1 - Fix double globbing during newly created generated files
- Version 4.0 - Initial release in this format (history)

-----

### API Reference

TODO: Reference documentation

include(cmake/wish.cmake)
```
include(cmake/wish.cmake)
wish_version
```

wish_configurations
```
wish_configurations(DEFAULT <default mode> <other modes>...)

# Example
wish_configurations(DEFAULT Release Dev Debug)
```

wish_force_colored_output
```
wish_force_colored_output(<bool>)

# Example
option(FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
wish_force_colored_output(${FORCE_COLORED_OUTPUT})
```

wish_skip_external_configures
```
wish_skip_external_configures(<bool>)

# Example
option(SKIP_EXTERNAL_CONFIGURES "Do not configure external projects only use the fake interface targets" FALSE)
wish_skip_external_configures(${SKIP_EXTERNAL_CONFIGURES})
```

wish_warning
```
TODO

# Example
wish_warning(
	MSVC /Wall
	Clang -Weverything
	GNU -Wall
	GNU VERSION_GREATER 12.0 -Wno-array-bounds
)
```

wish_compiler_flags
```
TODO

# Example
wish_compiler_flags(
	GNU -fcoroutines
	GNU -m64
	GNU -std=c++23
)
```

wish_linker_flags
```
TODO

# Example
wish_linker_flags(
    Release GNU -mwindows
)
```

wish_optimization_flags
```
wish_optimization_flags()
```

wish_group
```
wish_group(<group_name> <aliases...>)

# Example
wish_group(group_library lib)
```

wish_create_external
```
TODO

# Example
wish_create_external(
	NAME catch
	GIT_REPOSITORY https://github.com/catchorg/Catch2
	GIT_TAG v3.0.1
	CMAKE_ARGS
        -DCATCH_INSTALL_DOCS=OFF
        -DCATCH_INSTALL_EXTRAS=OFF
	LINK Catch2Main Catch2
)
```

wish_generator
```
TODO

# Example
wish_generator(
	TARGET  codegen
	COMMAND codegen
#	OUTPUT  REPLACE ".in.lua" ".hpp"
	OUTPUT  REPLACE ".ins.lua" ".hpp"
	OUTPUT  REPLACE ".ins.lua" ".cpp"
)
```

wish_create_executable
```
wish_create_executable(
	TARGET <target name>
	SOURCE <source glob pattern>...
	OBJECT <object targets>...
	GENERATE <generator name> <input glob pattern>...
	LINK <link targets or libraries>...
	[NO_GROUP]
	[DEBUG]
)

# Example
wish_create_executable(
	TARGET codegen
	SOURCE app/codegen/codegen_main.cpp
	LINK   ext_fmt ext_sol
)
```


wish_create_library
```
wish_create_library(
	TARGET <target name> (STATIC | SHARED | INTERFACE)
	SOURCE <source glob pattern>...
	OBJECT <object targets>...
	GENERATE <generator name> <input glob pattern>...
	LINK <link targets or libraries>...
	[NO_GROUP]
	[DEBUG]
)

# Example
wish_create_library(
	TARGET libA STATIC
	SOURCE src/libA/*.cpp
#	GENERATE codegen src/libA/*.in.lua
	GENERATE codegen src/libA/*.ins.lua
	LINK   Threads::Threads
)
```

wish_create_ide_target
```
wish_create_ide_target()
```
