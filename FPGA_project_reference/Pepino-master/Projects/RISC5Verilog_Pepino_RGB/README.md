Oberon RISC5 for Pepino
=======================

This is a port of the Oberon RISC5 system for the Pepino FPGA board. Both the LX9 and the LX25 version of Pepino are supported.

The original files can be found at the [Project Oberon page](http://www.projectoberon.com/).
Original Project Oberon design and source code copyright � 1991�2015 Niklaus Wirth (NW) and J�rg Gutknecht (JG)

For further information see the [Pepino Wiki page](http://www.saanlima.com/pepino/index.php?title=Welcome_to_Pepino).

Changes from the original code
------------------------------

- A DCM is used generated a 25 MHz system clock and a 75 MHz video clock that are in phase
- The SRAM write signal is genereated using a DDR output buffer
- The DCM in the video module is removed and replaced with a clock input from the main DCM
- SD card activity LED added
- The video system is modifed to 3-bit RGB (each pixel takes up 4 bits in video memory)

Binaries are available in the ISE folder.
