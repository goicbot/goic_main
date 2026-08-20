cmake_minimum_required(VERSION 3.20)

# ============================================================================
# GOIC ARM GNU TOOLCHAIN
# Cross-platform: Windows / macOS / Linux
# ============================================================================

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Do not try to execute ARM binaries during CMake compiler tests
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ============================================================================
# ARM GNU TOOLCHAIN
# ============================================================================

set(TOOLCHAIN_PREFIX arm-none-eabi-)

find_program(
    ARM_GCC
    NAMES ${TOOLCHAIN_PREFIX}gcc
    REQUIRED
)

find_program(
    ARM_GDB
    NAMES ${TOOLCHAIN_PREFIX}gdb
    REQUIRED
)

find_program(
    ARM_OBJCOPY
    NAMES ${TOOLCHAIN_PREFIX}objcopy
    REQUIRED
)

find_program(
    ARM_OBJDUMP
    NAMES ${TOOLCHAIN_PREFIX}objdump
    REQUIRED
)

find_program(
    ARM_SIZE
    NAMES ${TOOLCHAIN_PREFIX}size
    REQUIRED
)

find_program(
    ARM_AR
    NAMES ${TOOLCHAIN_PREFIX}ar
    REQUIRED
)

find_program(
    ARM_RANLIB
    NAMES ${TOOLCHAIN_PREFIX}ranlib
    REQUIRED
)

# ============================================================================
# CMAKE TOOLCHAIN BINARIES
# ============================================================================

set(CMAKE_C_COMPILER   "${ARM_GCC}")
set(CMAKE_ASM_COMPILER "${ARM_GCC}")

set(CMAKE_AR           "${ARM_AR}")
set(CMAKE_RANLIB       "${ARM_RANLIB}")

set(CMAKE_OBJCOPY      "${ARM_OBJCOPY}")
set(CMAKE_OBJDUMP      "${ARM_OBJDUMP}")
set(CMAKE_SIZE         "${ARM_SIZE}")

set(CMAKE_GDB          "${ARM_GDB}")

# ============================================================================
# DEFAULT ARM FLAGS
# ============================================================================

set(CMAKE_C_FLAGS_INIT
    "-mcpu=cortex-m4 -mthumb"
)

set(CMAKE_ASM_FLAGS_INIT
    "-mcpu=cortex-m4 -mthumb"
)

# ============================================================================
# SEARCH PATH
# ============================================================================

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# ============================================================================
# INFORMATION
# ============================================================================

message(STATUS "")
message(STATUS "==============================================")
message(STATUS " GOIC ARM GNU Toolchain")
message(STATUS "==============================================")
message(STATUS "ARM GCC:     ${ARM_GCC}")
message(STATUS "ARM GDB:     ${ARM_GDB}")
message(STATUS "ARM objcopy: ${ARM_OBJCOPY}")
message(STATUS "ARM size:    ${ARM_SIZE}")
message(STATUS "==============================================")
message(STATUS "")