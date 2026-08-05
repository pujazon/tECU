# ==============================================================================
# Flasher Module for ST-Link (st-flash / st-info)
# ==============================================================================

# Ensure STLINK_SERIAL is defined in local_env.cfg or environment
ifndef STLINK_SERIAL
$(error STLINK_SERIAL is not defined! Please set STLINK_SERIAL in your local_env.cfg)
endif

# Default variables if not overridden
BIN_PATH   ?= $(TARGET).bin
FLASH_ADDR ?= 0x08000000

# Base commands with serial filtering
ST_FLASH_CMD := st-flash --serial $(STLINK_SERIAL)
ST_INFO_CMD  := st-info

.PHONY: flash flash-debug probe reset

## Flash binary to target device
flash:
	@echo "============================================================"
	@echo " Starting flash process..."
	@echo " Binary Path : $(BIN_PATH)"
	@echo " Address     : $(FLASH_ADDR)"
	@echo " Serial      : $(STLINK_SERIAL)"
	@echo "============================================================"
	$(ST_FLASH_CMD) write $(BIN_PATH) $(FLASH_ADDR)

## Flash binary with verbose debug output
flash-debug:
	@echo "Starting debug flash process..."
	$(ST_FLASH_CMD) --debug write $(BIN_PATH) $(FLASH_ADDR)

## Probe target device and print system info
probe:
	@echo "Probing connected ST-Link programmers..."
	$(ST_INFO_CMD) --probe

## Reset target MCU
reset:
	@echo "Resetting target MCU..."
	$(ST_FLASH_CMD) reset
