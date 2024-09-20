

## Wish - A CMake library for simplicity

NOTICE: Wish was just created, documentation, features and more info will be coming "soon"

TODO: Documentation

-----

#### Setup

Grab the latest wish hook script from your project's root
TODO: More documentation
```
wget https://raw.githubusercontent.com/VaderDev/wish/main/cmake/wish.cmake -P cmake/ -O cmake/wish.cmake
```

Inside your root CMakeLists.txt file just set the version and include the primary script:
TODO: More documentation
```
set(WISH_REQUEST_VERSION v5.5.3)
include(cmake/wish.cmake)
```

-----

#### Release notes

TODO: Format, place
TODO: Auto self update the wish.cmake script (not just the wish/ folder)

- v5.5.3
  - Ensure '/' is present at the end of WISH_PATH_TO_*SOURCE
  - Update repository URL
- v5.5.2
  - Fix: Fix additional subdirectory issues with wish_create_external
- v5.5.1
  - Fix: Fix some subdirectory issues with wish_create_ide_target, wish_group and wish_resource_mapping
- v5.5.0
  - Improvement: Disable optimization for 'debug' build type and create a new 'optdebug' build type with it
- v5.4.4
  - Feature: Add wish_werror
  - Improvement: Hide package_* target for non-package build types
- v5.4.3
  - Improvement: Add PLUGIN support for wish_generator
- v5.4.2
  - Fix: Handle wish_resource_mapping empty resource sets
- v5.4.1
  - Change: Modify wish_resource_mapping CMAKE_SOURCE_DIR marker from / to @ or @/
- v5.4.0
  - Change: Modify wish_resource_mapping expose the resource file mapping instead of the mapping function
  - Rename wish_resource_mapping arguments:
      FILE_NAME to MAPPING_FILE,
      FUNCTION_NAME to MAPPING_FUNCTION,
      GLOB to RESOURCE,
      REPLACE to MAPPING
  - Improvement: Add relative to CMAKE_SOURCE_DIR path support for wish_resource_mapping by starting the patch with '/'
- v5.3.3
  - Fix: Fix wish_group alias names
- v5.3.2
  - Rename: wish_enable_lto is now wish_enable_ipo to match cmake terminology
  - Improvement: Improve wish_enable_ipo to use built in CMake support
- v5.3.1
  - Fix: Fix detection of default linker in wish_alternative_linker
- v5.3.0
  - Feature: Add wish_alternative_linker to use an alternative linker
  - Feature: Add wish_enable_lto
  - Feature: Add WISH_COMPILER_IS_<uppercase-compiler-id> as TRUE or FALSE (WIN32, UNIX, APPLE, MSYS, MINGW, LINUX)
  - Feature: Add WISH_SYSTEM_IS_<uppercase-system-id> as TRUE or FALSE (MSVC, CLANG, GNU)
  - Feature: Add WISH_SYSTEM as the most specific system name (MSYS > MINGW > LINUX > APPLE > WIN32 > UNIX)
  - Feature: Add WISH_BUILD_TYPE_IS_<build-type> and WISH_BUILD_TYPE_IS_DEFAULT and set by wish_configurations to TRUE or FALSE
  - Improvement: WISH_ENABLED_LTO set to TRUE or FALSE
  - Improvement: Additional warnings for not supported build types in wish_optimization_flags and wish_enable_lto
- v5.2.2
  - Improvement: Add string variant for resource_path
- v5.2.1
  - Fix: Handle empty wish_resource destination directory
  - Fix: Fix wish_resource hardcoded target name
- v5.2.0
  - Feature: Add CONFIGURE_SOURCE for wish_create_executable, _library and _object functions
  - Experimental: Implement wish_resource_mapping
  - Experimental: Implement wish_package
  - Improvement: Add OUTPUT_NAME support for wish_create_executable
- v5.1.0
  - Fix: Resolve the error during first configure
- v5.0.5
  - Feature: Add automated library alias naming
  - Fix: Change lockfile placement to be ignored by git
- v5.0.4
  - Improvement: Use a lockfile during wish install and update
- v5.0.3
  - Feature: Add support for library aliases
  - Improvement: Make wish_group usage optional
- v5.0.2
  - Improvement: Enable USES_TERMINAL_DOWNLOAD for externals
- v5.0.0
  - Feature: Automated wish install and update
- v4.2
  - Feature: Add wish_linker_flags
- v4.1
  - Improvement: Fix double globbing during newly created generated files
- v4.0
  - Release: Initial release in this format

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
wish_configurations(debug dev DEFAULT release package)
```

wish_force_colored_output
```
wish_force_colored_output(<bool>)

# Example
option(MY_PROJECT_FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
wish_force_colored_output(${MY_PROJECT_FORCE_COLORED_OUTPUT})
```

wish_skip_external_configures
```
wish_skip_external_configures(<bool>)

# Example
option(MY_PROJECT_SKIP_EXTERNAL_CONFIGURES "Do not configure external projects only use the fake interface targets" FALSE)
wish_skip_external_configures(${MY_PROJECT_SKIP_EXTERNAL_CONFIGURES})
```

wish_werror
```
wish_werror(<bool>)

# Example
option(MY_PROJECT_WERROR "Specify whether to treat warnings on compile as errors." FALSE)
wish_werror(${MY_PROJECT_WERROR})
```

wish_alternative_linker
```
wish_alternative_linker(<string>)

# Example
option(MY_PROJECT_ALTERNATIVE_LINKER "Use an alternative linker. Leave empty for system default; alternatives are 'gold', 'lld', 'bfd', 'mold'" FALSE)
wish_alternative_linker(${MY_PROJECT_ALTERNATIVE_LINKER})
```

wish_enable_ipo
```
wish_enable_ipo(<boolean>)

# Example
option(MY_PROJECT_ENABLE_IPO "Enable interprocedural optimization (LTO)" FALSE)
wish_enable_ipo(${MY_PROJECT_ENABLE_IPO})
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

TODO: Reference documentation format for variables

WISH_BUILD_TYPE_IS_<build-type>: bool
WISH_BUILD_TYPE_IS_DEFAULT: bool
WISH_COMPILER_IS_<uppercase-compiler-id>: bool (WIN32, UNIX, APPLE, MSYS, MINGW, LINUX)
WISH_SYSTEM_IS_<uppercase-system-id>: bool
WISH_SYSTEM: string: contains the most specific system name (MSYS > MINGW > LINUX > APPLE > WIN32 > UNIX)

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
	PLUGIN  app/codegen/plugins/*.lua
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
	CONFIGURE_SOURCE <source glob pattern.in>...
	OBJECT <object targets>...
	OUTPUT_NAME <output name>
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
	TARGET <target or alias::name> (STATIC | SHARED | INTERFACE)
	ALIAS <alias::name>...
	SOURCE <source glob pattern>...
	CONFIGURE_SOURCE <source glob pattern.in>...
	OBJECT <object targets>...
	GENERATE <generator name> <input glob pattern>...
	LINK <link targets or libraries>...
	[NO_GROUP]
	[DEBUG]
)

# Example
wish_create_library(
	TARGET libA STATIC
	ALIAS lib::A
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
