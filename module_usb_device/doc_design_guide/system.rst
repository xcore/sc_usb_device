USB library overview
====================

The XMOS USB device support is divided into the XMOS USB Device (XUD)
Library (module_xud) and the USB Device Helper Functions (module_usb_device)

Although only XUD is required to develop a full USB device it is highly recommended
to use this the helper functions/wrappers in module_usb_device. The use of these
will greatly decrease development time and reduced required verification and testing
efforts.

XUD library
-----------

For full XUD API listing and documentation please see the document `XMOS USB Device (XUD) Library`

The XUD Library performs all the low-level I/O operations required to meet
the USB 2.0 specification. This processing goes up to and includes the
transaction level. It removes all low-level timincg requirements from the
application, allowing quick development of all manner of USB devices.

The XUD Library allows the implementation of both full-speed and
high-speed USB 2.0 devices on U-Series and L-Series devices.

The U-Series includes an integrated USB transceiver. For
the L-Series the implementation requires the use of an
external ULPI transceiver such as the SMSC USB33XX range. Two libraries, with
identical interfaces, are provided - one for U-Series and one for 
L-Series devices.

The XUD Library runs in a single core with endpoint and application
cores communicating with it via a combination of channel communication
and shared memory variables.

There is one channel per IN or OUT endpoint. Endpoint 0 (the control
endpoint) requires two channels, one for each direction. Note, that
throughout this document the USB nomenclature is used: an OUT endpoint
is used to transfer data from the host to the device, an IN endpoint is
used when the host requests data from the device.

An example task diagram is shown in :ref:`figure_xud_overview`.  Circles
represent cores running with arrows depicting communication
channels between these cores. In this configuration there is one
core that deals with endpoint 0, which has both the input and output
channel for endpoint 0. IN endpoint 1 is dealt with by a second core,
and OUT endpoint 2 and IN endpoint 5 are dealt with by a third core.
Cores must be ready to communicate with the XUD Library whenever the
host demands its attention. If not, the XUD Library will NAK.

It is important to note that, for performance reasons, cores
communicate with the XUD Library using a combination of both XC channels and shared
memory. It is therefore madatory that *all cores that directly communicate with the
XUD Library must be on the same tile as the library itself*.

.. _figure_xud_overview:

.. figure:: images/xud_overview.*
   :width: 120mm
   :align: center

   XUD Overview

XUD core
~~~~~~~~

The main XUD task is ``XUD_Manager()`` (see :ref:`xud_manager`) that 
performs power-signalling/handshaking on the USB bus, and passes packets
on for the various endpoints.

This function should be called directly from the top-level ``par``
statement in ``main()`` to ensure that the XUD Library is ready
within the 100ms allowed by the USB specification. 

Endpoint communication with ``XUD_Manager()``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Communication state between a core and the XUD Library is encapsulated
in an opaque type ``XUD_ep`` (see :ref:`xud_ep`).

All client calls communicating with the XUD Library pass in this type.
These data structures can be created at the start of execution of a
client core with using ``XUD_InitEp()`` that takes as an argument the
endpoint channel connected to the XUD Library.

Endpoint data is sent/received using ``XUD_SetBuffer()``
(see :ref:`sec_xud_set_buffer`) and receive data using ``XUD_GetBuffer()``
(see :ref:`sec_xud_get_buffer`).

These functions will automatically deal with any low-level complications required
such as Packet ID toggling etc.

Endpoint type table 
~~~~~~~~~~~~~~~~~~~

The endpoint type table should take an array of ``XUD_EpType`` to inform XUD
about endpoints being used.  This is mainly used to indicate the transfer-type
of each endpoint (bulk, control, isochronous or interrupt) as well as
whether the endpoint wishes to be informed about bus-resets (see :ref:`xud_status_reporting`).

.. _xud_status_reporting:

Status reporting
~~~~~~~~~~~~~~~~

Status reporting on an endpoint can be enabled so that bus state is
known. This is achieved by ORing ``XUD_STATUS_ENABLE`` into the relevant
endpoint in the endpoint type table.

This means that endpoints are notified of USB bus resets (and
bus-speed changes). The XUD access functions discussed previously
(``XUD_SetBuffer()``, ``XUD_GetBuffer()``) return XUD_RES_RST if
a USB bus reset is detected.

After a reset notification has been received, the endpoint must call the
``XUD_ResetEndpoint()`` function. This will return the current bus
speed.

See `XMOS USB Device (XUD) Library` for full details.

.. _sec_usb_device_helpers:

USB device helper functions
---------------------------

The USB Device Helper Functions provide a set of standard functions to aid the creation
of USB devices. USB devices must provide an implementation of endpoint 0
and can optionally provide a number of other IN and OUT endpoints.

Standard requests and endpoint 0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Endpoint 0 must deal with enumeration and configuration requests from the host. 
Many enumeration requests are compulsory and common to all devices, most of them
being requests for mandatory descriptors (Configuration, Device, String, etc.).
Since these requests are common across most (if not all) devices, some useful
functions are provided to deal with them.

Firstly, the function ``USB_GetSetupPacket()`` is provided. This makes a call to
the standard XUD function ``XUD_GetSetupBuffer()`` with the 8 byte Setup packet
which it parses into a ``USB_SetupPacket_t`` structure (see :ref:`usb_setup_packet_t`) 
for further inspection. The ``USB_SetupPacket_t`` structure passed by reference to 
``USB_GetSetupPacket()`` is populated by the function.

At this point the request is in a reasonable state to be parsed by endpoint 0.
Please see Universal Serial Bus 2.0 specification for full details of setup packet
and request structure.

A ``USB_StandardRequests()`` (see :ref:`usb_standard_requests`) function provides
a bare-minimum implementation
of the mandatory requests required to be implemented by a USB device.  It is not intended
that this replace a good knowledge of the requests required, since the implementation
does not guarantee a fully USB compliant device. Each request could well be required
to be over-ridden for a device implementation. For example, a USB Audio device could
well require a specialised version of ``SET_INTERFACE`` since this could mean that audio
will be streamed imminently.

Please see Universal Serial Bus 2.0 spec for full details of these requests.

The function inspects this ``USB_SetupPacket_t`` structure and includes a minimum implementation of the
Standard Device requests.  To see the requests handled and a listing of the basic functionality
associated with the request see :ref:`usb_standard_request_types`.

