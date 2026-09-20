/* Linker Script
 * What is done here:
 * 1. _start is defined as the entry label
 * 2. . = x000000000 places the beginning at address 0
 * 3. 4 byte alignment is declared for each of the assebly program sections
 */
ENTRY(_start)

SECTIONS
{
  . = 0x000000000;
  .text : ALIGN(4)
  {
    *(.text.start)
    *(.text*)
  }

  .rodata : ALIGN(4)
  {
    *(.rodata*)
  }

  .data : ALIGN(4)
  {
    *(.data)
  }

  .bss : ALIGN(4)
  {
    *(.bss*)
    *(COMMON)
  }
}
