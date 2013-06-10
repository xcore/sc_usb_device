USB-Device Class Library
========================

This module provides USB device-class support functions.

.. _usb_device_building_for_l_series:

Building for L-Series
---------------------

**Note:** ``module_usb_device`` and ``module_xud`` upon which it depends both support
both U-Series and L-Series devices, but the xSOFTip explorer will only perform resource
estimation with the U-Series library. Also, in order to compile for an L-Series device
the ``Makefile`` in the auto-generated project needs to be modified. Open the ``Makefile``
and add the line ``MODULE_LIBRARIES = xud_l``.

Device-Class API
----------------

.. doxygenfunction:: USB_StandardRequests
.. doxygenfunction:: USB_GetSetupPacket
.. doxygenfunction:: USB_PrintSetupPacket
