USB Custom Class Device Demo Quick Start
========================================

app_custom_demo Quick Start Guide
---------------------------------

This application demonstrates how to create a USB 2.0 custom class device. It 
uses the XMOS U16 Slicekit Core Board (XP-SKC-U16).

The application provides:

    * A custom device which performs some data processing (increment data value).
    * Host application code to send data to the USB device and receive processed data.

Hardware Setup
++++++++++++++

To setup the hardware (:ref:`custom_demo_hardware_setup`):

    #. Connect the XA-SK-USB-AB Slice Card to slot marked ``USB`` on
       the XP-SKC-U16 Slicekit Core Board.
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-U16 Slicekit
       Core Board (via the supplied adaptor board).
    #. Connect the XTAG-2 to host PC (via a USB extension cable if desired).
    #. Connect the 12V power supply to the XP-SKC-U16 Slicekit Core Board.
    #. Connect the USB connector on the XP-SKC-U16 Slicekit Core Board to the host PC.

.. _custom_demo_hardware_setup:

.. figure:: images/hw_setup.*
   :width: 120mm
   :align: center

   Hardware Setup for USB Custom Class device demo

Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``Custom Class USB Device Demo`` item in the xSOFTip pane on the bottom left
      of the window and drag it into the Project Explorer window in the xTIMEcomposer.
      This will also cause the modules on which this application depends (in this case,
      module_usb_device, module_xud, module_usb_shared) to be imported as well. 
   #. *Note:* if the ``app_hid_mouse_demo`` has already been imported then a warning will
      be displayed that some components already exist and will be overwritten. Unless
      you have other projects in your workspace you can simply press ``Yes``. If you do
      have other projects you don't want to overwrite then click ``No`` and change
      workspace first (File->Switch Workspace).
   #. Click on the ``app_custom_bulk_demo`` item in the Explorer pane then click on the
      build icon (hammer) in xTIMEcomposer. Check the console window to verify that the
      application has built successfully.

*Note:* the Developer Column in the xTIMEcomposer on the right hand side of your screen
provides information on the xSOFTip components you are using. Select the module_xud
component in the Project Explorer, and you will see its description together with API
documentation. Having done this, click the ``back`` icon until you return to this
quickstart guide within the Developer Column.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial
(see Help->Tutorials in xTIMEcomposer).

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core
Board using the tools to load the application over JTAG (via the XTAG-2 Adaptor card)
into the xCORE multicore microcontroller.

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear
      asking which device to connect to. Select ``XMOS XTAG-2``.
   #. The application will now be running and the host PC should detect a new USB device
      called ``XMOS Custom Bulk Transfer Device``.
   #. Run the ``bulktest`` binary from the relevant ``host/`` subfolder. This will measure
      the USB transfer rate of the custom device. 
   #. Terminating the application will cause the USB device to be removed.

*Note:* on Mac OSX it is necessary to source the ``host/OSX/setup.sh`` before running
``bulktest``.

*Note:* the transfer rate will vary drastically between hosts and operating systems.

Next Steps
++++++++++

   #. Take a look at the USB HID Mouse Demo application.

