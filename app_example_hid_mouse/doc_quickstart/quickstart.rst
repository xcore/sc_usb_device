USB HID Device Demonstration Application
========================================

.. toctree::

app_example_hid_mouse Quick Start Guide
---------------------------------------

This application demonstrates how to create a USB 2.0 HID class device. It 
uses the XMOS U2 Slicekit Core Board (XP-SKC-U2) in conjunction with the Mixed
Signal Slice Card (XA-SK-???).

The application provides:

    * A USB HID-class device which provides a two-button mouse implementation.
    * The mouse is controlled by the joystick on the Mixed Signal Slice.

Hardware Setup
++++++++++++++

To setup the hardware:

    #. Connect the XA-SK-??? Mixed Signal Slice Card to the XP-SKC-U2 Slicekit Core Board using the connector
       marked with the ``???``. 
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-L2 Slicekit core board (via the supplied adaptor board)
    #. Connect the XTAG-2 to host PC (via a USB extension cable if desired)
    #. Connect the power supply to the XP-SKC-U2 Slicekit Core board
    #. Connect the USB connector on the XP-SKC-U2 Slicekit Core Board to the host PC

.. figure:: images/hw_setup.png
   :width: 300px
   :align: center

   Hardware Setup for USB HID device demonstration

Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``USB HID Mouse Demo`` item in the xSOFTip pane on the bottom left
      of the window and drag it into the Project Explorer window in the xTimeComposer.
      This will also cause the modules on which this application depends (in this case,
      module_usb_device, module_xud, module_usb) to be imported as well. 
   #. Click on the ``app_example_hid_mouse`` item in the Explorer pane then click on the
      build icon (hammer) in xTimeComposer. Check the console window to verify that the
      application has built successfully.

Note that the Developer Column in the xTimeComposer on the right hand side of your screen
provides information on the xSOFTip components you are using. Select the module_xud
component in the Project Explorer, and you will see its description together with API
documentation. Having done this, click the `back` icon until you return to this
quickstart guide within the Developer Column.

For help in using xTimeComposer, try the xTimeComposer tutorial (See Help->Tutorials in xTIMEcomposer).

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core
Board using the tools to load the application over JTAG (via the XTAG-2 Adaptor card)
into the xCORE multicore microcontroller.

   #. Click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear
      asking which device to connect to. Select ``XMOS XTAG2``.
   #. The application will now be running and the host PC should detect a new USB device.
   #. Controlling the joystick on the Mixed Signal Slice Card should move the mouse of the
      host machine.
   #. Terminating the application will cause the USB device to be removed.

Next Steps
++++++++++

   #. Take a look at the other USB example application TBD

