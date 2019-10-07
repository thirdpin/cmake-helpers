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

# ------------------------------
# Enable C11 and C++17 standards
# ------------------------------

# Use
#
#   common::c11cpp17standards
#
# name to link this library to your target
add_library_with_ns(c11cpp17standards common)

target_compile_features(c11cpp17standards
    INTERFACE
        cxx_std_17
        c_std_11
)
