ENTRY(_start)

MEMORY
{
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 32K   /* instruction memory */
  DMEM (rwx) : ORIGIN = 0x10000000, LENGTH = 32K   /* data memory */
}

SECTIONS
{
  /* Code + constants → IMEM */
  .text : {
    *(.text*)
    *(.rodata*)
  } > IMEM

  /* Initialized globals → DMEM */
  .data : {
    *(.data*)
  } > DMEM

  /* Uninitialized globals (zeroed at startup) → DMEM */
  .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > DMEM

  /* Stack region → DMEM */
  .stack (NOLOAD) : {
    . = ALIGN(16);
    _stack_top = . + 4K;  /* 4 KB stack */
  } > DMEM
}
