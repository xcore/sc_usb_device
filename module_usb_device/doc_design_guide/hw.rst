Evaluation Platforms
====================

Recommended Hardware
--------------------

U16 Slicekit
++++++++++++

The USB device library is best evaluated using the U16 Slicekit Modular Development Platform.
The required boards are:

    * ``XP-SKC-U16`` (Slicekit U16 Core Board) plus ``XA-SK-USB-AB`` (USB Slice)
    * Optionally: ``XA-SK-MIXED SIGNAL`` (Mixed Signal Slice) for the HID Class USB Device Demo

Demonstration Applications
--------------------------

HID Class USB Device Demo
+++++++++++++++++++++++++

This application demonstrates how to write a Human Interface Device (HID) Class Device; a mouse.

    * Package: HID Class USB Device Demo
    * Application: app_hid_mouse_demo

Custom Class USB Device Demo
++++++++++++++++++++++++++++

This application demonstrates how to write a Custom Class USB Device and using bulk transfers.
It provides both the xCORE application and the host drivers.

    * Package: Custom Class USB Device Demo
    * Application: app_custom_bulk_demo

