===========
CMake files
===========

Bunch of macros to simplifying use of CMake in
projects.


Structure of repository
-----------------------

All files in repo witch is started with `"_"` are
private and should not be included in user files
directly. Subdirectory **version** also should
not be included in user files: use macros from
**VersionTargetGenerator.cmake** instead.

**toolchains** folder contains *toolchain*-files. They can
be used throw ``-DCMAKE_TOOLCHAIN_FILE`` flag. See
example of use below.


How to use
----------

Example of usage see in Pastilda project repo:
https://bitbucket.org/thirdpin_team/pastilda

CMAKE_TOOLCHAIN_FILE
~~~~~~~~~~~~~~~~~~~~

Toolchain file provides information about build tools
to CMake. Also it adds some platform and compiler specific
global flags. You can set toolchain file throw
``-DCMAKE_TOOLCHAIN_FILE`` flag:

.. code-block:: bash

    cmake . -GNinja -DCMAKE_TOOLCHAIN_FILE=./cmake/toolchain-clang.cmake


CMake version
~~~~~~~~~~~~~

All files require CMake 3.13 or higher.


How to add it to your project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The best way to add this repo to your project is to
used it as submodule. Some files has inner dependencies.

To add all public files into a scope use ``CMAKE_MODULE_PATH``
variable:

.. code-block:: cmake

    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

where **cmake** is submodule. After that you can include any
file with ``include`` directive:

.. code-block:: cmake

    include(FileWithSomeMacroces)


Preamble
~~~~~~~~

**Preamble.cmake** should be included right after the adding path
to submodule to `CMAKE_MODULE_PATH`. It provides some important
global flags for better integration with IDEs.


Other files
~~~~~~~~~~~

Other files must be included only after the ``project``
directive. Every file contains description of itself.
Use it to better understanding files purpose. Also
use `Pastilda project repo <https://bitbucket.org/thirdpin_team/pastilda>`_
as example of macros usage.

Opencm3 library
~~~~~~~~~~~~~~~

``add_libopencm3_for`` macros from **Opencm3.cmake** can be
used for `Opencm3 library <https://libopencm3.org/>`_ compilation.
Macros usage precondtions is:

- Opencm3 should be a submodule of your project;
- Opencm3 should be located in ``/src/libopencm3``
  folder;
- if your are using Windows you should install WSL
  (`Windows Subsystem for Linux
  <https://docs.microsoft.com/ru-ru/windows/wsl/install-win10>`_

If all requirements are satisfied you can call the macros like
this:

.. code-block:: cmake

    include(Opencm3)
    add_libopencm3_for(f1 f2)

After that two targets will be generated: ``Opencm3::stm32f2`` and
``Opencm3::stm32f1``.
