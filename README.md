# Understanding the Build Process — Arduino Uno (ATmega328P)

Understanding **how a C program turns into machine code** and runs on an **Arduino Uno**, without using the Arduino IDE.

This repository shows every step of the **bare-metal build process** — from writing a simple LED blink program to generating the `.hex` file and flashing it to the ATmega328P microcontroller using command-line tools.

<p align="center">
  <img src="https://nerdyelectronics.com/wp-content/uploads/2017/07/GCC_CompilationProcess.png" alt="Build Process Banner" width="1000">
</p>

> 🚀 Goal: To demystify what happens behind the “Verify” and “Upload” buttons in the Arduino IDE.

---

##  Build Process Overview

The journey from a C source file to the final machine code on your Arduino Uno involves several stages handled by the **AVR-GCC toolchain**.

Each stage transforms the program into a new format — step by step — until it’s ready to flash into the microcontroller’s flash memory.

| Stage | Purpose | Command | Output |
|:------|:---------|:---------|:--------|
|  **Preprocessing** | Expands `#include` files and macros, removes comments | `avr-gcc -E -mmcu=atmega328p blink.c -o blink.i` | `blink.i` |
|  **Compilation** | Converts C code to AVR assembly | `avr-gcc -S -mmcu=atmega328p blink.c -o blink.s` | `blink.s` |
|  **Assembling** | Assembles assembly code into machine code | `avr-gcc -c -mmcu=atmega328p blink.c -o blink.o` | `blink.o` |
|  **Linking** | Combines object files into one executable | `avr-gcc -mmcu=atmega328p blink.o -o blink.elf` | `blink.elf` |
|  **Objcopy** | Extracts raw data and formats into Intel HEX | `avr-objcopy -O ihex -R .eeprom blink.elf blink.hex` | `blink.hex` |
|  **Flashing** | Uploads the HEX file to Arduino via bootloader | `avrdude -C "<path>/avrdude.conf" -c arduino -p atmega328p -P COM19 -b 115200 -U flash:w:blink.hex` | LED 💡 |

> 🚀 For a detailed block diagram and in-depth explanation of each build stage, refer to [**The Build Stages Explained**](https://github.com/ShravanaHS/understanding-the-c-compiler#2-the-build-process-from-c-to-hex).

---

## 💡 Source Code (blink.c)

<p align="center">
  <img src="https://github.com/ShravanaHS/Register-Level-Programming-With-Arduino-UNO/blob/main/images/Screenshot%202025-10-20%20222104.png" alt="Arduino LED Circuit">
</p>

This is the minimal **bare-metal C program** that toggles the onboard LED (connected to PB5 / Digital Pin 13) on the Arduino Uno.  
It directly manipulates **I/O registers** instead of using the Arduino framework.

> 🔗 **View full source:** [blink.c](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.c)
```c
#include <stdint.h>  // For uint8_t type

#define PORTB_DIR  *((volatile uint8_t*) 0x24)  // Data Direction Register (DDRB) = address is 0x24
#define PORTB_DATA *((volatile uint8_t*) 0x25)  // Output Register (PORTB) = address is 0x25

int main(void) {
    PORTB_DIR = 32; // Set PB5 as output
    while (1) {
        PORTB_DATA = 32;  // LED ON
        for (volatile long i = 0; i < 100000; i++){ PORTB_DATA = 32; } // Delay
        PORTB_DATA = 0;          // LED OFF
        for (volatile long i = 0; i < 100000; i++){ PORTB_DATA = 0; } // Delay
    }
}
```

###  Explanation

| Line | Description |
|------|--------------|
| `#define PORTB_DIR` | Points to **DDRB (0x24)** — controls direction (input/output) |
| `#define PORTB_DATA` | Points to **PORTB (0x25)** — controls output logic level (0/1)|
| `PORTB_DIR = (1 << 5);` | Sets bit 5 (PB5) as output pin |
| `PORTB_DATA = (1 << 5);` | Turns ON the LED |
| `PORTB_DATA = 0;` | Turns OFF the LED |
| `for(...)` | Crude software delay loop |

> **Note:** This direct register approach helps you understand how Arduino’s `digitalWrite()` really works internally.

---

## Toolchain Setup (Windows)


Before building and flashing the code, we need to make sure the **AVR-GCC Toolchain** and **AVRDUDE** are installed and accessible from the terminal.

### 🔹 Step 1 — Locate the Tools Installed by Arduino IDE

When you install the Arduino IDE, it already includes these tools.  
They can be found in your local AppData folder:
```
C:\Users<YourUsername>\AppData\Local\Arduino15\packages\arduino\tools\
```
Inside this folder, locate:
```
avr-gcc\7.3.0-atmel3.6.1-arduino7\bin
avrdude\6.3.0-arduino17\bin
```

### 🔹 Step 2 — Add Both Paths to Environment Variables

1. Press **Windows Key → “Edit the system environment variables”**  
2. Click **Environment Variables…**  
3. Under *System variables*, find and edit **Path**  
4. Click **New**, then paste each of the following lines:

```
C:\Users<YourUsername>\AppData\Local\Arduino15\packages\arduino\tools\avr-gcc\7.3.0-atmel3.6.1-arduino7\bin
C:\Users<YourUsername>\AppData\Local\Arduino15\packages\arduino\tools\avrdude\6.3.0-arduino17\bin
```
5. Click **OK** on all windows.

<p align="center">
<img src="https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/images/envi.png">
</p>

### 🔹 Step 3 — Verify the Installation

Open a **new terminal** and type:

```bash
avr-gcc --version
avrdude --version
```
You should see outputs like:
```
avr-gcc (GCC) 7.3.0
Copyright (C) 2017 Free Software Foundation, Inc.
...
avrdude version 6.3
```
<p align="center">
  <img src="https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/images/terminal.png" alt="AVR Toolchain Setup" width="1000">
</p>

If both work, your setup is complete!

---

## 1️⃣ Preprocessing — `.c` → `.i`

**Purpose:** The C preprocessor expands `#include` files, replaces `#define` macros, evaluates conditional compilation (`#ifdef`), and removes comments. The output is a single "pure" C file with all macros and includes expanded.


### Command (what to run)
```bash
avr-gcc -E -mmcu=atmega328p bare_metal_blink/blink.c -o bare_metal_blink/blink.i
```
### What This Does

- `-E` → tells **avr-gcc** to stop after the **preprocessing** stage.  
- `-mmcu=atmega328p` → selects the **ATmega328P** target so that device-specific headers and macros are correctly processed.  
- The output file **`blink.i`** is a **plain text C file** — open it in your editor to see all `#include` files expanded and macros replaced.

---
### Example Snippet (from `blink.i` — truncated)

```c
/* expanded stdint.h / avr headers ... */
typedef unsigned char uint8_t;
/* ... many device-specific register definitions ... */
#define PORTB _SFR_IO8(0x05)  /* etc. */
...
/* your original code, but with includes and macros expanded */
```

### What to Check / Expected Output

-  A new file **`bare_metal_blink/blink.i`** is created in your project folder.  
- Open **`blink.i`** and verify:
  - The contents of `<stdint.h>` (or at least basic type definitions like `uint8_t`) are visible.  
  - No `#include` lines remain — they’ve been **expanded inline**.  
  - All comments (`//`, `/* */`) are **removed**.  
  - All macros defined using `#define` have been **replaced with their actual values**.
  - **View full source:** [blink.i](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.i)

> 💡 The `.i` file represents your code *after preprocessing* but *before compilation* — it’s a human-readable intermediate step.

---

## 2️⃣ Compilation — `.i` → `.s`

**Purpose:**  
The **compiler** translates the preprocessed C code into **Assembly language** that the **ATmega328P** microcontroller understands.  
This is the first stage where your high-level code begins transforming into low-level instructions.

### Command
```bash
avr-gcc -S -mmcu=atmega328p bare_metal_blink/blink.c -o bare_metal_blink/blink.s
```
### What This Does

- `-S` → tells **avr-gcc** to stop after **compiling**, producing **Assembly output**.  
- `-mmcu=atmega328p` → ensures the assembly is generated for the **correct microcontroller**.  
- Output file **`blink.s`** contains **AVR Assembly instructions** (mnemonics like `ldi`, `out`, `rjmp`, etc.).  
- You can open the `.s` file in your editor to view the generated assembly — it’s **human-readable**.


---

### Example Snippet (from `blink.s` — truncated)

```asm
; Assembly output generated by avr-gcc
.global main
main:
    ldi r24, 0x20       ; Load immediate 0x20 into register r24
    out 0x24, r24        ; Write to DDRB -> Set PB5 as output
.loop:
    sbi 0x05, 5          ; Set bit 5 in PORTB -> LED ON
    call _delay          ; Delay (software loop)
    cbi 0x05, 5          ; Clear bit 5 in PORTB -> LED OFF
    rjmp .loop           ; Repeat forever

```

### What to Check / Expected Output

- A new file **`bare_metal_blink/blink.s`** is created.  
- The file will contain:
  - Function labels such as `_main:`  
  - Assembly instructions like `ldi`, `out`, `sbi`, `cbi`, `rjmp`, etc.  
  - Comments generated by the compiler showing memory sections or optimizations.
  - **View full source:** [blink.s](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.s)
> 💡 The `.s` file represents your code *after Compailation* — it’s a human-readable file.

## 3️⃣ Assembling — `.s` → `.o`

**Purpose:**  
The **assembler** converts the human-readable Assembly file into **machine-readable object code**.  
This object file contains pure **binary instructions** that the microcontroller can execute — but it’s not yet linked into a final program.

### Command
```bash
avr-gcc -c -mmcu=atmega328p bare_metal_blink/blink.s -o bare_metal_blink/blink.o
```
### What This Does

- `-c` → tells **avr-gcc** to compile or assemble the file but **not link** it yet.  
- `-mmcu=atmega328p` → generates the correct machine instructions for the **ATmega328P**.  
- Output file **`blink.o`** is a **binary object file** — not directly readable by humans.  

 You can inspect its contents using:
  ```bash
  avr-objdump -d bare_metal_blink/blink.o
```
```
blink.o:     file format elf32-littlearm

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000053c  00000000  00000000  00000034  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000001  00000000  00000000  00000570  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000054  00000000  00000000  00000574  2**2
                  ALLOC
  3 .rodata       000000c9  00000000  00000000  00000574  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .debug_info   00000472  00000000  00000000  0000063d  2**0
                  CONTENTS, RELOC, READONLY, DEBUGGING, OCTETS
  5 .debug_abbrev 00000232  00000000  00000000  00000aaf  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  6 .debug_aranges 00000020  00000000  00000000  00000ce1  2**0
                  CONTENTS, RELOC, READONLY, DEBUGGING, OCTETS
  7 .debug_line   0000031e  00000000  00000000  00000d01  2**0
                  CONTENTS, RELOC, READONLY, DEBUGGING, OCTETS
  8 .debug_str    000003ce  00000000  00000000  0000101f  2**0
                  CONTENTS, READONLY, DEBUGGING, OCTETS
  9 .comment      00000047  00000000  00000000  000013ed  2**0
                  CONTENTS, READONLY
 10 .debug_frame  000002d8  00000000  00000000  00001434  2**2
                  CONTENTS, RELOC, READONLY, DEBUGGING, OCTETS
 11 .ARM.attributes 0000002e  00000000  00000000  0000170c  2**0
                  CONTENTS, READONLY
```

### What to Check / Expected Output

- A new file **`bare_metal_blink/blink.o`** is created.  
- It’s a **binary file** — opening it directly in an editor will show unreadable characters.  
- To view its contents, use `avr-objdump -d` — you’ll see the **disassembled instructions**.  
- The `.o` file contains:
  - Machine code for your `main()` function.  
  - Symbol information for variables and functions.  
  - Relocation data (used later by the linker).
  - **View full source:** [blink.o](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.o)

> 💡 The `.o` file is a **relocatable object file** — it knows what each function does but doesn’t yet know where in memory it will be placed.

---

## 4️⃣ Linking — `.o` → `.elf`

**Purpose:**  
The **linker** combines one or more object files (`.o`) into a single executable file (`.elf`).  
It resolves **function calls**, **variable references**, and assigns **final memory addresses** to each code and data section.

### What This Does

- The linker takes all relocatable object files (like `blink.o`) and merges them into one final executable.  
- It performs two key operations:
  - **Symbol Resolution:** Finds where each function or variable is defined and links all calls correctly.  
  - **Relocation:** Assigns actual physical memory addresses according to the ATmega328P memory layout.  
- The result is a fully linked **Executable and Linkable Format (ELF)** file, ready to be converted into a HEX file for flashing.

---
```
# Link the object file to create the final ELF executable
avr-gcc -mmcu=atmega328p bare_metal_blink/blink.o -o bare_metal_blink/blink.elf

#Shows the memory mapping
avr-objdump -h bare_metal_blink/blink.elf


# Inspect memory size and sections
avr-size bare_metal_blink/blink.elf

# (Optional) View detailed disassembly with symbol info
avr-objdump -d bare_metal_blink/blink.elf > bare_metal_blink/blink_disassembly.txt
```
### How to Read This

| **Column** | **Meaning** |
|-------------|-------------|
| **Idx** | Section index number |
| **Name** | Section name (`.text`, `.data`, `.bss`, etc.) |
| **Size** | Size of the section in bytes |
| **VMA** | Virtual Memory Address (runtime address in Flash or SRAM) |
| **LMA** | Load Memory Address (where it’s stored initially — Flash for `.data`) |
| **File off** | Offset of section data inside the ELF file |
| **Algn** | Alignment requirement |

---

### Common AVR Sections

| **Section** | **Stored In** | **Purpose** |
|--------------|---------------|-------------|
| `.text` | **Flash** | Program instructions (your code) |
| `.data` | **SRAM (initialized)** | Global/static variables with initial values |
| `.bss` | **SRAM (zero-initialized)** | Global/static variables initialized to 0 |
| `.rodata` | **Flash (read-only)** | Constants and string literals |
| `.debug_*` | **Host only** | Debug information for use with `avr-gdb` |

```
bare_metal_blink/blink.elf:     file format elf32-avr

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000012c  00000000  00000000  00000074  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         00000004  00800060  0000012c  000001a0  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000006  00800064  00000130  000001a4  2**0
                  ALLOC
  3 .comment      0000002b  00000000  00000000  000001a4  2**0
                  CONTENTS, READONLY
  4 .debug_aranges 00000020  00000000  00000000  000001d0  2**0
                  CONTENTS, READONLY, DEBUGGING
  5 .debug_info   000002a1  00000000  00000000  000001f0  2**0
                  CONTENTS, READONLY, DEBUGGING
  ...
```
### ATmega328P Memory Regions

| **Memory Type** | **Start Address** | **End Address** | **Size** | **Purpose** |
|------------------|------------------|----------------|-----------|--------------|
| **Flash (Program Memory)** | `0x0000` | `0x7FFF` | 32 KB | Stores `.text` (code) and `.rodata` (constants) |
| **SRAM (Data Memory)** | `0x0100` | `0x08FF` | 2 KB | Stores `.data`, `.bss`, `heap`, and `stack` |
| **EEPROM** | `0x0000` | `0x03FF` | 1 KB | Non-volatile user data (not part of code execution) |

---

### What to Check / Expected Output

- A new file **`bare_metal_blink/blink.elf`** appears in your project directory.  
- The `.elf` file contains:
  - Final **machine code** with all addresses fixed.  
  - **Symbol tables** and **debug information**.  
  - **Program sections** like `.text`, `.data`, `.bss`, `.stack`, etc.  
- You can check its memory size and sections using `avr-size` or `avr-objdump`.
- **View full source:** [blink.elf](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.elf)

> 💡 The `.elf` file is the **final linked executable** — it’s the complete program image before generating the `.hex` file.


---

## 5️⃣ Conversion — `.elf` → `.hex`

**Purpose:**  
The microcontroller cannot directly execute the `.elf` file because it contains extra debug and symbol data.  
Therefore, the ELF must be converted into a lightweight **Intel HEX (.hex)** format — a simple, line-based encoding of your program’s binary instructions that the bootloader can understand.

---

### What This Does

- Converts the **ELF executable** into an **Intel HEX file**.  
- Removes unnecessary sections like `.eeprom`, `.debug_info`, and `.comment`.  
- The resulting `.hex` file contains **only the flashable program data**.  

---

### What to Check / Expected Output

- A new file **`bare_metal_blink/blink.hex`** appears in your project directory.  
- If you open it in a text editor, it will look like this:
 ```
:100000000C9434000C943B000C943B000C943B00A6
:100010000C943B000C943B000C943B000C943B0068
...
:00000001FF
```
  
- Each line represents memory data in **Intel HEX** format:
  - `:` → Start of record  
  - `10` → Number of data bytes  
  - `0000` → Address in Flash memory  
  - The next bytes → Machine code instructions  
  - The last two → Checksum for verification
  - **View full source:** [blink.hex](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.hex)


---

> 💡 The `.hex` file is the **final deliverable** that the Arduino’s bootloader reads when you upload a sketch.

---

## 🚀 Flashing the HEX File to Arduino Uno

**Purpose:**  
This is the final stage — transferring the compiled and converted **`.hex`** file into the **Flash memory** of the **ATmega328P** microcontroller on your Arduino Uno board.

---

### 🧩 What This Does

- Uses the **AVRDUDE** utility to communicate with the Arduino bootloader over the serial port.  
- Writes the program from the `.hex` file into **Flash memory**.  
- Verifies that the data was written correctly by reading it back.  

---
### Command to Flash the Program

```bash
avrdude -C "C:\Users\shravana HS\AppData\Local\Arduino15\packages\arduino\tools\avrdude\6.3.0-arduino17\etc\avrdude.conf" \
-c arduino -p atmega328p -P COM19 -b 115200 -U flash:w:bare_metal_blink/blink.hex
```
### Command Breakdown

| **Flag** | **Meaning** |
|-----------|-------------|
| `-C` | Specifies the full path to the **`avrdude.conf`** configuration file (needed on Windows). |
| `-c arduino` | Uses the **Arduino bootloader** protocol. |
| `-p atmega328p` | Selects the target microcontroller (**Arduino Uno**). |
| `-P COM19` | Defines the **serial port** (check your own COM port). |
| `-b 115200` | Sets the **baud rate** for communication with the bootloader. |
| `-U flash:w:blink.hex` | Performs a **write operation** to the Flash memory using the specified HEX file. |

---

### Once Executed

- **AVRDUDE** connects to your board through the bootloader.  
- It **erases** the Flash, **writes** your program, and **verifies** it byte by byte.  
- You’ll see the **TX/RX LEDs** blink during upload.  
- The onboard LED will start **blinking** once upload completes successfully. 💡

### 🧾 What to Check / Expected Output

- Your Arduino Uno is connected to the correct **COM port** (e.g., `COM19`).  
- When you flash successfully, the terminal output should show lines like:

  ```
  avrdude: Device signature = 0x1e950f (probably m328p)
  avrdude: writing flash (300 bytes):
  Writing | ################################################## | 100% 0.06s
  avrdude: 300 bytes of flash verified
  avrdude done. Thank you.
  ```


- Once complete, the onboard LED on **Pin 13 (PB5)** will start blinking! 💡  

---

### 💡 Notes

- The `-C` flag in the AVRDUDE command specifies the configuration file path (required on Windows).  
- If AVRDUDE fails to find your device, double-check:
  - The **COM port** number in your Makefile or command.  
  - That the board is properly connected and powered.  
  - That you’ve selected the right **microcontroller (`atmega328p`)**.  

---

> 🧠 The flashing process is what the Arduino IDE normally does automatically — but here you’ve done it manually, step-by-step, gaining full control over how your code is built and programmed.

> 🔗 **View final output files:**  
> [blink.hex](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.hex) • [blink.elf](https://github.com/ShravanaHS/understanding-the-build-process-arduino-uno/blob/main/bare_metal_blink/blink.elf)







