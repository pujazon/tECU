# Default goal when running 'make' without arguments
.DEFAULT_GOAL := info

# Include local environment configuration (if available)
-include scripts/local_env.cfg

# Include ST-Link flashing module
include make/flasher.mk

# ==============================================================================
# OPERATING SYSTEM DETECTION
# ==============================================================================
ifeq ($(OS),Windows_NT)
    MKDIR = if not exist $(subst /,\,$(1)) mkdir $(subst /,\,$(1))
    RM    = if exist $(subst /,\,$(1)) rmdir /s /q $(subst /,\,$(1))
    TARGET_OS := Windows
else
    MKDIR = mkdir -p $(1)
    RM    = rm -rf $(1)
    TARGET_OS := Linux/macOS
endif

# ==============================================================================
# TOOLCHAIN AND COMPILER DEFINITIONS
# ==============================================================================
PREFIX  = arm-none-eabi-
CXX     = $(PREFIX)g++
CC      = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE    = $(PREFIX)size

# ==============================================================================
# DIRECTORIES AND SOURCE FILES
# ==============================================================================
BUILD_DIR = build
SRC_DIR   = src
INC_DIR   = src/include

SRCS_CXX := $(wildcard $(SRC_DIR)/*.cpp)
SRCS_C   := $(wildcard $(SRC_DIR)/*.c)
SRCS_ASM := $(wildcard $(SRC_DIR)/*.s)

OBJS := $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(SRCS_CXX)) \
        $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS_C)) \
        $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(SRCS_ASM))

TARGET = $(BUILD_DIR)/tECU_firmware

# ==============================================================================
# COMPILER & LINKER FLAGS (Cortex-M4F + C++17 Freestanding)
# ==============================================================================
MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -DSTM32F407xx

INCLUDES  = -I$(SRC_DIR) -I$(INC_DIR)

CXXFLAGS  = $(MCU_FLAGS) -std=c++17 -Wall -Wextra -Werror \
            -fno-exceptions -fno-rtti -fno-threadsafe-statics \
            -ffunction-sections -fdata-sections $(INCLUDES)

CFLAGS    = $(MCU_FLAGS) -Wall -Wextra -ffunction-sections -fdata-sections $(INCLUDES)

LDFLAGS   = $(MCU_FLAGS) -specs=nano.specs -specs=nosys.specs \
            -Wl,--gc-sections

# ==============================================================================
# BUILD RULES
# ==============================================================================
.PHONY: build clean info

## Print helper with available commands
info:
	@echo "============================================================"
	@echo " tECU Firmware Build System (OS: $(TARGET_OS))"
	@echo "============================================================"
	@echo " Usage: make <target>"
	@echo ""
	@echo " Build Targets:"
	@echo "   build        - Compile source files and generate ELF, HEX, and BIN"
	@echo "   clean        - Remove all generated files in build/ directory"
	@echo ""
	@echo " Flashing Targets (ST-Link Serial: $(STLINK_SERIAL)):"
	@echo "   flash        - Flash binary to MCU (default: $(TARGET).bin at 0x08000000)"
	@echo "   flash-debug  - Flash binary with verbose debugging output"
	@echo "   probe        - Query connected ST-Link programmers"
	@echo "   reset        - Reset target MCU via SWD"
	@echo "============================================================"

## Build target binary files (.elf, .hex, .bin)
build: $(TARGET).elf $(TARGET).hex $(TARGET).bin

$(TARGET).elf: $(OBJS)
	@$(call MKDIR, $(BUILD_DIR))
	$(CXX) $(OBJS) $(LDFLAGS) -o $@
	@echo ""
	@echo "--- Target Memory Map (Flash / RAM) ---"
	$(SIZE) $@

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary -S $< $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@$(call MKDIR, $(BUILD_DIR))
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@$(call MKDIR, $(BUILD_DIR))
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@$(call MKDIR, $(BUILD_DIR))
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "Cleaning build directory..."
	@$(call RM, $(BUILD_DIR))