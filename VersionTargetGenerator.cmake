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


# - Macros to generate version target for project
#
#    add_version_target(<project_name>)
#
# After this macros is called there is appears ``<project_name>::version``
# in a scope. It should be linked to a main target of project to 
# generate version during building.
#
# Version file called ``version.h`` will be located in
# ``<project_name>/include/<project_name>`` folder.
#
macro(add_version_target PROJECT_NAME_)

    # Generate custom target for a version generation
    add_custom_target(
        ${PROJECT_NAME_}_custom_target_version
        DEPENDS ${CMAKE_MODULE_PATH}/version/version.h.in
        COMMAND ${CMAKE_COMMAND}
            -Dlocal_dir="${CMAKE_MODULE_PATH}/version/"
            -Doutput_dir="${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME_}"
            -P "${CMAKE_MODULE_PATH}/version/version.cmake"
        COMMENT "Generating </${PROJECT_NAME_}/include/${PROJECT_NAME_}/version.h>"
    )

    # Add interface include custom version target from above
    add_library(${PROJECT_NAME_}_version INTERFACE)
    add_dependencies(${PROJECT_NAME_}_version ${PROJECT_NAME_}_custom_target_version)

    # Make pretty alias for interface above
    add_library(${PROJECT_NAME_}::version ALIAS ${PROJECT_NAME_}_version)

endmacro(add_version_target PROJECT_NAME_)