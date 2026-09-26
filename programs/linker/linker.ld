/* Linker Script
 * What is done here:
 * 1. _start is defined as the entry label
 * 2. . = x000000000 places the beginning at address 0
 * 3. 4 byte alignment is declared for each of the assebly program sections
 * BSS data also included now
 */


ENTRY(_start)

MEMORY
{
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
  DMEM (rw)  : ORIGIN = 0x10000008, LENGTH = 16376
}

SECTIONS
{
  .text :
  {
    KEEP(*(.text.start))
    *(.text*)
  } > IMEM

  .rodata :
  {
    *(.rodata*)
  } > IMEM

  .data :
  {
    . = ALIGN(4);
    __data_start = .;
    *(.data*)
    . = ALIGN(4);
    __data_end = .;
  } > DMEM

  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > DMEM

  . = ORIGIN(DMEM) + LENGTH(DMEM);
  __stack_top = .;

  /DISCARD/ :
  {
    *(.comment)
    *(.riscv.attributes)
  }
}

