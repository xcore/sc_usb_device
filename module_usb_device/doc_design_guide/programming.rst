Programming Guide
=================

This section provides information on how to create an application using the USB
Device library.

Includes
--------

The application needs to include ``xud.h`` and ``usb.h``.

Declarations
------------

Create a table of endpoint types for both IN and OUT endpoints. These must
each include one for endpoint 0.

::

    #define XUD_EP_COUNT_OUT  1
    #define XUD_EP_COUNT_IN   2

    /* Endpoint type tables */
    XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {
        XUD_EPTYPE_CTL | XUD_STATUS_ENABLE
    };
    XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] = {
        XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL
    };

The endpoint types are:

    * ``XUD_EPTYPE_ISO``: Isochronous endpoint
    * ``XUD_EPTYPE_INT``: Interrupt endpoint
    * ``XUD_EPTYPE_BUL``: Bulk endpoint
    * ``XUD_EPTYPE_CTL``: Control endpoint
    * ``XUD_EPTYPE_DIS``: Disabled endpoint

And ``XUD_STATUS_ENABLE`` is ORed in to the endpoints that wish to be informed of
USB bus resets (see :ref:`xud_status_reporting`).

Endpoint 0 Implementation
-------------------------

It is necessary to create an implementation for endpoint 0 which takes two channels,
one for IN and one for OUT. It can take an optional channel for test
(see :ref:`xud_usb_test_modes`).

::

   void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in, chanend ?c_usb_test)
   {

Every endpoint must be initialized using the ``XUD_InitEp()`` function. For endpoint 0
this is looks like:

::

    XUD_ep ep0_out = XUD_InitEp(chan_ep0_out);
    XUD_ep ep0_in  = XUD_InitEp(chan_ep0_in);

Typically the minimal code for endpoint 0 loops making call to ``USB_GetSetupPacket()``,
parses the ``USB_SetupPacket_t`` for any class/applicaton specific requests.
Then makes a call to ``USB_StandardRequests()``. And finally, calls
``XUD_ResetEndpoint()`` if there have been any errors. For example:

::

    while(1)
    {
        /* Returns 0 on success, < 0 for USB RESET */
        int retVal = USB_GetSetupPacket(ep0_out, ep0_in, sp);

        if(retVal == 0) 
        {
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

            retval = USB_StandardRequests(ep0_out, ep0_in,
                    devDesc, devDescLen, ...);
        }

        if(retVal < 0)
            usbBusSpeed = XUD_ResetEndpoint(ep0_out, ep0_in);
    }

The code above could also over-ride any of the requests handled in
``USB_StandardRequests()`` for custom functionality.

Note, class specific code should be inserted before ``USB_StandardRequests()`` is called
since if ``USB_StandardRequests()`` cannot handle a request it marks the Endpoint stalled
to indicate to the host that the request is not supported by the device.

Note that on reset the XUD returns the negotiated USB speed (full speed/high speed).

Main
----

Within the main function it is necessary to allocate the channels to connect 
the endpoints and then create the top-level ``par`` containing
the XUD_Manager, endpoint 0 and any application specific endpoints.

::

    int main() 
    {
        chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];
        par {
            XUD_Manager(c_ep_out, XUD_EP_COUNT_OUT,
                        c_ep_in, XUD_EP_COUNT_IN,
                        null, epTypeTableOut, epTypeTableIn,
                        null, null, null, XUD_SPEED_HS, null);  
            Endpoint0(c_ep_out[0], c_ep_in[0]);

            // Application specific endpoints
            ...
        }
        return 0;
    }

The XUD_Manager connects to one end of every channel while the other end is
passed to an endpoint (either endpoint 0 or an application specific endpoint).
Application specific endpoints are connected using channel ends so the IN and OUT
channel arrays need to be extended for each endpoint.

Endpoint Addresses
------------------

Endpoint 0 uses index 0 of both the endpoint type table and the channel array.
The address of other endpoints must also correspond to their index in the
endpoint table and the channel array.

Sending/Receiving Data
----------------------

An application specific endpoint can send data using ``XUD_SetBuffer()``
(see :ref:`sec_xud_set_buffer`) and receive data using ``XUD_GetBuffer()``
(see :ref:`sec_xud_get_buffer`).

Device Descriptors
------------------

USB device descriptors must be provided for each USB device. They are used
to identify the USB device's vendor ID, product ID and detail all the 
attributes of the advice as specified in the USB 2.0 standard. It is beyond
the scope of this document to give details of writing a descriptor.

Worked Example
--------------

For more details see the worked HID Class example (:ref:`usb_device_hid_example`).

