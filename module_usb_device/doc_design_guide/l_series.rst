.. _l_series_support:

L-Series support
================

The USB Device Library has been designed primarily for use with xCORE-USB (U-Series)
devices. However, it does also support L-Series devices. This section describe the
resource usage on the L-Series and changes required to build for L-Series devices.

Resource requirements
---------------------

The resources used by the USB device and XUD libraries combined on an L-Series
device are shown below:

+------------------+-----------------+
| Resource         | Requirements    |
+==================+=================+
| Logical Cores    | 2 plus one per  |
|                  | endpoint        |
+------------------+-----------------+
| Channels         | 2 for Endpoint0 |
|                  | and 1 additional|
|                  | per IN and OUT  |
|                  | endpoint        |
+------------------+-----------------+
| Timers           | 4 timers        |
+------------------+-----------------+
| Clock blocks     | Clock block 0   |
|                  |                 |
+------------------+-----------------+

*Note:* On the L-Series the XUD library uses clock block 0 and configures it 
to be clocked by the 60MHz clock from the ULPI transceiver. The ports it
uses are in turn clocked from the clock block. Since clock block 0 is
the default for all ports when enabled it is important that if a port
is not required to be clocked from this 60MHz clock, then it is configured
to use another clock block.

Ports and pins
--------------

The ports used for the physical connection to the external ULPI transceiver must
be connected as shown in :ref:`table_usb_device_ulpi_required_pin_port`.

.. _table_usb_device_ulpi_required_pin_port:

.. table:: L-Series required pin/port connections
    :class: horizontal-borders vertical_borders

    +-------+-------+------+-------+---------------------+
    | Pin   | Port                 | Signal              |
    |       +-------+------+-------+---------------------+
    |       | 1b    | 4b   | 8b    |                     |
    +=======+=======+======+=======+=====================+
    | X0D12 | P1E0  |              | ULPI_STP            |
    +-------+-------+------+-------+---------------------+
    | X0D13 | P1F0  |              | ULPI_NXT            |
    +-------+-------+------+-------+---------------------+
    | X0D14 |       | P4C0 | P8B0  | ULPI_DATA[7:0]      |
    +-------+       +------+-------+                     |
    | X0D15 |       | P4C1 | P8B1  |                     |
    +-------+       +------+-------+                     |
    | X0D16 |       | P4D0 | P8B2  |                     |
    +-------+       +------+-------+                     |
    | X0D17 |       | P4D1 | P8B3  |                     |
    +-------+       +------+-------+                     |
    | X0D18 |       | P4D2 | P8B4  |                     |
    +-------+       +------+-------+                     |
    | X0D19 |       | P4D3 | P8B5  |                     |
    +-------+       +------+-------+                     |
    | X0D20 |       | P4C2 | P8B6  |                     |
    +-------+       +------+-------+                     |
    | X0D21 |       | P4C3 | P8B7  |                     |
    +-------+-------+------+-------+---------------------+
    | X0D22 | P1G0  |              | ULPI_DIR            |
    +-------+-------+------+-------+---------------------+
    | X0D23 | P1H0  |              | ULPI_CLK            |
    +-------+-------+------+-------+---------------------+
    | X0D24 | P1I0  |              | ULPI_RST_N          |
    +-------+-------+------+-------+---------------------+

In addition some ports are used internally when the XUD library is in
operation. For example pins X0D2-X0D9, X0D26-X0D33 and X0D37-X0D43 on
an XS1-L8-128 device should not be used. 

Please refer to the device datasheet for further information on which ports
are available.

Reset requirements
------------------

On the L-Series the ``XUD_Manager`` requires a reset port and a reset clock block
to be given.

.. _usb_device_building_for_l_series:

Building for L-Series
---------------------

**Note:** ``module_usb_device`` and ``module_xud`` upon which it depends both support
both U-Series and L-Series devices, but the xSOFTip Explorer will only perform resource
estimation with the U-Series library.

**Note:** Also, tools before the 13.0 release do not support automatically changing a
target library. Therefore, if using xTIMEcomposer pre-13.0 the ``Makefile`` generated will
have to be modified in order to compile for an L-Series device. Open the ``Makefile``
and add the line ``MODULE_LIBRARIES = xud_l``.

