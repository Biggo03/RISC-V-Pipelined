ENTRY(_start)

MEMORY {
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
  DMEM (rwx) : ORIGIN = 0x20000000, LENGTH = 32K
}

/* Define stack pointer at the very top of DMEM */
__stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

SECTIONS {
  /* Code lives in IMEM */
  .text : {
    KEEP(*(.text._start))   /* don’t strip your reset/entry */
    *(.init)                /* startup sections */
    *(.text .text.*)        /* all other code */
  } > IMEM

    /* --- Constants --- */
  .rodata : {
    *(.rodata .rodata.*)
  } > DMEM

  /* --- Initialized variables --- */
  .data : {
    __data_start = .;
    *(.data .data.*)
    __data_end = .;
  } > DMEM

  /* --- Zero-init variables --- */
  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > DMEM

  /* --- Heap region --- */
  . = ALIGN(8);
  __heap_start = .;
  __heap_end   = __stack_top;
}
