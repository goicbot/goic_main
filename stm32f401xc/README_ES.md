# DESCRIPCIÓN

### NOMBRE DEL PROYECTO: BLACK PILL BSP

### EMPRESA: GOIC

### AÑO: 2026

# GOIC Firmware Framework

Framework de firmware portable basado en CMake para proyectos STM32 / ARM Cortex-M.

Objetivo inicial:

- **MCU:** STM32F401xC
- **Core:** ARM Cortex-M4
- **Sistema operativo host:** Windows / macOS / Linux
- **Sistema de build:** CMake + Ninja
- **Toolchain:** ARM GNU Toolchain (`arm-none-eabi-*`)
- **Debugging:** VS Code + Cortex-Debug + OpenOCD + ST-LINK

---

## 1. Estructura del proyecto

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
└── build/                  # Generado; no debe incluirse en Git
```

El proyecto mantiene la configuración del sistema de build separada en tres componentes principales:

- `CMakeLists.txt` — define los archivos fuente, directorios de inclusión, opciones del compilador/linker y generación de los archivos de salida.
- `toolchain-arm-gcc.cmake` — detecta el ARM GNU Toolchain y configura el toolchain para Cortex-M4.
- `CMakePresets.json` — proporciona configuraciones portables de Debug/Release para CMake y Ninja.

---

## 2. Requisitos

Instala las siguientes herramientas y asegúrate de que estén disponibles a través del `PATH` del sistema:

- CMake >= 3.20
- Ninja
- ARM GNU Toolchain
- Git
- VS Code (opcional, para desarrollo/debugging)
- Extensión Cortex-Debug de VS Code (opcional, para debugging)
- OpenOCD (opcional, para debugging)
- Hardware/debug probe ST-LINK

### Verificar las herramientas

```bash
cmake --version

ninja --version

arm-none-eabi-gcc --version

arm-none-eabi-gdb --version

openocd --version
```

El proyecto intencionalmente **no contiene rutas específicas del sistema operativo**, como:

```text
/opt/homebrew/...

/Applications/...

C:\Program Files\...

/usr/local/...
```

Las herramientas se descubren mediante `PATH`, manteniendo el proyecto portable entre Windows, macOS y Linux.

---

## 3. ARM Toolchain

El proyecto utiliza el ARM Embedded GCC Toolchain:

```text
arm-none-eabi-gcc

arm-none-eabi-gdb

arm-none-eabi-objcopy

arm-none-eabi-size

arm-none-eabi-ar

arm-none-eabi-ranlib

arm-none-eabi-ld
```

El archivo `toolchain-arm-gcc.cmake` busca automáticamente estos programas:

```cmake
find_program(ARM_GCC NAMES arm-none-eabi-gcc REQUIRED)
```

y configura el compilador para:

```text
ARM Cortex-M4

Thumb instruction set
```

Los flags principales son:

```text
-mcpu=cortex-m4

-mthumb
```

---

## 4. Configuración de CMake

El proyecto utiliza CMake con Ninja.

El flujo recomendado es utilizar los presets de CMake.

### Debug

Configurar:

```bash
cmake --preset debug
```

Compilar:

```bash
cmake --build --preset debug
```

### Release

Configurar:

```bash
cmake --preset release
```

Compilar:

```bash
cmake --build --preset release
```

Los presets mantienen la configuración del build reproducible y evitan que los usuarios tengan que recordar comandos largos de CMake.

---

## 5. Configuración manual de CMake

El proyecto también puede configurarse sin utilizar presets:

```bash
cmake -S . -B build -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=toolchain-arm-gcc.cmake
```

Después:

```bash
cmake --build build
```

Esto resulta útil para solucionar problemas o cuando se integra el proyecto en otro entorno de build.

---

## 6. Archivos generados

Para la configuración Debug, el directorio de build es:

```text
build/
```

El paso posterior al build genera los artefactos del firmware en:

```text
build/output/
```

Archivos esperados:

```text
PROJECT_NAME.elf

PROJECT_NAME.bin

PROJECT_NAME.hex
```

### Propósito de cada archivo

| Archivo | Propósito |
|---|---|
| `.elf` | Debugging e información de símbolos |
| `.bin` | Binario de firmware sin formato |
| `.hex` | Imagen de firmware Intel HEX |

El archivo `.elf` es el archivo principal utilizado por el debugger.

---

## 7. Linker Script

El firmware del STM32F401xC utiliza:

```text
linker/STM32F401RCTX_FLASH.ld
```

CMake verifica que el linker script exista antes de realizar el linking.

La configuración del linker también habilita:

```text
--gc-sections
```

y enlaza contra:

```text
libc

libm
```

utilizando:

```text
--specs=nosys.specs
```

---

## 8. Organización del código fuente

La colección actual de archivos fuente de CMake incluye:

```text
Core/Source/*.c

Startup/*.s

Bsp/Source/*.c

App/*.c
```

Los directorios de inclusión incluyen:

```text
Drivers/CMSIS/Device/ST/STM32F4xx/Include

Drivers/CMSIS/Include

Core/Include

Bsp/Include

App
```

El proyecto define:

```text
STM32F401xC

USE_CMSIS
```

---

## 9. VS Code

VS Code se utiliza como entorno de desarrollo, mientras que CMake continúa siendo el sistema de build real.

Extensiones requeridas:

- **CMake Tools** — Microsoft
- **C/C++** — Microsoft

Para debugging:

- **Cortex-Debug** — marus25

El archivo `.vscode/settings.json` se mantiene intencionalmente libre de rutas específicas de la máquina.

Ejemplo:

```json
{
    "cmake.configureOnOpen": true,
    "cmake.useCMakePresets": "always",
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools"
}
```

---

## 10. Debugging

El debugging está diseñado para utilizar:

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

La configuración de debugging utiliza:

```text
Interface: SWD

Debugger server: OpenOCD

Target: STM32F401xC
```

El ELF generado por CMake se utiliza como ejecutable del debugger:

```text
build/output/PROJECT_NAME.elf
```

Antes de iniciar una sesión de debugging, verifica:

```bash
arm-none-eabi-gdb --version

openocd --version
```

y asegúrate de que el STM32 esté conectado mediante ST-LINK.

---

## 11. Distinción importante: Build vs. Debug

CMake/Ninja y el debugger tienen responsabilidades diferentes.

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

Que el build de CMake sea exitoso **no significa automáticamente que el debugger esté configurado**, y la configuración del debugger no reemplaza el build del firmware.

---

## 12. Limpiar el build

Si CMake queda configurado incorrectamente, elimina el directorio de build generado:

```bash
rm -rf build
```

Después vuelve a configurar:

```bash
cmake --preset debug
```

y compila:

```bash
cmake --build --preset debug
```

En Windows, elimina el directorio `build` utilizando el shell correspondiente o el explorador de archivos.

No debes hacer commit del directorio generado `build/`.

---

## 13. Git

El repositorio debe ignorar los archivos generados por el sistema de build.

`.gitignore` recomendado:

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

**No debes ignorar** los archivos de configuración del proyecto:

```text
CMakeLists.txt

CMakePresets.json

toolchain-arm-gcc.cmake

.vscode/settings.json

.vscode/launch.json
```

si están destinados a compartirse con el proyecto.

---

## 14. Primer build

Desde la raíz del proyecto:

```bash
cmake --preset debug

cmake --build --preset debug
```

Si el proceso es exitoso, los archivos del firmware serán generados en:

```text
build/output/
```

---

## 15. Estado actual del desarrollo

Configuración inicial del proyecto completada:

- Estructura CMake cross-platform
- Integración del ARM GNU Toolchain
- Configuración Cortex-M4
- Configuración del target STM32F401xC
- Generador Ninja
- Presets Debug/Release de CMake
- Generación de ELF/BIN/HEX
- Integración con VS Code
- Disponibilidad de ARM GDB
- Disponibilidad de OpenOCD
- Configuración de debugging mediante ST-LINK

### Siguiente paso

Completar y verificar la primera sesión de debugging de extremo a extremo:

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

## Licencia

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

**Fin del README**