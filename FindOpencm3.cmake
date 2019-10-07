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


#FindOpencm3.cmake
# 
# Finds the opencm3 library
#
# This will define the following variables
#
#    Opencm3_FOUND
#    Opencm3_INCLUDE_DIRS
#    Opencm3_LINKER_DIRS
#
# and the following imported targets
#
#     Opencm3::stm32fx
#

set(Opencm3_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/src/libopencm3/include)
set(Opencm3_LINKER_DIRS ${CMAKE_SOURCE_DIR}/src/libopencm3/lib)

set(Opencm3_LIBS_NAMES stm32f0 stm32f1 stm32f2 stm32f3 stm32f4 stm32f7)

foreach(LIB ${Opencm3_LIBS_NAMES})

    set(LIBNAME opencm3_${LIB})

    find_library(${LIBNAME}_RESULT
        NAMES ${LIBNAME}
        PATHS ${CMAKE_SOURCE_DIR}/src/libopencm3/lib
        NO_CMAKE_FIND_ROOT_PATH
    )

    if (${LIBNAME}_RESULT)
        message(STATUS "Opencm3 target ${LIB} found.")
        message(STATUS "${${LIBNAME}_RESULT}")

        string(TOUPPER ${LIB} LIB_UPCASE)
        
        add_library(Opencm3::${LIB} STATIC IMPORTED)
        set_target_properties(Opencm3::${LIB} PROPERTIES
            IMPORTED_LOCATION
                ${${LIBNAME}_RESULT}
            INTERFACE_COMPILE_DEFINITIONS
                ${LIB_UPCASE}
            INTERFACE_INCLUDE_DIRECTORIES
                ${Opencm3_INCLUDE_DIRS}
        )

        set(Opencm3_LIBS_FOUND True)
    endif()
endforeach()

mark_as_advanced(Opencm3_FOUND Opencm3_INCLUDE_DIRS)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Opencm3
    REQUIRED_VARS
        Opencm3_INCLUDE_DIRS
        Opencm3_LIBS_FOUND
    FAIL_MESSAGE "Compile libopencm3 first! Run 'make' command from libopencm3 directory. It should produce \
                  'libopencm3_stm32fx.a' library in '${CMAKE_CURRENT_LIST_DIR}/libopencm3/lib' path."
)