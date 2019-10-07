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


# - Macros to add compile and add opencm3 library into a global scope
#
#    add_libopencm3_for(<prefixes...>)
#
# All targets are contant in namespace ``Opencm3``, for example:
#    Opencm3::stm32f1.
#
# This macros depens on ``_CompileOpencm3.cmake`` and 
# ``FindOpencm3.cmake`` files.
#
macro(add_libopencm3_for)

    set(PREFIXES "${ARGN}")

    include(_CompileOpencm3)
    compile_opencm3_for(STM_PREFIX ${ARGN})

    find_package(Opencm3 REQUIRED)

    foreach(STMFx_PREFIX IN LISTS PREFIXES)
        string(TOLOWER ${STMFx_PREFIX} LOWERED_STMFx_PREFIX)
        message(STATUS "Import globally: Opencm3::stm32${LOWERED_STMFx_PREFIX}")
        set_target_properties(Opencm3::stm32${LOWERED_STMFx_PREFIX}
            PROPERTIES
                IMPORTED_GLOBAL TRUE)
    endforeach()

    link_directories(${Opencm3_LINKER_DIRS})

    unset(PREFIXES)

endmacro(add_libopencm3_for)