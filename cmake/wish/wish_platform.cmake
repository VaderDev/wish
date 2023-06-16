#

include_guard(GLOBAL)

# Set:
#	WISH_COMPILER_IS_MSVC
#	WISH_COMPILER_IS_CLANG
#	WISH_COMPILER_IS_GNU
foreach (compiler_id MSVC Clang GNU)
	string(TOUPPER ${compiler_id} compiler_id_upper)

	if (CMAKE_CXX_COMPILER_ID MATCHES ${compiler_id})
		set(WISH_COMPILER_IS_${compiler_id_upper} TRUE)
	else ()
		set(WISH_COMPILER_IS_${compiler_id_upper} FALSE)
	endif ()
endforeach ()

# Set WISH_COMPILER as the uppercase compiler id
string(TOUPPER ${CMAKE_CXX_COMPILER_ID} WISH_COMPILER)
set(WISH_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})

# Set:
#	WISH_SYSTEM_IS_WIN32
#	WISH_SYSTEM_IS_UNIX
#	WISH_SYSTEM_IS_APPLE
#	WISH_SYSTEM_IS_MSYS
#	WISH_SYSTEM_IS_MINGW
#	WISH_SYSTEM_IS_LINUX (= UNIX AND NOT APPLE)
foreach (system_id WIN32 UNIX APPLE MSYS MINGW)
	string(TOUPPER ${system_id} system_id_upper)

	if (${system_id})
		set(WISH_SYSTEM_IS_${system_id_upper} TRUE)
	else ()
		set(WISH_SYSTEM_IS_${system_id_upper} FALSE)
	endif ()
endforeach ()
if (WISH_SYSTEM_IS_UNIX AND NOT WISH_SYSTEM_IS_APPLE)
	set(WISH_SYSTEM_IS_LINUX TRUE)
else ()
	set(WISH_SYSTEM_IS_LINUX FALSE)
endif ()

# Set WISH_SYSTEM as the most specific SYSTEM variable
set(WISH_SYSTEM)
foreach (system_id MSYS MINGW LINUX APPLE WIN32 UNIX) # Ordering matters
	if (WISH_SYSTEM_IS_${system_id})
		set(WISH_SYSTEM ${system_id})
		break()
	endif ()
endforeach ()
