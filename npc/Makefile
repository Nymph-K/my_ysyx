TOPNAME = top
#ALL ?= $(basename $(notdir $(shell find /home/k/ysyx-workbench/am-kernels/tests/cpu-tests/tests/. -name "*.c")))Makefile
IMG ?= $(abspath $(shell find /home/k/ysyx-workbench/am-kernels/tests/cpu-tests/build/. -name "*-riscv64-npc.bin"))
NXDC_FILES = constr/top.nxdc
INC_PATH += $(abspath $(shell find $(abspath ./include/) -type d))

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-I./vsrc \
				-O3 --x-assign fast --x-initial fast --noassert --trace

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\"" -g
LDFLAGS += -lSDL2 -lSDL2_image -lreadline

override ARGS ?= --log=$(BUILD_DIR)/npc-log.txt
# override ARGS += $(ARGS_DIFF)
NEMU_EXEC := $(BIN) $(ARGS) $(IMG)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))


all: default

clean:
	rm -rf $(BUILD_DIR)

sim: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "**************sim ***************"
	$(NEMU_EXEC)


run: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "**************run***************"
	$(NEMU_EXEC)

.PHONY: default clean run sim

include ../Makefile
