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


# - Macros to generate different exe types from elf target
#
#    generate_exes(<elf_target_name>
#       EXE_TYPES <types...>
#    )
#
# It generates custom targets with name ``<elf_target_name>.<type>``
# there ``<type>`` can be hex, srec or bin.
#
macro(generate_exes ELF_TARGET_NAME)

    set(POSSIBLE_EXE_TYPES hex srec bin)

    set(multiValueArgs EXE_TYPES)
    cmake_parse_arguments(ARGS "" "" "${multiValueArgs}" ${ARGN})
    unset(multiValueArgs)

    foreach(EXE_TYPE IN LISTS ARGS_EXE_TYPES)
        # Check if type is valid and get -o argument for it
        if (${EXE_TYPE} IN_LIST POSSIBLE_EXE_TYPES)
            if (${EXE_TYPE} STREQUAL "hex")
                set(EXE_O_ARGUMENT "-Oihex")
            elseif(${EXE_TYPE} STREQUAL "bin")
                set(EXE_O_ARGUMENT "-Obinary")
            elseif(${EXE_TYPE} STREQUAL "srec")
                set(EXE_O_ARGUMENT "-Osrec")
            else()
                message(FATAL_ERROR "${EXE_TYPE} is not valid exe type! \
                                     Use one of ${POSSIBLE_EXE_TYPES}")
            endif()
        else()
            message(FATAL_ERROR "${EXE_TYPE} is not valid exe type! \
                                 Use one of ${POSSIBLE_EXE_TYPES}")
        endif()

        # Generate custom target for a exe generation
        add_custom_target(
            ${ELF_TARGET_NAME}.${EXE_TYPE} ALL
            DEPENDS ${ELF_TARGET_NAME}
            COMMAND ${CMAKE_OBJCOPY} ${EXE_O_ARGUMENT} ${ELF_TARGET_NAME}.elf ${ELF_TARGET_NAME}.${EXE_TYPE}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Generating ${ELF_TARGET_NAME}.${EXE_TYPE}"
        )

        # Clear scope
        unset(EXE_O_ARGUMENT)
    endforeach()

    # Clear scope
    unset(POSSIBLE_EXE_TYPES)
    unset(ARGS_POSSIBLE_EXE_TYPES)

endmacro(generate_exes ELF_TARGET_NAME)