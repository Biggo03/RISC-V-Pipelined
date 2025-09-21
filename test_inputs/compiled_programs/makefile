# Top-level path (directory where this Makefile lives)
TOP := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Shared startup and linker files
STARTUP = $(TOP)/_start.s
LINKER  = $(TOP)/linker.ld

# Toolchain
CC      = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

# Compiler flags
CFLAGS  = -march=rv32i -mabi=ilp32 -nostdlib -T $(LINKER)

# All program directories (recursively)
PROGRAM_DIRS := $(shell find . -mindepth 2 -type d | sed 's|^\./||')

# Leaf names only
PROGRAM_NAMES := $(notdir $(PROGRAM_DIRS))

# "all" builds every program by leaf name
all: $(PROGRAM_NAMES:%=build-%)

# Rule to build by leaf name, resolve the full dir path
build-%:
	@dir=$(firstword $(filter %/$*,$(PROGRAM_DIRS))); \
	echo "=== Building $* in $$dir ==="; \
	cd $$dir && \
	if [ -f $*.c ]; then \
		$(CC) $(CFLAGS) -o $*.elf $(STARTUP) $*.c; \
	elif [ -f $*.s ]; then \
		$(CC) $(CFLAGS) -o $*.elf $*.s; \
	else \
		echo "No source file for $*"; exit 0; \
	fi && \
	$(OBJCOPY) -O binary --only-section=.text --only-section=.rodata $*.elf $*.text.bin && \
	od -An -tx4 -w4 -v $*.text.bin > $*.text.hex && \
	$(OBJCOPY) -O binary --only-section=.data --only-section=.bss $*.elf $*.data.bin && \
	od -An -tx4 -w4 -v $*.data.bin > $*.data.hex && \
	$(OBJDUMP) -d $*.elf > $*.dump
	@echo "Built: $$dir/$*.text.hex (IMEM), $$dir/$*.data.hex (DMEM), $$dir/$*.dump"

# Clean everything
clean:
	@for dir in $(PROGRAM_DIRS); do \
		rm -f $$dir/*.elf $$dir/*.bin $$dir/*.hex $$dir/*.dump; \
	done
	@echo "Clean complete."


