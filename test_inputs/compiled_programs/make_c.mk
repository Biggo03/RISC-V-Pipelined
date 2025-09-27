# make_c.mk — C programs with object files

CC      = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

LINKER  = linker.ld
STARTUP = _start.s
STARTUP_OBJ = $(STARTUP:.s=.o)

# List of program directories
C_DIRS  := $(wildcard c_programs/*)
C_PROGS := $(notdir $(C_DIRS))

# Outputs named after subdir
C_ELFS      := $(foreach p,$(C_PROGS),c_programs/$(p)/$(p).elf)
C_DUMPS     := $(C_ELFS:.elf=.dump)
C_TEXT_HEXS := $(C_ELFS:.elf=.text.hex)
C_DATA_HEXS := $(C_ELFS:.elf=.data.hex)

# Default: build everything
c: $(C_ELFS) $(C_DUMPS) $(C_TEXT_HEXS) $(C_DATA_HEXS)

# Compile startup once
$(STARTUP_OBJ): $(STARTUP)
	$(CC) -c -o $@ $<

# Rule for each ELF: use $@ to locate subdir and base name
$(C_ELFS): $(STARTUP_OBJ) $(LINKER)
	$(CC) -nostdlib -T $(LINKER) -o $@ $(STARTUP_OBJ) $(wildcard $(dir $@)*.c)

# Dump
%.dump: %.elf
	$(OBJDUMP) -D $< > $@

# IMEM hex
%.text.hex: %.elf
	$(OBJCOPY) -O binary -j .text -j .init $< $*.text.bin
	hexdump -v -e '1/4 "%08x\n"' $*.text.bin > $@
	rm -f $*.text.bin

# DMEM hex
%.data.hex: %.elf
	$(OBJCOPY) -O binary -j .rodata -j .data $< $*.data.bin
	hexdump -v -e '1/4 "%08x\n"' $*.data.bin > $@
	rm -f $*.data.bin

# Clean
c-clean:
	rm -f $(STARTUP_OBJ) $(C_ELFS) $(C_DUMPS) $(C_TEXT_HEXS) $(C_DATA_HEXS) \
	      $(foreach d,$(C_DIRS),$(wildcard $(d)/*.o) $(wildcard $(d)/*.bin))

.PHONY: c c-clean
