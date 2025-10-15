##############################################################################
# Function: Module for building a repo
#    src   - repo path to the source directory (can be empty)
#    tests - repo path to the test directory (can be empty)
#    apps  - repo path to the applications directory (can be empty)
###############################################################################

function(REPO_BUILDER)

   cmake_policy(SET CMP0012 NEW)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   
   message(STATUS "=================================================================================")
   message(STATUS "BUIDING REPO ${target}")
   message(STATUS "=================================================================================")

   if ("$ENV{DOCKER}" STREQUAL "hpc-img")
      #
      # -- cannot run a simple executable using hpc++. Disable compiler check
      #
      set(CMAKE_CUDA_COMPILER_WORKS 1)
      #
      # -- No clue if this actually does anything
      #
      include(/opt/nvidia/hpc_sdk/Linux_x86_64/22.5/cmake/NVHPCConfig.cmake)
      #
      # -- appears library paths must be manually set for hpc 22.5
      #
      project(${target} C CXX CUDA)
      #
      # -- appears library paths must be manually set for hpc 22.5
      #
      set(HPC_LIB_PATH
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/ompi/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/nccl_rdma_sharp_plugin/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/sharp/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/hcoll/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/ucc/lib/ucc
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/ucc/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/ucx/mt/lib/ucx
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/hpcx-2.11/ucx/mt/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/nvshmem/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/nccl/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/math_libs/lib64
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/compilers/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/compilers/extras/qd/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/cuda/extras/CUPTI/lib64
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/cuda/lib64
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/hcoll/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/ompi/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/nccl_rdma_sharp_plugin/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/sharp/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/ucx/mt/lib
         /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/comm_libs/hpcx/latest/ucx/mt/lib/ucx
      )
   else()
      #
      # -- Declare project.
      #
      project(${target} C CXX)
   endif()

   # set(CMAKE_VERBOSE_MAKEFILE ON)
   
   if (CMAKE_CROSSCOMPILING)
      set(THREADS_PTHREAD_ARG "2" CACHE STRING "Forcibly set by CMakeLists.txt." FORCE)
   endif()
   
   message(STATUS "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
   
   if (SDK)
      add_compile_definitions(SDK)
      list(APPEND libraries "boost_chrono")
      # only need CMAKE_TOOLCHAIN_FILE and all the options are set
      set(CMAKE_TOOLCHAIN_FILE "OEToolchainConfig.cmake")
      message(STATUS "Using SDK")
   elseif (GCOV)
      set(GCOV_COMPILE_FLAGS " -fprofile-instr-generate -fcoverage-mapping ")
      set(GCOV_LINK_FLAGS    " -fprofile-instr-generate -fcoverage-mapping ")
      set(CMAKE_CXX_OUTPUT_EXTENSION_REPLACE ON)
      message(STATUS "Using LLVM Coverage")
   endif()

   set(CMAKE_POSITION_INDEPENDENT_CODE ON)
   
   # Conan setup
   include(${PROJECT_SOURCE_DIR}/conanbuildinfo.cmake)
   conan_basic_setup(TARGETS)
   
   # required for "YouCompleteMe". Only works for "Unix Makefiles" and "Ninja"
   set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
   
   # place binaries and libraries according to GNU standards
   include(GNUInstallDirs)
   set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
   set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
   set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
   
   set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -Wfatal-errors -fno-omit-frame-pointer")
   set(CMAKE_COLOR_MAKEFILE ON)
   enable_testing()
   
   # Added for External Projects
   include(ExternalProject)
   
   set(CMAKE_DEBUG_POSTFIX "")
   message(STATUS CMAKE_DEBUG_POSTFIX IS ${CMAKE_DEBUG_POSTFIX})
   message(STATUS CMAKE_PREFIX_PATH IS ${CMAKE_PREFIX_PATH})
   message(STATUS CMAKE_FIND_ROOT_PATH is ${CMAKE_FIND_ROOT_PATH})
   
   message(STATUS "ALL_LIBS_SHARED=${ALL_LIBS_SHARED}")
   
   if (ALL_LIBS_SHARED)
      set(LIB_TYPE "SHARED")
   else()
      set(LIB_TYPE "STATIC")
   endif()
   
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wno-deprecated")
   set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-deprecated")
   
   # For now, install in local self-contained directory, not on system
   # TODO: System install paths if ${CMAKE_INSTALL_PREFIX} = /usr or /usr/local
       set(INSTALL_ROOT      ".")                      # ./
       set(INSTALL_CMAKE     "cmake")                  # ./cmake
       set(INSTALL_EXAMPLES  ".")                      # ./
       set(INSTALL_DATA      ".")                      # ./
       set(INSTALL_BIN       ".")                      # ./
       set(INSTALL_SHARED    "lib")                    # ./lib
       set(INSTALL_LIB       "lib")                    # ./lib
       set(INSTALL_INCLUDE   "include")                # ./include
       set(INSTALL_DOC       "doc")                    # ./doc
       set(INSTALL_SHORTCUTS "misc")                   # ./misc
       set(INSTALL_ICONS     "misc")                   # ./misc
       set(INSTALL_INIT      "misc")                   # ./misc
   
   # Set runtime path
   set(CMAKE_SKIP_BUILD_RPATH            FALSE) # Add absolute path to all dependencies for BUILD
   set(CMAKE_BUILD_WITH_INSTALL_RPATH    FALSE) # Use CMAKE_INSTALL_RPATH for INSTALL, NOT BUILD
   set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) # Do NOT add path to dependencies for INSTALL
   
   # Find libraries relative to binary if we're not building for the appareo GW300.
   if (NOT CMAKE_CROSSCOMPILING)
      set(CMAKE_INSTALL_RPATH "$ORIGIN/${INSTALL_LIB}")
   endif()
   
   #-----------------------------------------------------------------------------
   # Boost settings
   #-----------------------------------------------------------------------------
   
   SET(Boost_USE_STATIC_LIBS ON)
   
   #-----------------------------------------------------------------------------
   # Debug and warnings
   #-----------------------------------------------------------------------------
   
   if (DEBUG)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDEBUG -g")
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUG -g")
   endif()
   
   if (WARNINGS_AS_ERRORS)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")
   endif()
   
   if (MINGW)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libstdc++ -static -Wl,-allow-multiple-definition")
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static-libgcc")
   endif()
   
   #-----------------------------------------------------------------------------
   #  Common External Libraries 
   #-----------------------------------------------------------------------------
   
   if (UNIX)
      list(APPEND EXTERNAL_LIBS "pthread" "rt")
   endif()
   
   #-----------------------------------------------------------------------------
   # set the path to the output directory 
   #-----------------------------------------------------------------------------
   
   if(${XTRA_MSGS})
      message(STATUS "EXTERNAL_INCLUDE_PATH = ${EXTERNAL_INCLUDE_PATH}")
      message(STATUS "EXTERNAL_LIBS =         ${EXTERNAL_LIBS}")
      message(STATUS "EXTERNAL_LIB_PATH =     ${EXTERNAL_LIB_PATH}")
   endif()
   
   get_filename_component(repo_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)

   if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
      add_subdirectory(src)
   else()
      message(STATUS "NOT FOUND: ${CMAKE_CURRENT_SOURCE_DIR}/src")
   endif()

   if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests")
      add_subdirectory(tests)
   else()
      message(STATUS "NOT FOUND: ${CMAKE_CURRENT_SOURCE_DIR}/tests")
   endif()

   if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/apps" AND NOT UNREAL)
      add_subdirectory(apps)
   else()
      if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/apps")
         message(STATUS "NOT FOUND: ${CMAKE_CURRENT_SOURCE_DIR}/apps")
      endif()
   endif()

   if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/deploySchema")
      add_subdirectory(deploySchema)
   else()
      message(STATUS "NOT FOUND: ${CMAKE_CURRENT_SOURCE_DIR}/deploySchema")
   endif()

endfunction()

###############################################################################

###############################################################################
# Macro to fix gtest and boost library specifications
###############################################################################

function(FixConan libraries)
   if ("CONAN_PKG::boost" IN_LIST libraries)
      message("CONAN_PKG::boost is in libraries list, removing!")
      list(REMOVE_ITEM libraries "CONAN_PKG::boost")
      list(APPEND libraries "boost_filesystem")
      list(APPEND libraries "boost_system")
      list(APPEND libraries "boost_random")
      list(APPEND libraries "boost_program_options")
      list(APPEND libraries "boost_date_time")
   endif()
   if ("CONAN_PKG::gtest" IN_LIST libraries)
      list(REMOVE_ITEM libraries "CONAN_PKG::gtest")
      list(APPEND libraries "gtest")
      list(APPEND libraries "gmock")
   endif()
   set(libraries "${libraries}" PARENT_SCOPE)
   message("In FixConan, libraries is now: ${libraries}")
endfunction()


###############################################################################
# Function: BuildApp
#   main  - either main.cpp or main.cu
#   libraries - list of library dependencies
###############################################################################

function(BuildApp main, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING APP ALL PLATFORMS: ${target}")
   
   add_executable( ${target}
      ${CMAKE_CURRENT_SOURCE_DIR}/${main}
   )

   if (GCOV)
      set_target_properties(${target} PROPERTIES 
         COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}"
         LINK_FLAGS    "${GCOV_LINK_FLAGS}"
      )
      set(GCOV_LIB "gcov")
   endif()

   target_link_directories(${target}
      PUBLIC
         ${HPC_LIB_PATH}
   )
   
   FixConan("${libraries}")

   message("After FixConan in BuildApp, libraries is now: ${libraries}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            #-remove-# boost_program_options
            #-remove-# boost_filesystem
            #-remove-# boost_system
            ${EXTERNAL_LIBS}
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            ${GCOV_LIB}
            ${EXTERNAL_LIBS}
      )
   endif ()

   set(deployPath "${CMAKE_CURRENT_SOURCE_DIR}")
   execute_process(COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "deploy" -d ${deployPath})
endfunction()

###############################################################################
# Function: UnitTest_All
#   tests  - list of test fixture files (.cpp)
#   libraries - list of library dependencies
###############################################################################

function(UnitTest_All tests, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING UnitTest ALL PLATFORMS: ${target}")
   
   set(source_path  
      "${CMAKE_CURRENT_SOURCE_DIR}"
   )
   
   set(sources "")

   foreach(test ${tests})
      list(APPEND sources ${source_path}/${test}.cpp)
   endforeach()

   add_executable(${target}
      ${sources}
      /opt/modules/main.cpp
   )
   
   if (GCOV)
      set_target_properties(${target} PROPERTIES 
         COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}"
         LINK_FLAGS    "${GCOV_LINK_FLAGS}"
      )
      set(GCOV_LIB "gcov")
   endif()

   target_include_directories(${target}
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   set(THREAD_LIBS "pthread" "rt")
   
   FixConan("${libraries}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            gtest
            gmock
            ${THREAD_LIBS}
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            ${GCOV_LIB}
            gtest
            gmock
            ${THREAD_LIBS}
      )
   endif ()
endfunction()

###############################################################################
# Function: UnitTest_x86 
#   target - test executable name
#   tests  - list of test fixture files (.cpp)
#   libraries - list of library dependencies
###############################################################################

function(UnitTest_x86 tests, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING UintTest x86: ${target}")
   
   set(source_path  
      "${CMAKE_CURRENT_SOURCE_DIR}"
   )
   
   set(sources "")

   foreach(test ${tests})
      list(APPEND sources ${source_path}/${test}.cpp)
   endforeach()

   add_executable(${target}
      ${sources}
      /opt/modules/main.cpp
   )
   
   set(CONDA_PREFIX $ENV{CONDA_PREFIX})
   message(STATUS "CONDA_PREFIX=${CONDA_PREFIX}")

   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}/share/cmake/pybind11")
   find_package(pybind11 REQUIRED)

   find_package(Python3 3.11 EXACT REQUIRED COMPONENTS Development)

   set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX )

   if (GCOV)
      set_target_properties(${target} PROPERTIES 
         COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}"
         LINK_FLAGS    "${GCOV_LINK_FLAGS}"
      )
      set(GCOV_LIB "gcov")
   endif()

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
         ${CONDA_PREFIX}/include
         ${Python3_INCLUDE_DIRS}

      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   set(THREAD_LIBS "pthread" "rt")
   
   message("libs: ${libraries}")
   FixConan("${libraries}")

   if (NOT SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            ${GCOV_LIB}
            gtest
            gmock
            ${THREAD_LIBS}
            Python3::Python
      )
   else()
      message(STATUS "ERROR: platform not supported")
   endif ()
endfunction()

###############################################################################
# Function: UnitTest_Armv8
#   target - test executable name
#   tests  - list of test fixture files (.cpp)
#   libraries - list of library dependencies
###############################################################################

function(UnitTest_ArmV8 tests, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING UnitTest ArmV8: ${target}")
   
   set(source_path  
      "${CMAKE_CURRENT_SOURCE_DIR}"
   )
   
   set(sources "")

   foreach(test ${tests})
      list(APPEND sources ${source_path}/${test}.cpp)
   endforeach()

   add_executable(${target}
      ${sources}
      /opt/modules/main.cpp
   )
   
   target_include_directories(${target}
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   set(THREAD_LIBS "pthread" "rt")
   
   FixConan("${libraries}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            gtest
            gmock
            ${THREAD_LIBS}
      )
   else()
      message(STATUS "ERROR: platform not supported")
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: StaticLib_Cuda
#   sources     - list of source files having both .h and .cu files
#   headersOnly - list of header only files having only .h files
#   libraries   - list of library dependencies (eg, CONAN_PKG::Monkey)
#
# set_target_properties(particle_test PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
#
###############################################################################

function(StaticLib_Cuda sources, headersOnly, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Static Lib All: ${target}")
   
   message(STATUS "StaticLib_All: ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(specification ${sources})
      list(APPEND specification_list ${specification_path}/${specification}.h)
   endforeach()

   foreach(header ${headersOnly})
      list(APPEND specification_list ${specification_path}/${header}.h)
   endforeach()

   message(STATUS "${specification_list}")

   foreach(implementation ${sources})
      list(APPEND implementation_list ${implementation_path}/${implementation}.cu)
   endforeach()

   message(STATUS "${implementation_list}")

   add_library(${target} STATIC
      ${specification_list}
      ${implementation_list}
   )
   
   set_target_properties(${target}
      PROPERTIES CUDA_SEPARABLE_COMPILATION ON
   )

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (SDK)
      #-remove-# if ("CONAN_PKG::boost" IN_LIST libraries)
	   #-remove-#    list(REMOVE_ITEM libraries "CONAN_PKG::boost")
	   #-remove-#    list(APPEND libraries "boost_filesystem")
	   #-remove-#    list(APPEND libraries "boost_system")
	   #-remove-#    list(APPEND libraries "boost_random")
	   #-remove-#    list(APPEND libraries "boost_program_options")
      #-remove-# endif()

      target_link_libraries(${target}
         PUBLIC
            ${libraries}
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: StaticLib_All
#   sources     - list of source files having both .h and .cpp files
#   headersOnly - list of header only files having only .h files
#   libraries   - list of library dependencies (eg, CONAN_PKG::Monkey)
###############################################################################

function(StaticLib_All sources, headersOnly, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Static Lib All: ${target}")
   
   message(STATUS "StaticLib_All: ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(specification ${sources})
      list(APPEND specification_list ${specification_path}/${specification}.h)
   endforeach()

   foreach(header ${headersOnly})
      list(APPEND specification_list ${specification_path}/${header}.h)
   endforeach()

   message(STATUS "${specification_list}")

   foreach(implementation ${sources})
      list(APPEND implementation_list ${implementation_path}/${implementation}.cpp)
   endforeach()

   message(STATUS "${implementation_list}")

   add_library(${target} STATIC
      ${specification_list}
      ${implementation_list}
   )
   
   set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX )

   if (GCOV)
      set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}")
   endif()

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (SDK)
      #-remove-# if ("CONAN_PKG::boost" IN_LIST libraries)
	   #-remove-#    list(REMOVE_ITEM libraries "CONAN_PKG::boost")
	   #-remove-#    list(APPEND libraries "boost_filesystem")
	   #-remove-#    list(APPEND libraries "boost_system")
	   #-remove-#    list(APPEND libraries "boost_random")
	   #-remove-#    list(APPEND libraries "boost_program_options")
      #-remove-# endif()

      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            #-remove-# ${boost}
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: StaticLib_x86
#   sources     - list of source files having both .h and .cpp files
#   headersOnly - list of header only files having only .h files
#   libraries   - list of library dependencies (eg, CONAN_PKG::Monkey)
###############################################################################

function(StaticLib_x86 sources, headersOnly, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Static Lib All: ${target}")
   
   message(STATUS "StaticLib_All: ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(specification ${sources})
      list(APPEND specification_list ${specification_path}/${specification}.h)
   endforeach()

   foreach(header ${headersOnly})
      list(APPEND specification_list ${specification_path}/${header}.h)
   endforeach()

   message(STATUS "${specification_list}")

   foreach(implementation ${sources})
      if (EXISTS "${implementation_path}/${implementation}.cpp")
         list(APPEND implementation_list ${implementation_path}/${implementation}.cpp)
      elseif (EXISTS "${implementation_path}/${implementation}.cu")
         list(APPEND implementation_list ${implementation_path}/${implementation}.cu)
      endif()
   endforeach()

   message(STATUS "${implementation_list}")


   add_library(${target} STATIC
      ${specification_list}
      ${implementation_list}
   )

   set(CONDA_PREFIX $ENV{CONDA_PREFIX})
   message(STATUS "CONDA_PREFIX=${CONDA_PREFIX}")
   #
   #  Requires that pybind be installed by conda (mamba)
   #  mamba install -c conda-forge pybind11
   #
   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}/share/cmake/pybind11")
   find_package(pybind11 REQUIRED)
   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}/share/cmake/TBB")
   find_package(TBB REQUIRED)

   find_package(Python3 3.11 EXACT REQUIRED COMPONENTS Development)
   #   find_package(Boost REQUIRED COMPONENTS python310)

   set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX )

   if (GCOV)
      set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}")
   endif()

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
         ${CONDA_PREFIX}/include
         ${Python3_INCLUDE_DIRS}
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (NOT SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            TBB::tbb
            Python3::Python
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: SharedLib_x86
#   sources     - list of source files having both .h and .cpp files
#   headersOnly - list of header only files having only .h files
#   libraries   - list of library dependencies (eg, CONAN_PKG::Monkey)
###############################################################################

function(SharedLib_x86 sources, headersOnly, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Shard Lib All: ${target}")
   
   message(STATUS "StaticLib_All: ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(specification ${sources})
      list(APPEND specification_list ${specification_path}/${specification}.h)
   endforeach()

   foreach(header ${headersOnly})
      list(APPEND specification_list ${specification_path}/${header}.h)
   endforeach()

   message(STATUS "${specification_list}")

   foreach(implementation ${sources})
      if (EXISTS "${implementation_path}/${implementation}.cpp")
         list(APPEND implementation_list ${implementation_path}/${implementation}.cpp)
      elseif (EXISTS "${implementation_path}/${implementation}.cu")
         list(APPEND implementation_list ${implementation_path}/${implementation}.cu)
      endif()
   endforeach()

   message(STATUS "${implementation_list}")

   add_library(${target} SHARED
      ${specification_list}
      ${implementation_list}
   )

   set(CONDA_PREFIX $ENV{CONDA_PREFIX})
   message(STATUS "CONDA_PREFIX=${CONDA_PREFIX}")
   #
   #  Requires that pybind be installed by conda (mamba)
   #  mamba install -c conda-forge pybind11
   #
   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}")
   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}/share/cmake/pybind11")
   find_package(pybind11 REQUIRED)
   list(APPEND CMAKE_PREFIX_PATH "${CONDA_PREFIX}/share/cmake/TBB")
   find_package(TBB REQUIRED)


   find_package(Python3 3.11 EXACT REQUIRED COMPONENTS Development)
   #   find_package(Boost REQUIRED COMPONENTS python310)

   set_target_properties(${target} PROPERTIES PREFIX "")
   set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX )

   if (GCOV)
      set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${GCOV_COMPILE_FLAGS}")
   endif()

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
         ${CONDA_PREFIX}/include
         ${Python3_INCLUDE_DIRS}
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (NOT SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            TBB::tbb
            Python3::Python

         PRIVATE
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: StaticLib_Armv8
#   sources     - list of source files having both .h and .cpp files
#   headersOnly - list of header only files having only .h files
#   libraries   - list of library dependencies (eg, CONAN_PKG::Monkey)
###############################################################################

function(StaticLib_Armv8 sources, headersOnly, libraries)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Static Lib All: ${target}")
   
   message(STATUS "StaticLib_All: ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(specification ${sources})
      list(APPEND specification_list ${specification_path}/${specification}.h)
   endforeach()

   foreach(header ${headersOnly})
      list(APPEND specification_list ${specification_path}/${header}.h)
   endforeach()

   message(STATUS "${specification_list}")

   foreach(implementation ${sources})
      list(APPEND implementation_list ${implementation_path}/${implementation}.cpp)
   endforeach()

   message(STATUS "${implementation_list}")

   add_library(${target} STATIC
      ${specification_list}
      ${implementation_list}
   )
   
   set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX )

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (SDK)
      #-remove-# if ("CONAN_PKG::boost" IN_LIST libraries)
	   #-remove-#   list(REMOVE_ITEM libraries "CONAN_PKG::boost")
	   #-remove-#   list(APPEND libraries "boost_filesystem")
	   #-remove-#   list(APPEND libraries "boost_system")
	   #-remove-#   list(APPEND libraries "boost_random")
	   #-remove-#   list(APPEND libraries "boost_program_options")
      #-remove-# endif()

      target_link_libraries(${target}
         PUBLIC
            ${libraries}
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: Mocks_All
#   target - library name of interfaces being mocked
#   mocks  - list of source files having both .h and .cpp files
#
#   NOTE: The expected path for mock specification is:
#		<source_dir>/include/<target_lib>/Mocks
#         The expected path for mock implementation is:
#		<source_dir>/src/Mocks
#
###############################################################################

function(MocksLib mocks)
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   message(STATUS "BUILDING Mocks All: ${target}Mocks for ${target}")

   set(specification_path   "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}/Mocks")
   set(implementation_path  "${CMAKE_CURRENT_SOURCE_DIR}/src/Mocks")

   set(specification_list  "")
   set(implementation_list "")
   
   foreach(mock ${mocks})
      list(APPEND specification_list ${specification_path}/${mock}.h)
      list(APPEND implementation_list ${implementation_path}/${mock}.cpp)
   endforeach()

   add_library(${target}Mocks STATIC
      ${specification_list}
      ${implementation_list}
   )
   
   target_include_directories(${target}Mocks
      PUBLIC
      ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   FixConan("${libraries}")

   if (SDK)
      #-remove-# if ("CONAN_PKG::boost" IN_LIST libraries)
	   #-remove-#    list(REMOVE_ITEM libraries "CONAN_PKG::boost")
	   #-remove-#    list(APPEND boost "boost")
      #-remove-# endif()

      target_link_libraries(${target}Mocks
         PUBLIC
	         ${target}
            ${libraries}
      )
   else ()
	   target_link_libraries(${target}Mocks
         PUBLIC
	         ${target}
            ${libraries}
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: Generate Message Codes
#   Description: Generate the Message Codes from a Schema
#   target   - name of the library
#   schemas  - path to the schema used to generate and build the code
###############################################################################

function(GENERATE_MCODE target, schema)

   set(generator "generator${target}")
   message(STATUS "Lib ${target}")

   set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(source_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")
   set(schema_path "${PROJECT_SOURCE_DIR}/schema")

   file(MAKE_DIRECTORY ${include_path})
   file(MAKE_DIRECTORY ${source_path})

   set(headers "")
   set(sources "")

	list(APPEND headers ${include_path}/${schema}.h)
	list(APPEND sources ${source_path}/${schema}.cpp)

	message(STATUS "schema=${target}/${schema}")
	add_custom_command(
		COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "mcode" -j ${schema_path} -i ${source_path} -s ${include_path} ${target}/${schema}
		OUTPUT ${include_path}/${schema}.h ${source_path}/${schema}.cpp
		DEPENDS ${schema_path}/${target}/${schema}.json
		VERBATIM
	)

   add_custom_target(
      ${generator}
       DEPENDS ${headers} ${sources}
   )

   add_library(${target} STATIC
      ${sources}
      ${headers}
   )

   add_dependencies(${target} ${generator})

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include

      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )

   get_filename_component(FOLDER_NAME ${CMAKE_SOURCE_DIR} NAME)
   message(STATUS "Last folder name is: ${FOLDER_NAME}")

   set(generatorlibs "")

   message(STATUS "ARG2=${ARG2}")

   if (NOT ARGV2)
      list(APPEND generatorlibs "CONAN_PKG::Framework")
   else()
      list(APPEND generatorlibs "CommonUtilities")
   endif()

   list(APPEND generatorlibs "CONAN_PKG::g3log")
   message(STATUS "generatorlibs=${generatorlibs}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${generatorlibs}
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${generatorlibs}
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: Generate_wLibs
#   Description: Generate the Message Contracts from Schemas
#   target   - name of the library
#   schemas  - path to the schema used to generate and build the code
#   libraries - list of dependent libraries
###############################################################################

function(GENERATE_WLIBS target, schemas, libraries)
    # Parse optional arguments
    set(oneValueArgs LIBRARIES)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})


    # message(STATUS "isPNFRepo=${isPNFRepo}")

   set(generator "generator${target}")
   
   message(STATUS "Lib ${target}")
   message(STATUS "generator ${generator}")
   
   set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(source_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")
   set(schema_path "${PROJECT_SOURCE_DIR}/schema")
   
   file(MAKE_DIRECTORY ${include_path})
   file(MAKE_DIRECTORY ${source_path})
   
   set(headers "")
   set(sources "")
   
   foreach(schema ${schemas})
      list(APPEND headers ${include_path}/${schema}.h)
      list(APPEND sources ${source_path}/${schema}.cpp)
   endforeach()
   
   foreach(schema ${schemas})
      message(STATUS "schema=${target}/${schema}")
      add_custom_command(
         COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "cpp+" -j ${schema_path} -i ${source_path} -s ${include_path} ${target}/${schema}
         OUTPUT ${include_path}/${schema}.h ${source_path}/${schema}.cpp
         DEPENDS ${schema_path}/${target}/${schema}.json
         VERBATIM
      )
   endforeach()
   
   add_custom_target(
      ${generator}
       DEPENDS ${headers} ${sources}
   )
   
   add_library(${target} STATIC
      ${sources}
      ${headers}
   )
   
   add_dependencies(${target} ${generator})
   
   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )

   get_filename_component(FOLDER_NAME ${CMAKE_SOURCE_DIR} NAME)
   message(STATUS "Last folder name is: ${FOLDER_NAME}")

   set(generatorlibs "")

   if (NOT "${FOLDER_NAME}" STREQUAL "Framework")
      if (${PROJECT_NAME} STREQUAL "PrinterNetworkFramework")
         list(APPEND generatorlibs "PrinterNetworkFramework")
      else()
         if (NOT ${PROJECT_NAME} STREQUAL "MessageContracts")
             list(APPEND generatorlibs "CONAN_PKG::MessageContracts")
         endif()
      
         list(APPEND generatorlibs "CONAN_PKG::PrinterNetworkFramework")
      endif()
      
       list(APPEND generatorlibs "CONAN_PKG::Framework")
   else()
      list(APPEND generatorlibs "MessageFramework")
      list(APPEND generatorlibs "Framework")
   endif()

   message("Libraries are: ${ARG_LIBRARIES}")
   message(STATUS "libraries=${libraries}")

   if(ARG_LIBRARIES)
      list(APPEND generatorlibs "${ARG_LIBRARIES}")
   endif()

   list(APPEND generatorlibs "boost_filesystem")
   list(APPEND generatorlibs "boost_system")

   message(STATUS "GENERATE(${target},${schemas}): generatorlibs=${generatorlibs}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            ${generatorlibs}
         
         INTERFACE
      )
   else ()

      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            ${generatorlibs}
         
         INTERFACE
      )
   endif ()
endfunction()

###############################################################################
# Function: Generate
#   Description: Generate the Message Contracts from Schemas
#   target   - name of the library
#   schemas  - path to the schema used to generate and build the code
###############################################################################

function(GENERATE target, schemas)
    # Parse optional arguments
    set(oneValueArgs LIBRARIES)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})


    # message(STATUS "isPNFRepo=${isPNFRepo}")

   set(generator "generator${target}")
   
   message(STATUS "Lib ${target}")
   message(STATUS "generator ${generator}")
   
   set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(source_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")
   set(schema_path "${PROJECT_SOURCE_DIR}/schema")
   
   file(MAKE_DIRECTORY ${include_path})
   file(MAKE_DIRECTORY ${source_path})
   
   set(headers "")
   set(sources "")
   
   foreach(schema ${schemas})
      list(APPEND headers ${include_path}/${schema}.h)
      list(APPEND sources ${source_path}/${schema}.cpp)
   endforeach()
   
   foreach(schema ${schemas})
      message(STATUS "schema=${target}/${schema}")
      add_custom_command(
         COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "cpp+" -j ${schema_path} -i ${source_path} -s ${include_path} ${target}/${schema}
         OUTPUT ${include_path}/${schema}.h ${source_path}/${schema}.cpp
         DEPENDS ${schema_path}/${target}/${schema}.json
         VERBATIM
      )
   endforeach()
   
   add_custom_target(
      ${generator}
       DEPENDS ${headers} ${sources}
   )
   
   add_library(${target} STATIC
      ${sources}
      ${headers}
   )
   
   add_dependencies(${target} ${generator})
   
   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )

   get_filename_component(FOLDER_NAME ${CMAKE_SOURCE_DIR} NAME)
   message(STATUS "Last folder name is: ${FOLDER_NAME}")

   set(generatorlibs "")

   if (NOT "${FOLDER_NAME}" STREQUAL "Framework")
      if (${PROJECT_NAME} STREQUAL "PrinterNetworkFramework")
         list(APPEND generatorlibs "PrinterNetworkFramework")
      else()
         if (NOT ${PROJECT_NAME} STREQUAL "MessageContracts")
             list(APPEND generatorlibs "CONAN_PKG::MessageContracts")
         endif()
      
         list(APPEND generatorlibs "CONAN_PKG::PrinterNetworkFramework")
      endif()
      
       list(APPEND generatorlibs "CONAN_PKG::Framework")
   else()
      list(APPEND generatorlibs "MessageFramework")
      list(APPEND generatorlibs "Framework")
   endif()

   message("Libraries are: ${ARG_LIBRARIES}")

   if(ARG_LIBRARIES)
      list(APPEND generatorlibs "${ARG_LIBRARIES}")
   endif()

   list(APPEND generatorlibs "boost_filesystem")
   list(APPEND generatorlibs "boost_system")

   message(STATUS "GENERATE(${target},${schemas}): generatorlibs=${generatorlibs}")

   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${generatorlibs}
         
         INTERFACE
      )
   else ()

      target_link_libraries(${target}
         PUBLIC
            ${generatorlibs}
         
         INTERFACE
      )
   endif ()
endfunction()

#=============================================================================

###############################################################################
# Function: Generate_Base
#   Description: Generate the Message Contracts from Schemas
#   target    - name of the library
#   schema    - path to the schema used to generate and build the code
#   libraries - list of dependent libraries
###############################################################################

function(GENERATE_BASE target, schema, libraries)

   set(generator "generator${target}")
   
   message(STATUS "Lib ${target}")
   message(STATUS "generator ${generator}")
   
   set(schema_path "${CMAKE_CURRENT_SOURCE_DIR}/schema/")
   set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
   set(source_path   "${CMAKE_CURRENT_SOURCE_DIR}/src")
   
   file(MAKE_DIRECTORY ${include_path})
   file(MAKE_DIRECTORY ${source_path})

   set(headers "")
   set(sources "")
   
   foreach(schema ${schemas})
      list(APPEND headers ${include_path}/${schema}.h  ${include_path}/Mock${schema}.h)
      list(APPEND sources ${source_path}/${schema}.cpp ${source_path}/Mock${schema}.cpp)
   endforeach()
   
   foreach(schema ${schemas})
      message(STATUS "schema=${schema}")
      add_custom_command(
         COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "base+" -j ${schema_path} -i ${source_path} -s ${include_path} ${schema}
         OUTPUT ${include_path}/${schema}.h ${source_path}/${schema}.cpp ${include_path}/Mock${schema}.h ${source_path}/Mock${schema}.cpp
         DEPENDS ${schema_path}/${schema}.json
         VERBATIM
      )
   endforeach()
   
   add_custom_target(
      ${generator}
       DEPENDS ${headers} ${sources}
   )
   
   message(STATUS "target=${target}")
   message(STATUS "libraries=${libraries}")
   message(STATUS "sources=${sources}")
   message(STATUS "headers=${headers}")

   add_library(${target} STATIC
      ${sources}
      ${headers}
   )
   
   add_dependencies(${target} ${generator})
   
   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )
   
   if (SDK)
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            CONAN_PKG::PrinterNetworkFramework
            boost_filesystem
            boost_system
         
         INTERFACE
      )
   else ()
      target_link_libraries(${target}
         PUBLIC
            ${libraries}
            CONAN_PKG::PrinterNetworkFramework
            boost_filesystem
            boost_system
         
         INTERFACE
      )
   endif ()

endfunction()

###############################################################################
# Function: Generate_CSV
#   Description: Generate CSV serializer for message contract
#   
#   target    - name of the generated library
#   schemas   - list of paths to message contracts to generate CSV serializers for
#   libraries - list of dependent libraries
###############################################################################

function(GENERATE_CSV target, schemas, libraries)

   set(generator "generatorCSV")
   
   message(STATUS "CSV Serializer")
   message(STATUS "generator ${generator}")

   set(schema_full_path ${PROJECT_SOURCE_DIR}/schema/${schema}.json)

   message("schema full path: ${schema_full_path}")

   get_filename_component(schema_json ${schema_full_path} NAME) 

   message("schema filename: ${schema_json}")
   
      set(schema_path "${PROJECT_SOURCE_DIR}/schema/${schema}")
      set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
      set(source_path   "${CMAKE_CURRENT_SOURCE_DIR}/src")
      
      file(MAKE_DIRECTORY ${include_path})
      file(MAKE_DIRECTORY ${source_path})
   
      set(headers "")
      set(sources "")
      
      foreach(schema ${schemas})
         get_filename_component(schema_basename ${schema} NAME)
         list(APPEND headers ${include_path}/CSV${schema_basename}.h)
         list(APPEND sources ${source_path}/CSV${schema_basename}.cpp)
      endforeach()
      
      foreach(schema ${schemas})
         message(STATUS "schema=${schema}")

         get_filename_component(schema_basename ${schema} NAME)
         message("for loop schema basename: ${schema_basename}")

         add_custom_command(
            COMMAND java -Dfile.encoding=UTF-8 -jar /usr/bin/MessageCGTool.jar -x "cpp+csv" -j ${schema_path} -i ${source_path} -s ${include_path} ${schema}
            OUTPUT ${include_path}/CSV${schema_basename}.h ${source_path}/CSV${schema_basename}.cpp
            #DEPENDS ${schema_path}/${schema_json}.json
            DEPENDS ${PROJECT_SOURCE_DIR}/schema/${schema}.json
            VERBATIM
         )
      endforeach()
      
      add_custom_target(
         ${generator}
          DEPENDS ${headers} ${sources}
      )
      
      message(STATUS "libraries=${libraries}")
      message(STATUS "sources=${sources}")
      message(STATUS "headers=${headers}")
   
      add_library(${target} STATIC
         ${sources}
         ${headers}
      )
      
      add_dependencies(${target} ${generator})
      
      target_include_directories(${target}
         PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/include
      
         INTERFACE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<INSTALL_INTERFACE:include/${target}>
      )
      
      if (SDK)
         target_link_libraries(${target}
            PUBLIC
               ${libraries}
               CONAN_PKG::PrinterNetworkFramework
               boost_filesystem
               boost_system
            
            INTERFACE
         )
      else ()
         target_link_libraries(${target}
            PUBLIC
               ${libraries}
               CONAN_PKG::PrinterNetworkFramework
               boost_filesystem
               boost_system
            
            INTERFACE
         )
      endif ()

endfunction()

###############################################################################
# Function: SWIG
#   Description: Generate python and C++ bindings for python
#   target   - name of the library
#   schemas  - path to the schema used to generate and build the code
###############################################################################
function(SWIG pairs, libraries)
   #---------------------------------------------------------------------------
   # First argument uses '/' as a delimiter between library and filename
   # CMake thinks its a path and thru magic deletes the strings.
   # To make all our function interfaces the same, that is, "${arg}", which causes 
   # cmake to render it into an empty string, we use the following command 
   # to skirt the issue:
   #     set(libClass ${ARGV0}
   #
   #---------------------------------------------------------------------------
   set(libClass ${ARGV0})

   #
   # Use CMake to get the directory name as the target name
   #
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   
   #
   # CMake wants a target name for the generator
   #
   set(generator "generator${target}")

   set(dependents "")

   foreach(item ${libClass})
      string(REPLACE "/" ";" pair ${item})
      list(GET pair 0 library)
      list(GET pair 1 filename)
      list(APPEND  dependents ${library}/include/${library}/${filename}.h)
   endforeach()

   set(source_path    "${CMAKE_CURRENT_SOURCE_DIR}/src")
   set(schema_path    "${CMAKE_CURRENT_SOURCE_DIR}/schema")

   #
   # No headers are used with swig
   # Only one source is required
   #
   set(sources "")
   list(APPEND sources ${source_path}/${target}.cpp)

   message(STATUS "sources=${sources}")

   #
   #  Run the swig command for the schema
   #
   message(STATUS "COMMAND swig -python -c++ -o ${source_path}/${target}.cpp ${schema_path}/${target}.i")
   add_custom_command(
      COMMAND swig -python -c++ -o ${source_path}/${target}.cpp ${schema_path}/${target}.i
      OUTPUT ${source_path}/${target}.cpp
      DEPENDS ${schema_path}/${target}.i
      VERBATIM
   )

   #
   # Don't understand why but need to link the generator with the source files
   # Probably need to rebuild if the sources change?
   #
   add_custom_target(
      ${generator} DEPENDS ${sources}
   )
   
   #
   # The rest below is standard shared library instructions
   #

   add_library(${target} SHARED
      ${sources}
   )
   
   add_dependencies(${target} ${generator})
   
   set_target_properties(${target} PROPERTIES PREFIX "")
   set_target_properties(${target} PROPERTIES OUTPUT_NAME "_${target}")

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )

   target_link_libraries(${target}
      PUBLIC
         ${libraries}
   )
endfunction()

#=============================================================================

###############################################################################
# Function: pybind11
#   Description: 
#   target   - name of the library
#   schemas  - path to the schema used to generate and build the code
###############################################################################
function(PyBind11 pairs, libraries)
   #---------------------------------------------------------------------------
   # First argument uses '/' as a delimiter between library and filename
   # CMake thinks its a path and thru magic deletes the strings.
   # To make all our function interfaces the same, that is, "${arg}", which causes 
   # cmake to render it into an empty string, we use the following command 
   # to skirt the issue:
   #     set(libClass ${ARGV0}
   #
   #---------------------------------------------------------------------------
   set(libClass ${ARGV0})

   #
   # Use CMake to get the directory name as the target name
   #
   get_filename_component(target ${CMAKE_CURRENT_SOURCE_DIR} NAME)
   
   #
   # CMake wants a target name for the generator
   #
   set(generator "generator${target}")

   set(dependents "")

   foreach(item ${libClass})
      string(REPLACE "/" ";" pair ${item})
      list(GET pair 0 library)
      list(GET pair 1 filename)
      list(APPEND  dependents ${library}/include/${library}/${filename}.h)
   endforeach()

   set(source_path    "${CMAKE_CURRENT_SOURCE_DIR}/src")
   set(schema_path    "${CMAKE_CURRENT_SOURCE_DIR}/schema")

   #
   # No headers are used with swig
   # Only one source is required
   #
   set(sources "")
   list(APPEND sources ${source_path}/${target}.cpp)

   message(STATUS "sources=${sources}")

   #
   #  Run the swig command for the schema
   #
   message(STATUS "COMMAND swig -python -c++ -o ${source_path}/${target}.cpp ${schema_path}/${target}.i")
   add_custom_command(
      COMMAND swig -python -c++ -o ${source_path}/${target}.cpp ${schema_path}/${target}.i
      OUTPUT ${source_path}/${target}.cpp
      DEPENDS ${schema_path}/${target}.i
      VERBATIM
   )

   #
   # Don't understand why but need to link the generator with the source files
   # Probably need to rebuild if the sources change?
   #
   add_custom_target(
      ${generator} DEPENDS ${sources}
   )
   
   #
   # The rest below is standard shared library instructions
   #

   add_library(${target} SHARED
      ${sources}
   )
   
   add_dependencies(${target} ${generator})
   
   set_target_properties(${target} PROPERTIES PREFIX "")
   set_target_properties(${target} PROPERTIES OUTPUT_NAME "_${target}")

   target_include_directories(${target}
      PUBLIC
         ${CMAKE_CURRENT_SOURCE_DIR}/include
   
      INTERFACE
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include/${target}>
   )

   target_link_libraries(${target}
      PUBLIC
         ${libraries}
   )
endfunction()

#=============================================================================
