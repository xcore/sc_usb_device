Evaluation platforms
====================

The XMOS USB Device Library supports both the xCORE-USB (U-Series) devices and the
xCORE General Purpose (L-Series) devices. However, not all development kits support
implementing USB devices.

Recommended hardware
--------------------

U16 sliceKIT
++++++++++++

The USB device capabilities are best evaluated using the U16 Slicekit Modular
Development Platform. The required boards are:

    * ``XP-SKC-U16`` (Slicekit U16 Core Board) plus ``XA-SK-USB-AB`` (USB Slice)
    * Optionally: ``XA-SK-MIXED SIGNAL`` (Mixed Signal Slice) for the HID
      Class USB Device Demo

Demonstration applications
--------------------------

HID class USB device demo
+++++++++++++++++++++++++

This application demonstrates how to write a Human Interface Device (HID) Class Device; a mouse.

    * Package: HID Class USB Device Demo
    * Application: app_hid_mouse_demo

