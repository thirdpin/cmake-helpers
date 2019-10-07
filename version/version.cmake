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


# cmake/gitversion.cmake
# generator version: 1.2.0

cmake_minimum_required(VERSION 3.0.0)
 
message(STATUS "Resolving GIT Version")

set(branch_name "unknown_branch")
set(git_describe "unknown_describe")
set(hash_only "unknown_hash")
set(git_tag "")

find_package(Git)
if(GIT_FOUND)
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory "${output_dir}")

  execute_process(
    COMMAND ${GIT_EXECUTABLE} show -s --format=%h --abbrev=5
    WORKING_DIRECTORY "${output_dir}"
    OUTPUT_VARIABLE hash_only
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} symbolic-ref --short HEAD
    WORKING_DIRECTORY "${output_dir}"
    RESULT_VARIABLE symbolic_ref_result
    OUTPUT_VARIABLE branch_name
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(symbolic_ref_result EQUAL 128)
    set(detached true)
  else()
    set(detached false)
  endif()
  
  if(detached)
    set(branch_name "detached_head")
  endif()
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always --dirty=+ --abbrev=5
    WORKING_DIRECTORY "${output_dir}"
    OUTPUT_VARIABLE git_describe
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  execute_process(
    COMMAND ${GIT_EXECUTABLE} tag --points-at ${hash_only}
    WORKING_DIRECTORY "${output_dir}"
    OUTPUT_VARIABLE git_tag
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
else()
  message(FATAL_ERROR "GIT not found")
endif()

if (NOT "${git_tag}" STREQUAL "")
    message(STATUS "Generation of a tagged release version")
    message(STATUS "Git Tag: ${git_tag}")
    message(STATUS "Commit hash: ${hash_only}")

    set(_build_version "${git_tag}__${hash_only}") 
elseif("${branch_name}" MATCHES "^release/*")
    message(STATUS "Generation of a release version")
    message(STATUS "Commit hash: ${hash_only}")
    message(STATUS "Branch name: ${branch_name}")

    # Remove "release/" from a branch name
    string(REPLACE "release/" "" branch_name "${branch_name}")
    # Set the branch name and a commit hash as a version
    set(_build_version "${branch_name}__${hash_only}")   
else()
    message(STATUS "Generation of a develop version")
    message(STATUS "Git describe: ${git_describe}")
    message(STATUS "Branch name: ${branch_name}")

    # Set a branch name and a git describe response as a version
    set(_build_version "${branch_name}__${git_describe}")
endif()

message(STATUS "Build version: ${_build_version}")

configure_file(${local_dir}/version.h.in ${output_dir}/version.h @ONLY)