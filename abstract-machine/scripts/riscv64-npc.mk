include $(AM_HOME)/scripts/isa/riscv64.mk
include $(NEMU_HOME)/include/config/auto.conf

AM_SRCS := riscv/npc/start.S \
           riscv/npc/trm.c \
           riscv/npc/ioe.c \
           riscv/npc/timer.c \
           riscv/npc/input.c \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
NPCFLAGS += -l $(shell dirname $(IMAGE).elf)/npc-log.txt -f$(IMAGE).elf -b
ifeq ($(CONFIG_DIFFTEST), y)
	REF_SO_FILE = $(abspath $(NEMU_HOME)/build/riscv64-nemu-interpreter-so)
	NPCFLAGS += -d$(REF_SO_FILE)
endif

.PHONY: $(AM_HOME)/am/src/riscv/npc/trm.c

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	make  -C $(NPC_HOME) -s -f $(NPC_HOME)/Makefile ARGS="$(NPCFLAGS)" IMG=$(IMAGE).bin $(MAKECMDGOALS)