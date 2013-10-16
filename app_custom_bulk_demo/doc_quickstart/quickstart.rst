USB custom class device demo quick start
========================================

Quick start guide (app_custom_bulk_demo)
----------------------------------------

This application demonstrates how to create a High Speed USB 2.0 Custom Class device. It 
uses the XMOS U16 sliceKIT Core Board (XP-SKC-U16).

The demonstration provides:

    * A custom device application which performs some data processing
      (increment data value).
    * Host application code to send data to the USB device and receive processed data
      and time the data rate of the transfer. *Note:* the transfer rate will vary
      widely between hosts and operating systems. The theoretical maximum bandwidth
      for 512-byte transfers is about 50MB/s, but in a real system this is likely
      to be more like 1-10MB/s.
    * A driver for Windows (none required for MacOSX/Linux).

Hardware setup
--------------

To setup the hardware (:ref:`custom_bulk_demo_hardware_setup`):

    #. Connect the XA-SK-USB-AB Slice Card to slot marked ``U`` on the
       XP-SKC-U16 sliceKIT Core Board.
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-U16 sliceKIT
       Core Board.
    #. Connect the XTAG-2 to host PC (via a USB extension cable if desired).
    #. Connect the 12V power supply to the XP-SKC-U16 sliceKIT Core Board.
    #. Connect the USB B-type connector on the XP-SKC-USB-AB Slice Card to the host PC.
    #. Switch the ``XLINK`` switch near the XTAG-2 connector to ``ON``.

.. _custom_bulk_demo_hardware_setup:

.. figure:: images/hw_setup.*
   :width: 120mm
   :align: center

   Hardware Setup for USB Custom Class device demo

Import and build the application
--------------------------------

   #. Open xTIMEcomposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``Custom Class USB Device Demo`` item in the xSOFTip pane on the bottom left
      of the window and drag it into the Project Explorer window in the xTIMEcomposer.
      This will also cause the modules on which this application depends (in this case,
      module_usb_device, module_xud, module_usb_shared) to be imported as well. 
   #. *Note:* if the ``HID Class USB Device Demo`` has already been imported then a warning will
      be displayed that some components already exist and will be overwritten. Unless
      you have other projects in your workspace you can press ``Yes``. If you do
      have other projects you don't want to overwrite then click ``No`` and change
      workspace (File->Switch Workspace) and drag the demo into that workspace.
   #. Click on the ``app_custom_bulk_demo`` item in the Project Explorer pane then click on
      drop-down arrow next to the ``Build`` icon (hammer) in xTIMEcomposer and select
      ``u16``. Check the console window to verify that the application has
      built successfully.

*Note:* the Developer Column in the xTIMEcomposer on the right hand side of your screen
provides information on the xSOFTip components you are using. Select the module_xud
component in the Project Explorer, and you will see its description together with API
documentation. Having done this, click the ``back`` icon until you return to this
quickstart guide within the Developer Column.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial
(see Help->Tutorials in xTIMEcomposer).

Windows driver
--------------

On Windows you must first install the USB driver before running the application.

   #. The driver is included in the project directory, but cannot be run from within
      the xTIMEcomposer so open a Windows Explorer and locate the
      ``app_custom_bulk_demo/host`` in your workspace.
   #. Run ``host/libusb/Win32/dpinst64.exe`` (or ``dpinst32.exe`` on 32-bit systems).
   #. When User Access Control asks whether you want to let the program make changes
      to the computer, click ``Yes``.
   #. A Device Driver Updater dialog will appear. Click ``Next`` and it will install
      the driver.

If this fails, then run the application so that the USB device is connected to the machine
and then you can install the driver manually with the following steps:

   #. Open the Device Manager (Start -> Control Panel -> Device Manager)
   #. Locate the ``Unknown device`` under ``Other devices``.
   #. Right click on it and select ``Update Driver Software`` and then select
      ``Browse my computer for driver software`` and select the ``host/libusb/Win32/driver``
      folder.
   #. The device should be installed and recognized as ``XMOS Simple Bulk Transfer Example``.
      
MacOSX/Linux driver
-------------------

There is no need to install a driver on either MacOSX or Linux.

Run the application
-------------------

Now that the application has been compiled, the next step is to run it on the sliceKIT Core
Board using the tools to load the application over JTAG into the xCORE multicore microcontroller.

   #. Click on the ``app_custom_bulk_demo`` item in the Project Explorer pane and then
      from the drop-down next to the ``Run`` icon (the white arrow in the green circle) 
      select ``Run Configurations``.
   #. Select ``xCORE Application`` and press the ``New`` icon (white sheet 
      with small yellow ``+`` symbol in the corner).
   #. Ensure the Project is ``app_custom_bulk_demo`` and the Build configuration is
      ``u16``.
   #. From the ``Target`` drop-down select the ``XMOS XTAG-2``.
   #. Select ``Run XScope output server`` to ensure that the output from the application
      will be displayed in the console.
   #. Click the ``Run`` button on the bottom right of the dialog window.
   #. You should see ``Address allocated`` and the USB address that the host has allocated
      to the device when the host has detected the device. The device will be called
      ``XMOS Custom Bulk Transfer Device``.

Windows
+++++++

   #. When the device runs Windows should detect the device and install the driver for it
      as long as you pre-installed the driver as detailed above. Otherwise follow the
      instructions above for manually installing the driver.
   #. Run the ``bulktest`` binary from the relevant ``host/`` subfolder. This will measure
      the USB transfer rate of the custom device.
   #. Terminating the application will cause the USB device to be removed.

Linux
+++++

   #. On Linux source the relevant ``app_custom_bulk_demo/host/Linux[32|64]/setup.sh``.
   #. Run the ``bulktest`` binary from the relevant ``app_custom_bulk_demo/host/Linux[32|64]/``
      subfolder. This will measure the USB transfer rate of the custom device.
      *Note: this must be run as administrator.*
   #. Terminating the application will cause the USB device to be removed.

MacOSX
++++++

   #. On MacOSX source ``app_custom_bulk_demo/host/OSX/setup.sh``.
   #. Run the ``bulktest`` binary from ``app_custom_bulk_demo/host/OSX``. This will measure
      the USB transfer rate of the custom device.
   #. Terminating the application will cause the USB device to be removed.

Next steps
----------

   #. Open ``app_custom_bulk_demo/src/main.xc`` and look at the ``main()`` function.
      You will see that there are three parallel tasks running; ``XUD_Manager()``,
      ``Endpoint0()`` and ``bulk_endpoint()``. The first two are common to any USB device
      application and the ``bulk_endpoint()`` is the core of the application.
   #. Look at the ``bulk_endpoint()`` function. It receives a buffer from the host using
      ``XUD_GetBuffer()``, increments the contents and then sends it back to the host
      using ``XUD_SetBuffer()``. It needs to ensure that if either function indicates
      an error (returns < 0) then the endpoint is reset and the communication restarts.
   #. Open ``app_custom_bulk_demo/src/endpoint0.xc``. You will see the device descriptors
      which configure the USB device.
   #. Take a look at the USB HID Mouse Demo application.

