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


# ========================
# Global CMake environment
# ========================

# Make -DCMAKE_INSTALL_PREFIX works
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  SET(CMAKE_INSTALL_PREFIX ${STAGING_DIR} CACHE PATH "Installation Directory" FORCE)
endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

## --> IDE related settings
    # Generates an extra file that specifies the maximum amount 
    # of stack used, on a per-function basis.
    # Works for GCC compiler only
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        add_compile_options(-fstack-usage)
    endif()

    # Used if generator is Eclipse CDT
    if (CMAKE_ECLIPSE_VERSION)
        set(CMAKE_ECLIPSE_VERSION "4.5 (Mars)" CACHE STRING "Eclipse version" FORCE)
    endif()
    
    # Be more CDT Error Parser friendly..
    if(CMAKE_COMPILER_IS_GNUCC)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0 ")
    endif(CMAKE_COMPILER_IS_GNUCC)
    
    # Generate compile commands json 
    # See https://cmake.org/cmake/help/git-stage/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Enable/Disable output of compile commands during generation.")
## <--
