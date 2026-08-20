#######################################################################################################
# Project:   GOIC Firmware Framework
# Author:    Felipe Gómez
# Compatible with: STM32 / ARM Cortex / Native (Linux, macOS, Windows)
#######################################################################################################

cmake_minimum_required(VERSION 3.20)

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

set(PROJECT_NAME "GOIC_BlackPill_BSP")          # Project name
set(PROJECT_TYPE "exe")                      # exe | static-lib

project(
    ${PROJECT_NAME}
    C
    ASM
)

# =============================================================================
# HOST PLATFORM
# =============================================================================

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")

    message(STATUS "Host: Linux")

elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")

    message(STATUS "Host: macOS")

elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")

    message(STATUS "Host: Windows")

else()

    message(WARNING
        "Unknown host platform: ${CMAKE_HOST_SYSTEM_NAME}"
    )

endif()

# =============================================================================
# TOOLCHAIN INFORMATION
# =============================================================================

if(CMAKE_TOOLCHAIN_FILE)

    message(STATUS
        "Toolchain: ${CMAKE_TOOLCHAIN_FILE}"
    )

endif()

message(STATUS
    "C compiler: ${CMAKE_C_COMPILER}"
)

message(STATUS
    "ASM compiler: ${CMAKE_ASM_COMPILER}"
)

# =============================================================================
# TARGET ARCHITECTURE
# =============================================================================

if(
    CMAKE_SYSTEM_NAME STREQUAL "Generic"
    AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm"
)

    set(IS_ARM TRUE)

    # ARM Cortex-M4
    set(MCPU
        "-mcpu=cortex-m4"
    )

    set(MTHUMB
        "-mthumb"
    )

    set(MFPU
        "-mfpu=fpv4-sp-d16"
    )

    # Keep the same ABI currently used by your project
    set(MFLOAT_ABI
        "-mfloat-abi=softfp"
    )

    set(SYSCALLS
        "--specs=nosys.specs"
    )

    set(
        LINKER_SCRIPT
        "${CMAKE_SOURCE_DIR}/linker/STM32F401RCTX_FLASH.ld"
    )

else()

    set(IS_ARM FALSE)

    set(MCPU "")
    set(MTHUMB "")
    set(MFPU "")
    set(MFLOAT_ABI "")
    set(SYSCALLS "")
    set(LINKER_SCRIPT "")

endif()

# =============================================================================
# REQUIRED FILES
# =============================================================================

if(
    NOT EXISTS
    "${CMAKE_SOURCE_DIR}/Core/Source/system_stm32f4xx.c"
)

    message(FATAL_ERROR
        "Missing Core/Source/system_stm32f4xx.c"
    )

endif()

if(
    NOT EXISTS
    "${CMAKE_SOURCE_DIR}/app/main.c"
)

    message(FATAL_ERROR
        "Missing app/main.c"
    )

endif()

# =============================================================================
# SOURCE COLLECTION
# =============================================================================

file(GLOB_RECURSE PROJECT_SOURCES

    "${CMAKE_SOURCE_DIR}/Core/Source/*.c"

    "${CMAKE_SOURCE_DIR}/Startup/*.s"
    "${CMAKE_SOURCE_DIR}/Startup/*.S"

    "${CMAKE_SOURCE_DIR}/bsp/src/*.c"

    "${CMAKE_SOURCE_DIR}/app/*.c"
)

# =============================================================================
# HEADER COLLECTION
# =============================================================================

file(GLOB_RECURSE PROJECT_HEADERS

    "${CMAKE_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include/*.h"

    "${CMAKE_SOURCE_DIR}/Drivers/CMSIS/Include/*.h"

    "${CMAKE_SOURCE_DIR}/Core/Include/*.h"

    "${CMAKE_SOURCE_DIR}/Drivers/Include/*.h"

    "${CMAKE_SOURCE_DIR}/bsp/inc/*.h"

    "${CMAKE_SOURCE_DIR}/app/*.h"
)

# =============================================================================
# INCLUDE DIRECTORIES
# =============================================================================

set(PROJECT_INCLUDES

    "${CMAKE_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include"

    "${CMAKE_SOURCE_DIR}/Drivers/CMSIS/Include"

    "${CMAKE_SOURCE_DIR}/Core/Include"

    "${CMAKE_SOURCE_DIR}/Drivers/Include"

    "${CMAKE_SOURCE_DIR}/bsp/inc"

    "${CMAKE_SOURCE_DIR}/app"
)

# =============================================================================
# BUILD TYPE
# =============================================================================

if(NOT CMAKE_BUILD_TYPE)

    set(
        CMAKE_BUILD_TYPE
        Debug
        CACHE STRING "Build type"
    )

endif()

message(STATUS
    "Build type: ${CMAKE_BUILD_TYPE}"
)

# =============================================================================
# TARGET
# =============================================================================

if(PROJECT_TYPE STREQUAL "exe")

    add_executable(
        ${PROJECT_NAME}
        ${PROJECT_SOURCES}
    )

elseif(PROJECT_TYPE STREQUAL "static-lib")

    add_library(
        ${PROJECT_NAME}
        STATIC
        ${PROJECT_SOURCES}
    )

else()

    message(FATAL_ERROR
        "Unknown PROJECT_TYPE: ${PROJECT_TYPE}"
    )

endif()

# =============================================================================
# INCLUDE DIRECTORIES
# =============================================================================

target_include_directories(
    ${PROJECT_NAME}
    PRIVATE
        ${PROJECT_INCLUDES}
)

# =============================================================================
# COMPILER OPTIONS
# =============================================================================

target_compile_options(
    ${PROJECT_NAME}
    PRIVATE

        ${MCPU}
        ${MTHUMB}
        ${MFPU}
        ${MFLOAT_ABI}

        -ffunction-sections
        -fdata-sections

        -std=gnu11

        -Wall
        -Wextra
        -Werror
)

# =============================================================================
# DEFINITIONS
# =============================================================================

target_compile_definitions(
    ${PROJECT_NAME}
    PRIVATE

        STM32F401xC
        USE_CMSIS
        DEBUG_BSP
        USE_SYS_TIME
)

# =============================================================================
# LINKER
# =============================================================================

if(IS_ARM)

    if(NOT EXISTS "${LINKER_SCRIPT}")

        message(FATAL_ERROR
            "Linker script not found: ${LINKER_SCRIPT}"
        )

    endif()

    target_link_options(
        ${PROJECT_NAME}
        PRIVATE

            ${MCPU}
            ${MTHUMB}
            ${MFPU}
            ${MFLOAT_ABI}

            "-T${LINKER_SCRIPT}"

            ${SYSCALLS}

            "-Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map"

            "-Wl,--gc-sections"

            -static

            "-Wl,--start-group"
            -lc
            -lm
            "-Wl,--end-group"
    )

endif()

# =============================================================================
# POST BUILD
# =============================================================================

if(IS_ARM)

    set(
        OUTPUT_DIR
        "${CMAKE_BINARY_DIR}/output"
    )

    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD

        COMMENT
            "Generating firmware files in ${OUTPUT_DIR}"

        COMMAND
            ${CMAKE_COMMAND}
            -E make_directory
            "${OUTPUT_DIR}"

        # ELF
        COMMAND
            ${CMAKE_COMMAND}
            -E copy
            "$<TARGET_FILE:${PROJECT_NAME}>"
            "${OUTPUT_DIR}/${PROJECT_NAME}.elf"

        # BIN
        COMMAND
            ${CMAKE_OBJCOPY}
            -O binary
            "$<TARGET_FILE:${PROJECT_NAME}>"
            "${OUTPUT_DIR}/${PROJECT_NAME}.bin"

        # HEX
        COMMAND
            ${CMAKE_OBJCOPY}
            -O ihex
            "$<TARGET_FILE:${PROJECT_NAME}>"
            "${OUTPUT_DIR}/${PROJECT_NAME}.hex"

        # Size
        COMMAND
            ${CMAKE_SIZE}
            "$<TARGET_FILE:${PROJECT_NAME}>"
    )

endif()

# =============================================================================
# SUMMARY
# =============================================================================

message(STATUS "")
message(STATUS "==============================================")
message(STATUS " GOIC Firmware Framework")
message(STATUS "==============================================")
message(STATUS "Project:      ${PROJECT_NAME}")
message(STATUS "Host:         ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "Target:       STM32F401xC")

if(IS_ARM)

    message(STATUS "CPU:          Cortex-M4")
    message(STATUS "FPU:          FPv4-SP-D16")
    message(STATUS "Float ABI:    softfp")
    message(STATUS "Toolchain:    ARM GNU")

else()

    message(STATUS "Target:       Native / Host")

endif()

message(STATUS "Build type:   ${CMAKE_BUILD_TYPE}")
message(STATUS "==============================================")
message(STATUS "")