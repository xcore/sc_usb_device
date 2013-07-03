API
===

module_xud
----------

.. _xud_manager:

``XUD_Manager()``
+++++++++++++++++

.. doxygenfunction:: XUD_Manager

.. _xud_ep:

``XUD_ep``
++++++++++

.. doxygentypedef:: XUD_ep

``XUD_InitEp()``
++++++++++++++++

.. doxygenfunction:: XUD_InitEp

``XUD_GetBuffer()``
~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_GetBuffer

``XUD_SetBuffer()``
~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_SetBuffer

``XUD_SetBuffer_EpMax()``
~~~~~~~~~~~~~~~~~~~~~~~~~

This function provides a similar function to ``XUD_SetBuffer`` function
but it cuts the data up in packets of a fixed
maximum size. This is especially useful for control transfers where large 
descriptors must be sent in typically 64 byte transactions.

.. doxygenfunction:: XUD_SetBuffer_EpMax

``XUD_DoGetRequest()``
~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_DoGetRequest

``XUD_DoSetRequestStatus()``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_DoSetRequestStatus

``XUD_SetDevAddr()``
~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_SetDevAddr

``XUD_ResetEndpoint()``
~~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_ResetEndpoint


``XUD_SetStallByAddr()``
~~~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_SetStallByAddr

``XUD_SetStall()``
~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_SetStall

``XUD_ClearStallByAddr()``
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_ClearStallByAddr

``XUD_ClearStall()``
~~~~~~~~~~~~~~~~~~~~

.. doxygenfunction:: XUD_ClearStall

module_usb_device
-----------------

.. _usb_setup_packet_t:

Data Structure
++++++++++++++

This structure closely matches the structure defined in the USB 2.0 Specification:

.. literalinclude:: sc_usb/module_usb_shared/src/usb.h
    :start-after: \brief   Typedef for setup packet structure
    :end-before: #endif

.. _usb_get_setup_packet:

Setup Function
++++++++++++++

.. doxygenfunction:: USB_GetSetupPacket

Note, this function can return -1 to indicate a bus-reset condition.

.. _usb_standard_requests:

Standard Requests
+++++++++++++++++

This function takes a populated ``USB_SetupPacket_t`` structure as an argument. 

.. doxygenfunction:: USB_StandardRequests

.. _usb_standard_request_types:

Standard Device Request Types
+++++++++++++++++++++++++++++

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
+++++++++++++++++++++++++++

- ``SET_INTERFACE``

    - A global variable is maintained for each interface. This is updated by a ``SET_INTERFACE``.
      Some basic range checking is included using the value ``numInterfaces`` from the ConfigurationDescriptor.  

- ``GET_INTERFACE``

    - Returns the value written by ``SET_INTERFACE``.

Standard Endpoint Requests
++++++++++++++++++++++++++

- ``SET_FEATURE``

- ``CLEAR_FEATURE``

- ``GET_STATUS``

If parsing the request does not result in a match, the request is not handled, the Endpoint is
marked "Halted" (Using ``XUD_SetStall_Out()`` and ``XUD_SetStall_In()``) and the function returns 1.
The function returns 0 if a request was handled without error (See also Status Reporting).

