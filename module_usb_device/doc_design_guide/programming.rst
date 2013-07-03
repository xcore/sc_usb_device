Programming Guide
=================

This section provides information on how to create an application using the USB
Device library.

Includes
--------

The application needs to include ``xud.h`` and ``usb.h``.

Declarations
------------

There needs to be a table of endpoint types for both IN and OUT endpoints. These must
each include one for Endpoint0.

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

Endpoint0
---------

It is necessary to create an implementation for endpoint0 which takes two channels,
one for IN and one for OUT. It can take an optional channel for test.

::

   void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in, chanend ?c_usb_test)

The function must initialise the endpoints:

::

    XUD_ep ep0_out = XUD_InitEp(chan_ep0_out);
    XUD_ep ep0_in  = XUD_InitEp(chan_ep0_in);

and then loops handling USB packets, doing any processing locally
and calling ``USB_StandardRequests`` if they haven't been handled:

::

    while(1)
    {
        /* Returns 0 on success, < 0 for USB RESET */
        int retVal = USB_GetSetupPacket(ep0_out, ep0_in, sp);
        
        if(retVal == 0) 
        {
            // Perform local handling
            ...

            // Call library if not yet handled
            retVal = USB_StandardRequests(ep0_out, ep0_in, devDesc,
                        sizeof(devDesc), cfgDesc, sizeof(cfgDesc),
                        null, 0, null, 0, stringDescriptors, sp,
                        c_usb_test, usbBusSpeed);
        }

And finally, reset the endpoint if there have been any errors.

::

        if(retVal < 0)
            usbBusSpeed = XUD_ResetEndpoint(ep0_out, ep0_in);


Main
----

Within the main function it is necessary to allocate the channels to connect 
the endpoints the endpoints and then create the top-level ``par`` containing
the XUD_Manager, Endpoint0 and any additional endpoints.

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

            // Additional endpoints
            ...
        }
        return 0;
    }

Device Descriptors
------------------

USB Device descriptors must be provided for each USB device implementation
(see :ref:`sec_hid_ex_descriptors` for an example).

