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

set(TOOLCHAIN_PREFIX arm-none-eabi-)
set(TOOLCHAIN_TRIPLE arm-none-eabi)
set(CMAKE_INSTALL_PREFIX "${TOOLCHAIN_PREFIX}" CACHE PATH "...")

# Select tool for exes path resolving
if(MINGW OR CYGWIN OR WIN32)
  set(UTIL_SEARCH_CMD "cmd")
  set(UTIL_SEARCH_ARGS "/c where ${TOOLCHAIN_PREFIX}gcc")
elseif(UNIX OR APPLE)
    set(UTIL_SEARCH_CMD "which")
    set(UTIL_SEARCH_ARGS "${TOOLCHAIN_PREFIX}gcc")
endif()

# Get a full path to an executable from GCC ARM toolchain
execute_process(
  COMMAND ${UTIL_SEARCH_CMD} ${UTIL_SEARCH_ARGS}
  OUTPUT_VARIABLE BINUTILS_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get path to 'bin' dirrectory of GCC ARM toolchain
get_filename_component(ARM_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)
set(ARM_TOOLCHAIN_PREFIX ${ARM_TOOLCHAIN_DIR}/..)

# Select cortex core
set(TOOLCHAIN_CORTEX_CONFIG "cortex-m3" CACHE STRING
    "Cortex chosen by the user at CMake configure time")

set_property(CACHE TOOLCHAIN_CORTEX_CONFIG 
    PROPERTY STRINGS 
        cortex-m3 cortex-m4 cortex-m0 cortex-a9)


# ------------------------------------
# Set a mix of Clang and ARM GCC tools
# ------------------------------------

# ASM compiller from ARM GCC
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)

# C and C++ compillers from Clang
set(CMAKE_C_COMPILER clang --target=${TOOLCHAIN_TRIPLE} CACHE PATH "") # clang C compiller
set(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_TRIPLE} CACHE STRING "")
set(CMAKE_CXX_COMPILER clang++ --target=${TOOLCHAIN_TRIPLE} CACHE PATH "") # clang C++ compiller
set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_TRIPLE} CACHE STRING "")

# Which prefix is correct?
# set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN ${ARM_TOOLCHAIN_PREFIX})
# set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN ${ARM_TOOLCHAIN_PREFIX})

# Objcopy and size tools from ARM GCC
set(CMAKE_SIZE_UTIL ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}size CACHE INTERNAL "size tool")

set(CMAKE_C_FLAGS_INIT "-fshort-enums")
set(CMAKE_CXX_FLAGS_INIT "-fshort-enums")

# Select linker type
set(LINKER_TYPE "ld" CACHE STRING
"Linker chosen by the user at CMake configure time.\
Possible values: `ld`, `ld.bfd`, `ld.gold`, `ld.lld`, `arm`")

set_property(CACHE LINKER_TYPE 
    PROPERTY STRINGS 
        ld ld.bfd ld.gold ld.lld arm)

if (${LINKER_TYPE} STREQUAL "ld.bfd")
    set(LINKER_TYPE_ARG "bfd")
elseif(${LINKER_TYPE} STREQUAL "ld.gold")
    set(LINKER_TYPE_ARG "gold")
elseif(${LINKER_TYPE} STREQUAL "ld.lld")
    set(LINKER_TYPE_ARG "lld")
elseif(${LINKER_TYPE} STREQUAL "arm")
    set(LINKER_TYPE_ARG "${ARM_TOOLCHAIN_DIR}/arm-none-eabi-ld")
else()
    set(LINKER_TYPE_ARG "ld")
endif()

# Add initial linker options
string(CONCAT
    CMAKE_EXE_LINKER_FLAGS_INIT "-B\"${ARM_TOOLCHAIN_DIR}/arm-none-eabi-\" "
                                "-fuse-ld=${LINKER_TYPE_ARG} "
                                "-Wl,--defsym,__dso_handle=0 "
                                "--verbose ")

message(STATUS "Linker type chosen: ${LINKER_TYPE_ARG}.")

# ------------
# Libs configs
# ------------

# Only for successful compilation of CMake test
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Control of find_package finging paths
set(CMAKE_FIND_ROOT_PATH ${ARM_TOOLCHAIN_DIR})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set possible suffixes of libs
SET(CMAKE_FIND_LIBRARY_PREFIXES "lib")
SET(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")


# ------------------
# STD libs inclusion
# ------------------

# Get version of ARM GCC compiller
execute_process(
    COMMAND arm-none-eabi-gcc -dumpversion 
    OUTPUT_VARIABLE ARM_NONE_EABI_GCC_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)

# Clang has not got own libraries so we borrow them from ARM GCC compiller
include_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/include/c++/${ARM_NONE_EABI_GCC_VERSION})
include_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/include/c++/${ARM_NONE_EABI_GCC_VERSION}/arm-none-eabi)
include_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/include/c++/${ARM_NONE_EABI_GCC_VERSION}/backward)
include_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/include)
include_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/include-fixed)
include_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/include)

if(TOOLCHAIN_CORTEX_CONFIG STREQUAL "cortex-m3")
    if(ARM_NONE_EABI_GCC_VERSION VERSION_GREATER "8.2.0")
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v7-m/nofp)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v7-m/nofp)
    else()
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v7-m)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v7-m)
    endif()
elseif(TOOLCHAIN_CORTEX_CONFIG STREQUAL "cortex-m4")
    if(ARM_NONE_EABI_GCC_VERSION VERSION_GREATER "8.2.0")
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v7e-m+dp/hard)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v7e-m+dp/hard)
    else()
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v7e-m/fpv4-sp/hard)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v7e-m/fpv4-sp/hard)
    endif()
elseif(TOOLCHAIN_CORTEX_CONFIG STREQUAL "cortex-m0")
    if(ARM_NONE_EABI_GCC_VERSION VERSION_GREATER "8.2.0")
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v6-m/nofp)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v6-m/nofp)
    else()
        link_directories(${ARM_TOOLCHAIN_DIR}/../${TOOLCHAIN_TRIPLE}/lib/thumb/v6-m)
        link_directories(${ARM_TOOLCHAIN_DIR}/../lib/gcc/${TOOLCHAIN_TRIPLE}/${ARM_NONE_EABI_GCC_VERSION}/thumb/v6-m)
    endif()
endif()


# ---------------------------------------
# Core related cortex flags configuration
# ---------------------------------------

include(${CMAKE_CURRENT_LIST_DIR}/../_ConfigureCortexFlags.cmake)
configure_cortex_flags(${TOOLCHAIN_CORTEX_CONFIG})


# ---------------
# Colored console
# ---------------

# Use with ANSI Escape in Console plugin
# Utils that print messages looks on the environmet for color support.
# Go to Windows -> Pereferences -> C/C++ -> Build -> Environment and define
# GCC_COLORS "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
# TERM "xterm-256color"

# Colors do not work with Ninja builder because it retargets flows to own buffer
# So can be tried this Force option
option (FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." FALSE)
if (${FORCE_COLORED_OUTPUT})
    add_compile_options (-fcolor-diagnostics)
endif ()
