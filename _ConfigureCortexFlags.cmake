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


macro(configure_cortex_flags CORTEX_NAME)
    # Flags to prepare code to cleaning by linker
    set(DEAD_CODEDATA_REMOVAL_FLAGS "-fno-common -ffunction-sections -fdata-sections")

    # -fuse-cxa-atexit Register destructors for objects
    # with static storage duration with the _cxa_atexit function rather
    # than the atexit function.
    # This option is required for fully standards-compliant handling 
    # of static destructors, but only works if
    # your C library supports _cxa_atexit.
    #
    # Newlib nano unsupport it so disable it.

    set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} ${DEAD_CODEDATA_REMOVAL_FLAGS}")
    set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${DEAD_CODEDATA_REMOVAL_FLAGS} -fno-rtti -fno-exceptions -fno-unwind-tables -fno-threadsafe-statics")
	set(CMAKE_ASM_FLAGS_INIT "${CMAKE_ASM_FLAGS_INIT} -x assembler-with-cpp")

    if (${CORTEX_NAME} STREQUAL "cortex-m4")

        set(COMPILE_FLAGS
            "-mcpu=cortex-m4 -march=armv7e-m -mthumb \
            -mfloat-abi=hard -mfpu=fpv4-sp-d16"
        )

        set(CMAKE_C_FLAGS_INIT
            "${CMAKE_C_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

        set(CMAKE_CXX_FLAGS_INIT
            "${CMAKE_CXX_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

    elseif (${CORTEX_NAME} STREQUAL "cortex-m3")

        set(COMPILE_FLAGS
            "-mcpu=cortex-m3 -march=armv7-m -mthumb -msoft-float"
        )

        set(CMAKE_C_FLAGS_INIT
            "${CMAKE_C_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

        set(CMAKE_CXX_FLAGS_INIT
            "${CMAKE_CXX_FLAGS_INIT} ${COMPILE_FLAGS}"
        )
        
    elseif (${CORTEX_NAME} STREQUAL "cortex-m0")

        set(COMPILE_FLAGS
            "-mcpu=cortex-m0 -march=armv6-m -mthumb -msoft-float"
        )

        set(CMAKE_C_FLAGS_INIT
            "${CMAKE_C_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

        set(CMAKE_CXX_FLAGS_INIT
            "${CMAKE_CXX_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

    elseif (${CORTEX_NAME} STREQUAL "cortex-a9")

        set(COMPILE_FLAGS
            "-mcpu=cortex-a9 -march=armv7-a -mthumb -mfloat-abi=hard -mfpu=neon"
        )

        set(CMAKE_C_FLAGS_INIT
            "${CMAKE_C_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

        set(CMAKE_CXX_FLAGS_INIT
            "${CMAKE_CXX_FLAGS_INIT} ${COMPILE_FLAGS}"
        )

    else ()
        message(WARNING
            "Processor not recognised, "
            "compiler flags not configured."
        )
    endif ()
    
    set(BUILD_SHARED_LIBS OFF)
endmacro()