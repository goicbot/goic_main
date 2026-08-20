# DESCRIPTION

### PROJECT NAME: BLACK PILL BSP

### COMPANY: GOIC

### YEAR: 2026

# GOIC Firmware Framework

Portable CMake-based firmware framework for STM32 / ARM Cortex-M projects.

Initial target:

- **MCU:** STM32F401xC
- **Core:** ARM Cortex-M4
- **Host OS:** Windows / macOS / Linux
- **Build system:** CMake + Ninja
- **Toolchain:** ARM GNU Toolchain (`arm-none-eabi-*`)
- **Debugging:** VS Code + Cortex-Debug + OpenOCD + ST-LINK

---

## 1. Project structure

```text
black_pill/
├── App/
├── Bsp/
├── Core/
├── Drivers/
├── Startup/
├── linker/
│
├── CMakeLists.txt
├── CMakePresets.json
├── toolchain-arm-gcc.cmake
│
├── .vscode/
│   ├── settings.json
│   └── launch.json
│
└── build/                  # Generated; do not commit
```

The project keeps the build configuration separated into three main parts:

- `CMakeLists.txt` — project sources, includes, compiler/linker options and output generation.
- `arm-none-eabi.cmake` — ARM GNU toolchain detection and Cortex-M4 toolchain configuration.
- `CMakePresets.json` — portable Debug/Release configurations for CMake and Ninja.

---

## 2. Requirements

Install the following tools and make them available through the system `PATH`:

- CMake >= 3.20
- Ninja
- ARM GNU Toolchain
- Git
- VS Code (optional, for IDE/debugging)
- Cortex-Debug VS Code extension (optional, for debugging)
- OpenOCD (optional, for debugging)
- ST-LINK hardware/debug probe

### Verify the tools

```bash
cmake --version
ninja --version
arm-none-eabi-gcc --version
arm-none-eabi-gdb --version
openocd --version
```

The project intentionally does **not** contain hard-coded OS-specific toolchain paths such as:

```text
/opt/homebrew/...
/Applications/...
C:\Program Files\...
/usr/local/...
```

The tools are discovered through `PATH`, keeping the project portable between Windows, macOS and Linux.

---

## 3. ARM toolchain

The project uses the ARM Embedded GCC toolchain:

```text
arm-none-eabi-gcc
arm-none-eabi-gdb
arm-none-eabi-objcopy
arm-none-eabi-size
arm-none-eabi-ar
arm-none-eabi-ranlib
arm-none-eabi-ld
```

The arm-none-eabi file automatically searches for these programs:

```cmake
find_program(ARM_GCC NAMES arm-none-eabi-gcc REQUIRED)
```

and configures the compiler for:

```text
ARM Cortex-M4
Thumb instruction set
```

The important flags are:

```text
-mcpu=cortex-m4
-mthumb
```

---

## 4. CMake configuration

The project uses CMake with Ninja.

The recommended workflow is through the CMake preset.

### Debug

Configure:

```bash
cmake --preset debug
```

Build:

```bash
cmake --build --preset debug
```

### Release

Configure:

```bash
cmake --preset release
```

Build:

```bash
cmake --build --preset release
```

The presets keep the build configuration reproducible and avoid requiring users to remember long CMake command lines.

---

## 5. Manual CMake configuration

The project can also be configured without presets:

```bash
cmake -S . -B build -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=arm-none-eabi.cmake
```

Then:

```bash
cmake --build build
```

This is useful for troubleshooting or when integrating the project into another build environment.

---

## 6. Generated files

For the Debug configuration, the build directory is:

```text
build/
```

The post-build step generates firmware artifacts in:

```text
build/output/
```

Expected files:

```text
PROJECT_NAME.elf
PROJECT_NAME.bin
PROJECT_NAME.hex
```

### File purposes

| File | Purpose |
|---|---|
| `.elf` | Debugging and symbol information |
| `.bin` | Raw firmware binary |
| `.hex` | Intel HEX firmware image |

The `.elf` file is the main file used by the debugger.

---

## 7. Linker script

The STM32F401xC firmware uses:

```text
linker/STM32F401RCTX_FLASH.ld
```

CMake verifies that the linker script exists before linking.

The linker configuration also enables:

```text
--gc-sections
```

and links against:

```text
libc
libm
```

with:

```text
--specs=nosys.specs
```

---

## 8. Source layout

The current CMake source collection includes:

```text
Core/Source/*.c
Startup/*.s
Bsp/Source/*.c
App/*.c
```

Include directories include:

```text
Drivers/CMSIS/Device/ST/STM32F4xx/Include
Drivers/CMSIS/Include
Core/Include
Bsp/Include
App
```

The project defines:

```text
STM32F401xC
USE_CMSIS
```

---

## 9. VS Code

VS Code is used as the development environment while CMake remains the actual build system.

Required extensions:

- **CMake Tools** — Microsoft
- **C/C++** — Microsoft

For debugging:

- **Cortex-Debug** — marus25

The `.vscode/settings.json` is intentionally kept free of machine-specific paths.

Example:

```json
{
    "cmake.configureOnOpen": true,
    "cmake.useCMakePresets": "always",
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools"
}
```

---

## 10. Debugging

Debugging is intended to use:

```text
VS Code
   ↓
Cortex-Debug
   ↓
arm-none-eabi-gdb
   ↓
OpenOCD
   ↓
ST-LINK
   ↓
STM32F401xC
```

The debug configuration uses:

```text
Interface: SWD
Debugger server: OpenOCD
Target: STM32F401xC
```

The ELF generated by CMake is used as the debugger executable:

```text
build/output/PROJECT_NAME.elf
```

Before starting a debug session, verify:

```bash
arm-none-eabi-gdb --version
openocd --version
```

and make sure the STM32 is connected through ST-LINK.

---

## 11. Important distinction: build vs. debug

CMake/Ninja and the debugger have different responsibilities.

### Build

```text
CMake
  ↓
Ninja
  ↓
ARM GCC
  ↓
ELF / BIN / HEX
```

### Debug

```text
ELF
  ↓
Cortex-Debug
  ↓
GDB
  ↓
OpenOCD
  ↓
ST-LINK
  ↓
STM32
```

A successful CMake build does not automatically mean the debugger is configured, and a debugger configuration does not replace the firmware build.

---

## 12. Cleaning the build

If CMake becomes incorrectly configured, remove the generated build directory:

```bash
rm -rf build
```

Then configure again:

```bash
cmake --preset debug
```

and build:

```bash
cmake --build --preset debug
```

On Windows, remove the `build` directory using the appropriate shell or file explorer.

Do not commit the generated `build/` directory.

---

## 13. Git

The repository should ignore generated build files.

Recommended `.gitignore`:

```gitignore
# CMake
build/
build-*/
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
compile_commands.json
CTestTestfile.cmake
Makefile

# Ninja
.ninja_deps
.ninja_log
rules.ninja

# VS Code local state
.vscode/.cmake/
.vscode/ipch/

# Firmware generated artifacts
*.elf
*.bin
*.hex
*.map

# macOS
.DS_Store
```

Do **not** ignore the project configuration files:

```text
CMakeLists.txt
CMakePresets.json
toolchain-arm-gcc.cmake
.vscode/settings.json
.vscode/launch.json
```

if they are intended to be shared by the project.

---

## 14. First build

From the project root:

```bash
cmake --preset debug
cmake --build --preset debug
```

If successful, the firmware files will be generated under:

```text
build/output/
```

---

## 15. Current development status

Initial project setup completed:

- Cross-platform CMake structure
- ARM GNU Toolchain integration
- Cortex-M4 configuration
- STM32F401xC target configuration
- Ninja generator
- Debug/Release CMake presets
- ELF/BIN/HEX generation
- VS Code integration
- ARM GDB availability
- OpenOCD availability
- ST-LINK debugging setup prepared

### Next step

Complete and verify the first end-to-end debug session:

```text
CMake
→ Ninja
→ ARM GCC
→ ELF
→ Cortex-Debug
→ GDB
→ OpenOCD
→ ST-LINK
→ STM32F401xC
```

---

## License

 MIT License

 Copyright (c) 2026 GOIC Embedded Systems

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

**End of README**
