.. _usb_device_design_guide:

Overview
========

This document describes the XMOS USB Device Library, its API and provides a worked
example of a USB Human Interface Device (HID) Class compliant mouse using the
library. This library is aimed primarily for use with xCORE-USB (U-Series) 
devices but it does also support L-Series devices (see :ref:`l_series_support`).

This document assumes familiarity with the XMOS xCORE architecture, the Universal
Serial Bus 2.0 Specification (and related specifications), the XMOS tool chain
and XC language.

Features
++++++++

   * Support for USB 2.0 full and high speed devices.

Memory requirements
+++++++++++++++++++

The approximate memory usage for the USB device library including the XUD
library is:

+------------------+---------------+
|                  | Usage         |
+==================+===============+
| Stack            | 2kB           |
+------------------+---------------+
| Program          | 12kB          |
+------------------+---------------+

Resource requirements
+++++++++++++++++++++

The resources used by the device application and libraries on the xCORE-USB
are shown below:

+------------------+-----------------+
| Resource         | Requirements    |
+==================+=================+
| Logical Cores    | 2 plus 1 per    |
|                  | endpoint        |
+------------------+-----------------+
| Channels         | 2 for Endpoint0 |
|                  | and 1 additional|
|                  | per IN and OUT  |
|                  | endpoint        |
+------------------+-----------------+
| Timers           | 4 timers        |
+------------------+-----------------+
| Clock blocks     | Clock blocks    |
|                  | 4 and 5         |
+------------------+-----------------+

Core speed
++++++++++

Due to I/O timing requirements, the library requires a guaranteed MIPS rate to
ensure correct operation. This means that core count restrictions must
be observed. The XUD core must run at at least 80 MIPS.

This means that for an xCORE device running at 500MHz no more than six
cores shall execute at any one time when using the XUD.

This restriction is only a requirement on the tile on which the XUD is running. 
For example, a different tile on an U16 device is unaffected by this restriction.

Ports and pins
++++++++++++++

The U-Series of processors has an integrated USB transceiver. Some ports
are used to communicate with the USB transceiver inside the U-Series packages.
These ports/pins should not be used when USB functionality is enabled.
The ports/pins are shown in :ref:`table_usb_device_u_required_pin_port`.

.. _table_usb_device_u_required_pin_port:

.. table:: U-Series required pin/port connections
    :class: horizontal-borders vertical_borders

    +-------+-------+------+-------+-------+--------+
    | Pin   | Port                                  |                
    |       +-------+------+-------+-------+--------+
    |       | 1b    | 4b   | 8b    | 16b   | 32b    |                    
    +=======+=======+======+=======+=======+========+
    | X0D02 |       | P4A0 | P8A0  | P16A0 | P32A20 |
    +-------+-------+------+-------+-------+--------+
    | X0D03 |       | P4A1 | P8A1  | P16A1 | P32A21 |
    +-------+-------+------+-------+-------+--------+
    | X0D04 |       | P4B0 | P8A2  | P16A2 | P32A22 |
    +-------+-------+------+-------+-------+--------+
    | X0D05 |       | P4B1 | P8A3  | P16A3 | P32A23 |
    +-------+-------+------+-------+-------+--------+
    | X0D06 |       | P4B2 | P8A4  | P16A4 | P32A24 |
    +-------+-------+------+-------+-------+--------+
    | X0D07 |       | P4B3 | P8A5  | P16A5 | P32A25 |
    +-------+-------+------+-------+-------+--------+
    | X0D08 |       | P4A2 | P8A6  | P16A6 | P32A26 |
    +-------+-------+------+-------+-------+--------+
    | X0D09 |       | P4A3 | P8A7  | P16A7 | P32A27 |
    +-------+-------+------+-------+-------+--------+
    | X0D23 | P1H0  |                               |
    +-------+-------+------+-------+-------+--------+
    | X0D25 | P1J0  |                               | 
    +-------+-------+------+-------+-------+--------+
    | X0D26 |       | P4E0 | P8C0  | P16B0 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D27 |       | P4E1 | P8C1  | P16B1 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D28 |       | P4F0 | P8C2  | P16B2 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D29 |       | P4F1 | P8C3  | P16B3 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D30 |       | P4F2 | P8C4  | P16B4 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D31 |       | P4F3 | P8C5  | P16B5 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D32 |       | P4E2 | P8C6  | P16B6 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D33 |       | P4E3 | P8C7  | P16B7 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D34 | P1K0  |                               |
    +-------+-------+------+-------+-------+--------+
    | X0D36 | P1M0  |      | P8D0  | P16B8 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D37 | P1N0  |      | P8C1  | P16B1 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D38 | P1O0  |      | P8C2  | P16B2 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D39 | P1P0  |      | P8C3  | P16B3 |        |
    +-------+-------+------+-------+-------+--------+

