This simple host example demonstrates simple bulk transfer requests between the host processor and the XMOS device.

The application simply transfers a data buffer to the device and back, the device increments the data values before returning the new values to the host. The host then increments the values and sends them again a number of times.

The binaries and (where required) setup scripts are provided for each sample platform in the named directory

To run the example, source the appropriate setup script and then execute the 'bulktest' application

Compilation instructions
------------------------

Win32
-----
cl -o bulktest bulktest.cpp -I ..\libusb\Win32 ..\libusb\Win32\libusb.lib

OSX
---
g++ -o bulktest bulktest.cpp -I ../libusb/OSX ../libusb/OSX/libusb-1.0.0.dylib -m32

Linux32
-------
g++ -o bulktest bulktest.cpp -I ../libusb/Linux32 ../libusb/Linux32/libusb-1.0.a -lpthread -lrt

Linux64
-------
g++ -o bulktest bulktest.cpp -I ../libusb/Linux64 ../libusb/Linux64/libusb-1.0.a -lpthread -lrt

Windows Driver
--------------

An test driver for Windows built using libusb is available in the libusb/Win32
directory. When prompted for driver installation by the OS add this directory
to the search path. This will allow the device to install correctly.

Note : On windows 7 systems the driver test mode will need to be activated as
the driver provided with this example is not digitally signed.
