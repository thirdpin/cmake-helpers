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


include(AddInterfaceWithNamespace)

# ---------------------------------------------------
# Compiler specific cross-target options for std libs
# ---------------------------------------------------

# Use
#
#   common::standard_libraries
#
# name to link this library to your target
add_library_with_ns(standard_libraries common)

# Linker options/linked libraries depend on compiler
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    target_link_libraries(standard_libraries INTERFACE
        # newlib-nano C library
        --specs=nano.specs

        --specs=nosys.specs
    )
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    target_link_libraries(standard_libraries INTERFACE
        m
        g_nano
        nosys
        stdc++_nano
        gcc
    )
else()
    message(FATAL_ERROR "standard_libraries target generation failed!\
                         Selected compiler should be \"Clang\" or \"GNU\"\
                         Current is ${CMAKE_CXX_COMPILER_ID}.\n\
                         May be you should include this file after\
                         project(<name>), see:\n\
                         https://stackoverflow.com/questions/20904914/\
                         cmake-compiler-is-gnucxx-and-cmake-cxx-compiler-id-are-empty")
endif()