# Copyright (C) 2019  Third Pin LLC
# www.thirdpin.io
#
# Written by:
#  Dmitrii Lisin       <d.lisin@thirdpin.ru>
#  Ilya Stolyarov      <i.stolyarov@thirdpin.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Prevent toolchain file double call
if(TOOLCHAIN_INCLUDED)
    return()
endif(TOOLCHAIN_INCLUDED)
set(TOOLCHAIN_INCLUDED true)


set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)


IF(${CMAKE_VERSION} VERSION_LESS 3.6.0)
    INCLUDE(CMakeForceCompiler)
    CMAKE_FORCE_C_COMPILER(arm-none-eabi-gcc GNU)
    CMAKE_FORCE_CXX_COMPILER(arm-none-eabi-g++ GNU)
ELSE()
    SET(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    SET(CMAKE_C_COMPILER arm-none-eabi-gcc)
    SET(CMAKE_CXX_COMPILER arm-none-eabi-g++)
ENDIF()


## -->  Get ARM toolchain path
    execute_process(
        COMMAND ${CMAKE_C_COMPILER} --print-file-name=libc.a
        OUTPUT_VARIABLE TOOLCHAIN_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    get_filename_component(TOOLCHAIN_PREFIX
        "${TOOLCHAIN_PREFIX}" PATH
    )

    get_filename_component(TOOLCHAIN_PREFIX
        "${TOOLCHAIN_PREFIX}/.." REALPATH
    )
## <--

set(TOOLCHAIN_PREFIX ${TOOLCHAIN_PREFIX} CACHE FILEPATH "Install prefix")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_FIND_LIBRARY_PREFIXES "lib")
SET(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")

set(CMAKE_INSTALL_PREFIX "${TOOLCHAIN_PREFIX}" CACHE PATH "...")

set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -fstack-usage")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -fstack-usage")

set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT} -Wl,--defsym,__dso_handle=0")

set(TOOLCHAIN_CORTEX_CONFIG "cortex-m3" CACHE STRING
  "Cortex chosen by the user at CMake configure time")

set_property(CACHE TOOLCHAIN_CORTEX_CONFIG 
    PROPERTY 
        STRINGS cortex-m3 cortex-m4 cortex-m0 cortex-a9)

include(${CMAKE_CURRENT_LIST_DIR}/../_ConfigureCortexFlags.cmake)
configure_cortex_flags(${TOOLCHAIN_CORTEX_CONFIG})

# Colored console
# Use with ANSI Escape in Console plugin
# Utils that print messages looks on the environmet for color support.
# Go to Windows -> Pereferences -> C/C++ -> Build -> Environment and define
# GCC_COLORS "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
# TERM "xterm-256color"

# Colors do not work with Ninja builder because it retargets flows to own buffer
# So can be tried this Force option
option (FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
if (${FORCE_COLORED_OUTPUT})
    add_compile_options (-fdiagnostics-color=always)
endif ()

