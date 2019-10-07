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


# - Macros to add executable with elf prefix
#
#    add_executable_elf(<target_name> <sources...>)
#
macro(add_executable_elf TARGET_NAME)

add_executable(${TARGET_NAME}
    ${ARGN}
)

set_target_properties(${TARGET_NAME}
    PROPERTIES
        SUFFIX ".elf"
)

endmacro(add_executable_elf TARGET_NAME)