API
===

The XMOS USB Device library is provided by ``module_xud`` and the
USB Device Helper Functions are provided by ``module_usb_device``. 

The API of ``module_xud`` is listed in `XMOS USB Device (XUD) Library`. The API of 
``module_usb_device`` is detailed in this section.

Please note, both ``module_xud`` and ``module_usb_device`` depend on the module ``module_usb_shared``

module_usb_shared
-----------------

.. _usb_setup_packet_t:

``USB_SetupPacket_t``
~~~~~~~~~~~~~~~~~~~~~

This structure closely matches the structure defined in the USB 2.0 Specification:

.. literalinclude:: sc_usb/module_usb_shared/src/usb_std_requests.h
    :start-after: \brief   Typedef for setup packet structure
    :end-before: /**

.. _usb_get_setup_packet:

module_usb_device
-----------------

``USB_GetSetupPacket()``
~~~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: USB_GetSetupPacket

.. _usb_standard_requests:


``USB_StandardRequests()``
~~~~~~~~~~~~~~~~~~~~~~~~~~

This function takes a populated ``USB_SetupPacket_t`` structure as an argument. 

.. doxygenfunction:: USB_StandardRequests

.. _usb_standard_request_types:

Standard Device Request Types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``USB_StandardRequests()`` handles the following Standard Device Requests:


- ``SET_ADDRESS``

    - The device address is set in XUD (using ``XUD_SetDevAddr()``).

- ``SET_CONFIGURATION``
    
    - A global variable is updated with the given configuration value.
    
- ``GET_STATUS``
    
    - The status of the device is returned. This uses the device Configuration
      descriptor to return if the device is bus powered or not. 

-  ``SET_CONFIGURATION``

    - A global variable is returned with the current configuration last set by ``SET_CONFIGURATION``.

-  ``GET_DESCRIPTOR``

    - Returns the relevant descriptors. See :ref:`sec_hid_ex_descriptors` for further details.
      Note, some changes of returned descriptor will occur based on the current bus speed the
      device is running.

        -  ``DEVICE``

        -  ``CONFIGURATION``
    
        -  ``DEVICE_QUALIFIER``

        -  ``OTHER_SPEED_CONFIGURATION``

        -  ``STRING``

In addition the following test mode requests are dealt with (with the correct test mode set in XUD):   
   
- ``SET_FEATURE``

    - ``TEST_J``

    - ``TEST_K``

    - ``TEST_SE0_NAK``

    - ``TEST_PACKET``

    - ``FORCE_ENABLE``

Standard Interface Requests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

``USB_StandardRequests()`` handles the following Standard Interface Requests:

- ``SET_INTERFACE``

    - A global variable is maintained for each interface. This is updated by a ``SET_INTERFACE``.
      Some basic range checking is included using the value ``numInterfaces`` from the ConfigurationDescriptor.  

- ``GET_INTERFACE``

    - Returns the value written by ``SET_INTERFACE``.

Standard Endpoint Requests
~~~~~~~~~~~~~~~~~~~~~~~~~~

``USB_StandardRequests()`` handles the following Standard Endpoint Requests:

- ``SET_FEATURE``

- ``CLEAR_FEATURE``

- ``GET_STATUS``

If parsing the request does not result in a match, the request is not handled, the Endpoint is
marked "Halted" (Using ``XUD_SetStall_Out()`` and ``XUD_SetStall_In()``) and the function returns 
XUD_RES_ERR.

The function returns XUD_RES_OKAY if a request was handled without error (See also ``Status Reporting``).

