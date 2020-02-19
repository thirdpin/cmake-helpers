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


# - Function to compile opencm3 for differert STM MCUs
#
#    compile_opencm3_for(STM_PREFIX <prefixes...>)
#
# For linking compiled targets use find_package(Opencm3).
# For compiling on Windows you should have WSL installed.
#
function(compile_opencm3_for)
    set(POSSIBLE_STM_PREFIXES f0 f1 f2 f3 f4 f7)
    set(FPV_SUPPORT_STM f4 f7)

    set(multiValueArgs STM_PREFIX)
    cmake_parse_arguments(ARGS "" "" "${multiValueArgs}" ${ARGN})
    unset(multiValueArgs)

    message (STATUS "Compiling opencm3 library for prefixes: ${ARGS_STM_PREFIX}")

    # --> Detect if we have deal with Windows (WSL)
        execute_process(
            COMMAND bash -c "cat /proc/sys/kernel/osrelease"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            ENCODING UTF8
            OUTPUT_VARIABLE OS_RELEASE_STR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        string(TOLOWER ${OS_RELEASE_STR} OS_RELEASE_STR)

        string(FIND
            ${OS_RELEASE_STR}  # [in] string
            "microsoft"        # [in] substring
            MICROSOFT_POS      # [out] position of substring
        )

        if (${MICROSOFT_POS} EQUAL -1)
            set(IS_WSL OFF)
        else()
            set(IS_WSL ON)
        endif()
    # <--

    # --> Check if bash and tool avalibale in environment
        # Get UNIXed path of a sources root
        if (IS_WSL)
            execute_process(
                COMMAND bash -c "wslpath -a ${CMAKE_SOURCE_DIR}"
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                ENCODING UTF8
                RESULT_VARIABLE ERROR_CODE
                OUTPUT_VARIABLE SOURCE_DIR_LINUX_PATH
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            if (${ERROR_CODE} GREATER 0)
                message(FATAL_ERROR "Bash was not found. You should "
                                    "install WSL before run this macros!"
                                    "https://docs.microsoft.com/ru-ru/windows/wsl/install-win10")
            endif()

            message(STATUS "WSL found.")
        else()
            set(SOURCE_DIR_LINUX_PATH ${CMAKE_SOURCE_DIR})
            message(STATUS "Linux found.")
        endif()

        set(LIBOPENCM3_LIB_LINUX_PATH ${SOURCE_DIR_LINUX_PATH}/src/libopencm3)

        # Check if opencm3 lib folder exists
        execute_process(
            COMMAND bash -c "[ -d \"${LIBOPENCM3_LIB_LINUX_PATH}\" ] "
            WORKING_DIRECTORY ${LIBOPENCM3_LIB_LINUX_PATH}
            ENCODING UTF8
            RESULT_VARIABLE ERROR_CODE
            OUTPUT_QUIET
        )

        if (${ERROR_CODE} GREATER 0)
            message(FATAL_ERROR "ERROR: Opencm3 not found by path ${LIBOPENCM3_LIB_LINUX_PATH}!")
        endif()

        message(STATUS "Opencm3 library found: ${LIBOPENCM3_LIB_LINUX_PATH}.")
    # <--

    # Init and update libopencm3 module
    execute_process(
        COMMAND git submodule init
        COMMAND git submodule update
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/libopencm3
    )

    # Apply all patches for libopencm3
    execute_process(
        COMMAND bash -c "[ -z \"$(ls -A ${SOURCE_DIR_LINUX_PATH}/patches/libopencm3)\" ] && \
        echo \"-- No patches found for libopencm3\" ||
        git am ${SOURCE_DIR_LINUX_PATH}/patches/libopencm3/*"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/libopencm3
        ENCODING UTF8
        ERROR_QUIET
    )

    # Calculate optimal count of threads for a compiling
    include(ProcessorCount)
    ProcessorCount(N)
    if(NOT N EQUAL 0)
      set(MAKE_BUILD_FLAGS -j${N})
    endif()

    foreach(STMFx_PREFIX IN LISTS ARGS_STM_PREFIX)
        string(TOLOWER ${STMFx_PREFIX} LOWERED_STMFx_PREFIX)
        
        if (NOT (${STMFx_PREFIX} IN_LIST POSSIBLE_STM_PREFIXES))
            message(FATAL_ERROR "${STMFx_PREFIX} is not valid exe type! \
                                 Use one of: ${POSSIBLE_STM_PREFIXES}.")
        endif()

        message (STATUS "Compiling for stm32${STMFx_PREFIX}...")

        set(MAKE_FLAGS "LANG=en_US.utf8 && CFLAGS='-fstack-usage' && ")
        # Set FP_FLAGS for f4 and f7
        if (STMFx_PREFIX IN_LIST FPV_SUPPORT_STM)
            message(STATUS "FPV enabled for ${STMFx_PREFIX}.")
            string(APPEND MAKE_FLAGS "FP_FLAGS='-mfloat-abi=hard' ")
        endif()

        string(CONCAT MAKE_CMD "${MAKE_FLAGS}"
                               "make "
                                   "${MAKE_BUILD_FLAGS} "
                                   "lib/stm32/${LOWERED_STMFx_PREFIX}")

        execute_process(
            COMMAND bash --login -c ${MAKE_CMD}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/libopencm3
            ENCODING UTF8
        )

        unset(MAKE_FLAGS)
        unset(MAKE_CMD)
    endforeach()

    # Reset patches
    execute_process(
        COMMAND git submodule init
        COMMAND git submodule update
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/libopencm3
    )

    message(STATUS "Opencm3 succesfully compiled for all prefixes.\n")
endfunction(compile_opencm3_for)