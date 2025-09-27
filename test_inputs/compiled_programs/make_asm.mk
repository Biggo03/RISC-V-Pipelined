# Toolchain
CC      = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

LINKER  = linker.ld

# Find all assembly tests (one per subdirectory)
ASM_DIRS := $(wildcard basic_asm_tests/*)
ASM_SRCS := $(foreach d,$(ASM_DIRS),$(wildcard $(d)/*.s))
ASM_ELFS := $(ASM_SRCS:.s=.elf)
ASM_HEXS := $(ASM_SRCS:.s=.text.hex)
ASM_DUMPS := $(ASM_SRCS:.s=.dump)

# Default: build all assembly tests
asm: $(ASM_ELFS) $(ASM_HEXS) $(ASM_DUMPS)

# ELF from .s
%.elf: %.s $(LINKER)
	$(CC) -nostdlib -T $(LINKER) -o $@ $<

# HEX from ELF
%.text.hex: %.elf
	$(OBJCOPY) -O binary -j .text -j .init $< $*.text.bin
	hexdump -v -e '1/4 "%08x\n"' $*.text.bin > $@
	rm -f $*.text.bin

# DUMP from ELF
%.dump: %.elf
	$(OBJDUMP) -D $< > $@

# Clean
asm-clean:
	rm -f $(ASM_ELFS) $(ASM_HEXS) $(ASM_DUMPS)