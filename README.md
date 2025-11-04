# Understanding the Build Process — Arduino Uno (ATmega328P)

A complete guide to understanding **how a C program turns into machine code** and runs on an **Arduino Uno**, without using the Arduino IDE.

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

> 🚀 For a detailed block diagram and in-depth explanation of each build stage, refer to [**The Build Stages Explained**](https://github.com/ShravanaHS/understanding-the-c-compiler#31-the-build-stages-explained).

---

## 💡 Source Code (blink.c)

<p align="center">
  <img src="https://github.com/ShravanaHS/Register-Level-Programming-With-Arduino-UNO/blob/main/images/Screenshot%202025-10-20%20222104.png" alt="Arduino LED Circuit">
</p>

This is the minimal **bare-metal C program** that toggles the onboard LED (connected to PB5 / Digital Pin 13) on the Arduino Uno.  
It directly manipulates **I/O registers** instead of using the Arduino framework.

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


