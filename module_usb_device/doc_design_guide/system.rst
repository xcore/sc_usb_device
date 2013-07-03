System
======

A USB device can be programmed using the XUD Library alone,
however, to aid development some additional functions that
are essentially wrappers for the XUD are provided in the
USB Device Library :ref:`sec_usb_device_library`.

XUD Library
-----------

The XUD library allows the implementation of both full-speed and
high-speed USB 2.0 devices on both L-Series and U-Series devices.

For the L-Series family the implementation requires the use of an
external ULPI transceiver such as the SMSC USB33XX range. The U-Series
family includes an integrated USB transceiver. Two libraries, with
identical interfaces, are provided - one for L-Series and one for 
U-Series devices.

The library performs all the low-level I/O operations required to meet
the USB 2.0 specification. This processing goes up to and includes the
transaction level. It removes all low-level timing requirements from the
application, allowing quick prototyping of all manner of USB devices.

The XUD library runs in a single core with endpoint and application
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
Cores must be ready to communicate with the XUD library whenever the
host demands its attention. If not, the XUD library will NAK.

It is important to note that, for performance reasons, cores
communicate with the XUD library using both XC channels and shared
memory communication. Therefore, *all cores using the XUD library must
be on the same tile as the library itself*.

.. _figure_xud_overview:

.. figure:: images/xud_overview.*
   :width: 120mm
   :align: center

   XUD Overview


XUD Core
~~~~~~~~

The main XUD task is ``XUD_Manager()`` (see :ref:`xud_manager`) that 
performs power-signalling/handshaking on the USB bus, and passes packets
on for the various endpoints.

This function should be called directly from the top-level ``par``
statement in ``main()`` to ensure that the XUD library is ready
within the 100ms allowed by the USB specification. 

Endpoint Communication with ``XUD_Manager()``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Communication state between a core and the XUD library is encapsulated
in an opaque type ``XUD_ep`` (see :ref:`xud_ep`).

All client calls communicating with the XUD library pass in this type.
These data structures can be created at the start of execution of a
client core with using ``XUD_InitEp()`` that takes as an argument the
endpoint channel connected to the XUD library.

Endpoint data is sent/received using three main functions,
``XUD_SetData()``, ``XUD_GetData()`` and ``XUD_GetSetupData()``.

These assembly functions implement the low-level shared memory/channel
communication with the ``XUD_Manager()`` core. For developer convenience
these calls are wrapped up by XC functions.

These functions will automatically deal with any low-level complications required
such as Packet ID toggling etc.

Endpoint Type Table 
~~~~~~~~~~~~~~~~~~~

The endpoint type table should take an array of ``XUD_EpType`` to inform XUD
about endpoints being used.  This is mainly used to indicate the transfer-type
of each endpoint (bulk, control, isochronous or interrupt) as well as
whether the endpoint wishes to be informed about bus-resets (see :ref:`xud_status_reporting`).

*Note:* endpoints can also be marked as disabled.

Traffic to Endpoints that are not in used will be ``NAKed``.

.. _xud_status_reporting:

Status Reporting
~~~~~~~~~~~~~~~~

Status reporting on an endpoint can be enabled so that bus state is
known. This is achieved by ORing ``XUD_STATUS_ENABLE`` into the relevant
endpoint in the endpoint type table.

This means that endpoints are notified of USB bus resets (and
bus-speed changes). The XUD access functions discussed previously
(``XUD_GetData``, ``XUD_SetData``, etc.) return less than 0 if
a USB bus reset is detected.

This reset notification is important if an endpoint core is expecting
alternating INs and OUTs. For example, consider the case where an
endpoint is always expecting the sequence OUT, IN, OUT (such as a control
transfer). If an unplug/reset event was received after the first OUT,
the host would return to sending the initial OUT after a replug, while
the endpoint would hang on the IN. The endpoint needs to know of the bus
reset in order to reset its state machine.

*Endpoint 0 therefore requires this functionality since it deals with
bi-directional control transfers.*

This is also important for high-speed devices, since it is not
guaranteed that the host will detect the device as a high-speed device.
The device therefore needs to know what speed it is running at.

After a reset notification has been received, the endpoint must call the
``XUD_ResetEndpoint()`` function. This will return the current bus
speed.

SOF Channel
~~~~~~~~~~~

An application can pass a channel-end to the ``c_sof`` parameter of 
``XUD_Manager()``.  This will cause a word of data to be output every time
the device receives a SOF from the host.  This can be used for timing
information for audio devices etc.  If this functionality is not required
``null`` should be passed as the parameter.  Please note, if a channel-end
is passed into ``XUD_Manager()`` there must be a responsive task ready to
receive SOF notifications since else the ``XUD_Manager()`` task will be
blocked attempting to send these messages.

.. _xud_usb_test_modes:

USB Test Modes
~~~~~~~~~~~~~~

XUD supports the required test modes for USB Compliance testing. The
``XUD_Manager()`` task can take a channel-end argument for controlling the
test mode required.  ``null`` can be passed if this functionality is not required.  

XUD accepts a single word for from this channel to signal which test mode
to enter, these commands are based on the definitions of the Test Mode Selector
Codes in the USB 2.0 Specification Table 11-24.  The supported test modes are
summarised in the :ref:`table_test_modes`.

.. _table_test_modes:

.. table:: Supported Test Mode Selector Codes
    :class: horizontal-borders vertical_borders

    +--------+-------------------------------------+
    | Value  | Test Mode Description               |                
    +========+=====================================+
    | 1      | Test_J                              |
    +--------+-------------------------------------+
    | 2      | Test_K                              |
    +--------+-------------------------------------+
    | 3      | Test_SE0_NAK                        |
    +--------+-------------------------------------+
    | 4      | Test_Packet                         |
    +--------+-------------------------------------+
    | 5      | Test_Force_Enable                   |
    +--------+-------------------------------------+

The use of other codes results in undefined behaviour.

As per the USB 2.0 specification a power cycle or reboot is required to exit the test mode.

.. _sec_usb_device_library:

USB Device Library
------------------

The USB Device Library provides a set of standard functions to aid the creation
of any class of USB Device. USB devices must provide an implementation of Endpoint0
and can optionally provide a number of other IN and OUT endpoints.

Standard Requests and Endpoint 0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Endpoint 0 must deal with enumeration and configuration requests from the host. 
Many enumeration requests are compulsory and common to all devices, most of them
being requests for mandatory descriptors (Configuration, Device, String, etc.).
Since these requests are common across most (if not all) devices, some useful
functions are provided to deal with them. Although not strictly part of the
XUD library and supporting files, their use is so fundamental to a USB device that
they are covered in this document.

Firstly, the function ``USB_GetSetupPacket()`` is provided. This makes a call to
the standard XUD function ``XUD_GetSetupBuffer()`` from the 8 byte Setup packet
and parses it into a ``USB_SetupPacket_t`` structure (see :ref:`usb_setup_packet_t`) 
for further inspection (A ``USB_SetupPacket_t`` structure is passed by reference into the
``USB_GetSetupPacket()`` call, which is populated by the function).  

At this point the request is in a reasonable state to be parsed by endpoint 0.
Please see Universal Serial Bus 2.0 specification for full details of setup packet
and request structure. This is done using ``USB_GetSetupPacket`` (see :ref:`usb_get_setup_packet`).

A ``USB_StandardRequests()`` (see :ref:`usb_standard_requests`) function is given to
provide a bare-minimum implementation
of the mandatory requests required to be implemented by a USB device.  It is not intended
that this replace a good knowledge of the requests required, since the implementation
does not guarantee a fully USB compliant device.  Each request could well be required
to be over-ridden for many device implementations.  For example, a USB Audio device could
well require a specialised version of ``SET_INTERFACE`` since this could mean that audio
will be streamed imminently.

Please see Universal Serial Bus 2.0 spec for full details of these requests.

The function inspects this ``USB_SetupPacket_t`` structure and includes a minimum implementation of the
Standard Device requests.  To see the requests handled and a listing of the basic functionality
associated with the request see :ref:`usb_standard_request_types`.

Minimal Endpoint 0 Implementation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Typically the minimal code for endpoint 0 makes a call to call ``USB_GetSetupPacket()``, parses
the ``USB_SetupPacket_t`` for any class/applicaton specific requests. Then makes a call to
``USB_StandardRequests()``. For example:

::

    USB_GetSetupPacket(ep0_out, ep0_in, sp);

    switch(sp.bmRequestType.Type) 
    {
        case BM_REQTYPE_TYPE_CLASS:

            switch(sp.bmRequestType.Receipient)
            {
                case BM_REQTYPE_RECIP_INTER:
         
                    // Optional class specific requests.
                    break;

                ...
            }

            break;

        ...

    }

    USB_StandardRequests(ep0_out, ep0_in, devDesc, devDescLen, ..., );

Note, the example code above ignores any bus reset.

The code above could also over-ride any of the requests handled in ``USB_StandardRequests()``
for custom functionality.

Note, custom class code should be inserted before ``USB_StandardRequests()`` is called
since if ``USB_StandardRequests()`` cannot handle a request it marks the Endpoint stalled
to indicate to the host that the request is not supported by the device.

