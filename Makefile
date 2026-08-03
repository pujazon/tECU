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
.PHONY: all clean info

all: info $(TARGET).elf $(TARGET).hex $(TARGET).bin

info:
	@echo "--------------------------------------------------"
	@echo " Building tECU on OS: $(TARGET_OS)"
	@echo "--------------------------------------------------"

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

# ============================================================================
# Flash Target (Requires BIN_PATH and FLASH_ADDR parameters)
# ============================================================================

# TODO: Refactor to allow positional arguments (make flash <bin_path> <address>)
#       using MAKECMDGOALS or a wrapper script instead of explicit variable assignments.
.PHONY: flash
flash:
# 1. Check if both mandatory parameters are provided
ifeq ($(strip $(BIN_PATH)),)
	@echo "ERROR: Missing 'BIN_PATH'. Usage: make flash BIN_PATH=<path_to_bin> FLASH_ADDR=<address>" && exit 1
endif

ifeq ($(strip $(FLASH_ADDR)),)
	@echo "ERROR: Missing 'FLASH_ADDR'. Usage: make flash BIN_PATH=<path_to_bin> FLASH_ADDR=<address>" && exit 1
endif

# 2. Check if st-flash CLI tool is available in PATH
	@st-flash --version >NUL 2>&1 || st-flash --version >/dev/null 2>&1 || (echo "ERROR: 'st-flash' not found in PATH. Please run 'setup_env.bat'." && exit 1)

# 3. Perform the flash operation
	@echo "============================================================"
	@echo " Starting flash process..."
	@echo " Binary Path : $(BIN_PATH)"
	@echo " Address     : $(FLASH_ADDR)"
	@echo "============================================================"
	st-flash write $(BIN_PATH) $(FLASH_ADDR)
