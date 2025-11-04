# --- Tool Definitions ---
CC = avr-gcc
OBJCOPY = avr-objcopy
AVRDUDE = avrdude

# --- Project Settings ---
MCU = atmega328p
TARGET = blink

# --- Flashing Settings (CHANGE YOUR PORT if needed) ---
PORT = COM19
BAUD = 115200
# This is the long config file path
AVRDUDE_CONF = "C:\Users\shravana HS\AppData\Local\Arduino15\packages\arduino\tools\avrdude\6.3.0-arduino17\etc\avrdude.conf"

# --- Flags ---
# -Os = Optimize for code size
# -mmcu = Set the target microcontroller
CFLAGS = -Os -mmcu=$(MCU)
LDFLAGS = -mmcu=$(MCU)
OBJCOPY_FLAGS = -O ihex -R .eeprom
AVRDUDE_FLAGS = -C $(AVRDUDE_CONF) -c arduino -p $(MCU) -P $(PORT) -b $(BAUD) -U flash:w:$(TARGET).hex

# --- Build Rules ---

# The default rule (if you just type "make")
# This tells 'make' to build the .hex file as the main goal
all: $(TARGET).hex

# 1. Rule to LINK the .elf file
# Depends on the .o file
$(TARGET).elf: $(TARGET).o
	$(CC) $(LDFLAGS) $^ -o $@

# 2. Rule to COMPILE the .c file
# Depends on the .c file
$(TARGET).o: $(TARGET).c
	$(CC) $(CFLAGS) -c $^ -o $@

# 3. Rule to CONVERT the .elf to .hex
# Depends on the .elf file
$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) $(OBJCOPY_FLAGS) $^ $@

# --- Utility Rules ---

# Rule to FLASH the code to the Arduino
# Depends on 'all' to make sure the .hex is built first
flash: all
	$(AVRDUDE) $(AVRDUDE_FLAGS)

# Rule to CLEAN up all build files
clean:
	rm -f $(TARGET).o $(TARGET).elf $(TARGET).hex