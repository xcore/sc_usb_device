HID Class USB Device Demo Quick Start Guide
===========================================

app_hid_mouse_demo Quick Start Guide
------------------------------------

This application demonstrates how to create a USB 2.0 HID class device. It 
uses the XMOS U16 Slicekit Core Board (XP-SKC-U16) in conjunction with the Mixed
Signal Slice Card (XA-SK-MIXED SIGNAL).

The application provides:

    * A USB HID-class device which provides a two-button mouse implementation.
    * The mouse is controlled by the joystick on the Mixed Signal Slice.

Hardware Setup
--------------

To setup the hardware (:ref:`hid_mouse_demo_hardware_setup`):

    #. Connect the XA-SK-USB-AB Slice Card to slot marked ``U`` on the
       XP-SKC-U16 Slicekit Core Board.
    #. Connect the XA-SK-MIXED SIGNAL Slice Card to the XP-SKC-U16 Slicekit Core Board
       using the connector marked with the ``A``. 
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-U16 Slicekit Core Board.
    #. Connect the XTAG-2 to host PC (via a USB extension cable if desired).
    #. Connect the 12V power supply to the XP-SKC-U16 Slicekit Core Board.
    #. Connect the USB B-type connector on the XP-SKC-USB-AB Slice Card to the host PC.
    #. Switch the ``XLINK`` switch near the XTAG-2 connector to ``ON``.

.. _hid_mouse_demo_hardware_setup:

.. figure:: images/hw_setup.*
   :width: 120mm
   :align: center

   Hardware Setup for USB HID device example

Import and Build the Application
--------------------------------

   #. Open xTIMEcomposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``HID Class USB Device Demo`` item in the xSOFTip pane on the bottom left
      of the window and drag it into the Project Explorer window in the xTIMEcomposer.
      This will also cause the modules on which this application depends (in this case,
      module_usb_device, module_xud, module_usb_shared, module_usb_tile_support) to be
      imported as well. 
   #. *Note:* if the ``Custom Class USB Device Demo`` has already been imported then a warning will
      be displayed that some components already exist and will be overwritten. Unless
      you have other projects in your workspace you can press ``Yes``. If you do
      have other projects you don't want to overwrite then click ``No`` and change
      workspace (File->Switch Workspace) and drag the demo into that workspace.
   #. Click on the ``app_hid_mouse_demo`` item in the Project Explorer pane then click on
      drop-down arrow next to the ``Build`` icon (hammer) in xTIMEcomposer and select
      ``u16_adc``. Check the console window to verify that the application has
      built successfully.

*Note:* the Developer Column in the xTIMEcomposer on the right hand side of your screen
provides information on the xSOFTip components you are using. Select the ``module_xud``
component in the Project Explorer, and you will see its description together with API
documentation. Having done this, click the ``back`` icon until you return to this
quickstart guide within the Developer Column.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial
(see Help->Tutorials in xTIMEcomposer).

Run the Application
-------------------

Now that the application has been compiled, the next step is to run it on the Slicekit Core
Board using the tools to load the application over JTAG into the xCORE multicore microcontroller.

   #. Click on the ``app_hid_mouse_demo`` item in the Project Explorer pane and then 
      click on the ``Run`` icon (the white arrow in the green circle). A dialog will appear
      asking which device to connect to. Select ``XMOS XTAG-2``.
   #. You should see ``Address allocated`` and the USB address that the host has allocated
      to the device when the host has detected the device.
   #. Controlling the joystick on the Mixed Signal Slice Card should move the mouse of the
      host machine.
   #. Terminating the application will cause the USB device to be removed.

If the run dialog does not appear and let you select the XTAG then do the following:

   #. From the drop-down next to the ``Run`` icon select ``Run Configurations``.
   #. Select ``xCORE Application`` and press the ``New`` icon (white sheet 
      with small yellow ``+`` symbol in the corner).
   #. Ensure the Project is ``app_hid_mouse_demo`` and the Build configuration is
      ``u16_adc``.
   #. From the ``Target`` drop-down select the ``XMOS XTAG-2``.
   #. Click the ``Run`` button on the bottom right of the dialog window.

Next Steps
----------

   #. Open ``app_hid_mouse_demo/src/main.xc`` and look at the ``main()`` function.
      You will see that there are three parallel tasks running; ``XUD_Manager``,
      ``Endpoint0`` and ``hid_mouse``. The first two are common to any USB device
      application and the ``hid_mouse`` is the core of the application.
   #. There are two implementations of the ``hid_mouse`` function, one for use with
      the joystick which uses the ADC and one for use when no Mixed Signal Slice is
      available.
   #. If you look at the first implementation of ``hid_mouse`` you will see the
      configuration of the ADC. For the U16 board it uses two ADCs, one for each
      axis. The main loop then reads ADC values, which are 32-bit values of which
      the 12 most significant bits contain the ADC reading. The ``x`` and ``y``
      values are scaled and used only if they are outside of a dead zone. Try changing
      the ``SENSITIVITY`` define from ``1`` to ``9``.
   #. Open ``app_custom_bulk_demo/src/endpoint0.xc``. You will see the device descriptors
      which configure the USB device.
   #. Take a look at the USB Bulk Device Demo application.

