.. _usb_device_design_guide:

XMOS USB Device Design Guide
============================

This document details the use of the XMOS USB Device (XUD) Library
(see :ref:`xmos_usb_device_library`) to create USB 2.0 devices on
the XMOS xCORE architecture.

This document describes how to create an Endpoint 0 implementation
and provides a worked example that uses the XUD library; a USB Human
Interface Device (HID) Class compliant mouse. The full source
code for the example can be downloaded from the XMOS website.

This document assumes familiarity with the XUD Library, XMOS xCORE
architecture, the Universal Serial Bus 2.0 Specification (and
related specifications), the XMOS tool chain and XC language.

.. toctree::

    Standard Requests and Endpoint 0 <standard_reqs>
    Basic Example HS Device: USB HID Device <hid_example>
    Buidling on the L-Series  <building>
    Document Version History <version_history>


