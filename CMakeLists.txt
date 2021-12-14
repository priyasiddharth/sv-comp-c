cmake_minimum_required(VERSION 3.18.4)
project(verify-c-common C)

#list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvmir)
#include(LLVMIRUtil)
include(CTest)

enable_testing()

# Enables LLVM builtin functions for memory operations. We do not check these for memory safety.
# To check for memory safety, set this option to OFF. Then our wrappers will be used instead that
# check for memory safety and call builtin functions directly.
#option(SEA_LLVM_MEM_BUILTINS "Use LLVM builtins memcpy/memmove without memory safety checks" OFF)


#option(SEA_ENABLE_FUZZ "Enable fuzzing" OFF)
#option(SEA_WITH_BLEEDING_EDGE "Enable bleeding edge proofs" OFF)

#option(SEA_ENABLE_KLEE "Enable klee" OFF)
#option(SEA_ENABLE_SMACK "Enable SMACK" OFF)

#option(SEA_ALLOCATOR_CAN_FAIL "Use can fail allocator" OFF)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(
    FATAL_ERROR
    "In-source builds are not allowed. Please clean your source tree and try again."
  )
endif()

# Default is release with debug info
if(NOT CMAKE_BUILD_TYPE)
  set(
    CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE
  )
endif()

set(SEAHORN_ROOT "/usr" CACHE PATH "Path to SeaHorn installation")
set(SRC_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
set(SEA_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/seahorn)
set(SEA_CMD ${SEAHORN_ROOT}/bin/sea)
set(SEA_CONFIG $ENV{SEA_YAML} CACHE STRING "path to yaml file for sea yama")
set(SEA_LIB_FILE ${SEA_LIB}/seahorn_stubs.c)
function(sea_add_unsat_test TARGET)
  get_filename_component(SEA_CONFIG_ABS "${SEA_CONFIG}"
                       REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
  add_test(NAME "${TARGET}_unsat_test" COMMAND ${SEA_CMD} yama -y ${SEA_CONFIG_ABS} bpf ${CMAKE_CURRENT_LIST_DIR}/${TARGET}.c ${SEA_LIB_FILE})
  set_tests_properties("${TARGET}_unsat_test" PROPERTIES
    FAIL_REGULAR_EXPRESSION "^sat"
)
endfunction()

function(sea_add_sat_test TARGET)
  get_filename_component(SEA_CONFIG_ABS "${SEA_CONFIG}"
                       REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
  add_test(NAME "${TARGET}_sat_test" COMMAND ${SEA_CMD} yama -y ${SEA_CONFIG_ABS} bpf ${CMAKE_CURRENT_LIST_DIR}/${TARGET}.c ${SEA_LIB_FILE})
  set_tests_properties("${TARGET}_sat_test" PROPERTIES WILL_FAIL TRUE)
  set_tests_properties("${TARGET}_sat_test" PROPERTIES
    FAIL_REGULAR_EXPRESSION "^unsat")
endfunction()



# add subdirectories here
add_subdirectory(bitvector)
