sc_usb_device Change Log
========================

1.3.3
-----

1.3.2
-----

  * Changes to dependencies:

    - sc_xud: 2.2.0rc0 -> 2.2.1rc0

      + RESOLVED:   Slight optimisations (long jumps replaced with short) to aid inter-packet gaps.

1.3.1
-----

  * Changes to dependencies:

    - sc_xud: 2.1.1rc0 -> 2.2.0rc0

      + CHANGE:     Timer usage optimisation - usage reduced by one.
      + CHANGE:     OTG Flags register explicitly cleared at start up - useful if previously running

1.3.0
-----
    - CHANGE:  Required updates for XUD API change relating to USB test-mode-support


  * Changes to dependencies:

    - sc_xud: 2.0.1rc3 -> 2.1.1rc0

      + ADDED:      Warning emitted when number of cores is greater than 6
      + CHANGE:     XUD no longer takes a additional chanend parameter for enabling USB test-modes.

1.2.2
-----

  * Changes to dependencies:

    - sc_xud: 2.0.0rc0 -> 2.0.1rc3

      + RESOLVED:   (Minor) Error when building module_xud in xTimeComposer due to invalid project

1.2.1
-----
    - RESOLVED:   (Minor) Build issue in Windows host app for bulk demo

1.2.0
-----
    - CHANGE:     USB_StandardRequests() now returns XUD_Result_t instead of int
    - CHANGE:     app_hid_mouse_demo now uses XUD_Result_t
    - CHANGE:     app_custom_bulk_demo now uses XUD_Result_t
    - CHANGE:     USB_StandardRequests() now takes the string table as an array of char pointers rather
                  than a fixed size 2D array. This allows for a more space efficient string table
                  representation. Please note, requires tools 13 or later for XC pointer support.
    - CHANGE:     Demo applications now set LangID string at build-time (rather than run-time)
    - CHANGE:     Test mode support no longer guarded by TEST_MODE_SUPPORT

  * Changes to dependencies:

    - sc_util: 1.0.3rc0 -> 1.0.4rc0

      + module_logging now compiled at -Os
      + debug_printf in module_logging uses a buffer to deliver messages unfragmented
      + Fix thread local storage calculation bug in libtrycatch
      + Fix debug_printf itoa to work for unsigned values > 0x80000000

1.1.0
-----
    - CHANGE:     Functions changed to use new XUD_Result_t type and return value from XUD user functions
    - CHANGE:     XUD_BusSpeed_t now used (previously used unsigned)
    - CHANGE:     Function prototypes now use macros from xccompat.h such that they can be called from
                  standard C
    - CHANGE:     Latest enums/defines from module_usb_shared now used
    - RESOLVED:   (Minor) devDescLength_fs now inspected instead of cfgDescLength when checking for
                  full-speed Device Descriptor

  * Changes to dependencies:

    - sc_xud: 1.0.3beta1 -> 2.0.0beta1

      + CHANGE:     All XUD functions now return XUD_Result_t. Functions that previously returned
      + CHANGE:     Endpoint ready flags are now reset on bus-reset (if XUD_STATUS_ENABLE used). This
      + CHANGE:     Reset notifications are now longer hand-shaken back to XUD_Manager in
      + CHANGE:     XUD_SetReady_In now implemented using XUD_SetReady_InPtr (previously was duplicated
      + CHANGE:     XUD_ResetEndpoint now in XC. Previously was an ASM wrapper.
      + CHANGE:     Modifications to xud.h including the use of macros from xccompat.h such that it
      + CHANGE:     XUD_BusSpeed type renamed to XUD_BusSpeed_t in line with naming conventions
      + CHANGE:     XUD_SetData_Select now takes a reference to XUD_Result_t instead an int
      + CHANGE:     XUD_GetData_Select now takes an additional XUD_Result_t parameter by reference
      + CHANGE:     XUD_GetData_Select now returns XUD_RES_ERR instead of a 0 length on packet error

    - sc_usb: 1.0.2beta1 -> 1.0.3beta1

      + CHANGE:     Various descriptor structures added, particularly for Audio Class
      + CHANGE:     Added ComposeSetupBuffer() for creating a buffer from a USB_Setup_Packet_t
      + CHANGE:     Various function prototypes now using macros from xccompat.h such that then can be

1.0.4
-----
    - CHANGE:     devDesc_hs and cfgDesc_hs params to USB_StandardRequests() now nullable (useful for full-speed only devices)
    - CHANGE:     Nullable descriptor array parameters to USB_StandardRequests() changed from ?array[] to (?&array)[] due to
                  the compiler warning that future compilers will interpret the former as an array of nullable items (rather
                  than a nullable reference to an array). Note: The NULLABLE_ARRAY_OF macro (from xccompat.h) is used retain
                  compatibility with older tools version (i.e. 12).

1.0.3
-----
  * Changes to dependencies:

    - sc_xud: 1.0.1beta3 -> 1.0.3alpha5

      + RESOLVED:   (Minor) ULPI data-lines driven hard low and XMOS pull-up on STP line disabled
      + RESOLVED:   (Minor) Fixes to improve memory usage such as adding missing resource usage
      + RESOLVED:   (Minor) Moved to using supplied tools support for communicating with the USB tile

    - sc_usb: 1.0.1beta1 -> 1.0.2beta0

      + ADDED:   USB_BMREQ_D2H_VENDOR_DEV and USB_BMREQ_D2H_VENDOR_DEV defines for vendor device requests

1.0.2
-----
  * CHANGE:    USB_StandardRequests() function now takes length of string table as an extra parameter such that bounds checking can be performed.
  * RESOLVED:  Removed invalid response to Microsoft OS String request. Request is now STALLed by default.
  * RESOLVED:  USB_StandardRequestsi() now makes calls to XUD_ResetEpStateByAddr() in SET_CONFIGURATION to resolve some PID toggling issues on bulk EP's

  * Changes to dependencies:

    - sc_xud: 1.0.0rc6 -> 1.0.1beta3

      + CHANGE:     Power signalling state machines simplified in order to reduce memory usage.
      + RESOLVED:   (Minor) Reduced delay before transmitting k-chirp for high-speed mode, this improves high-speed handshake reliability on some hosts
      + RESOLVED:   (Major) Resolved a compatibility issue with Intel USB 3.0 xHCI host controllers relating to tight inter-packet timing resulting in packet loss

    - sc_usb: 1.0.0rc0 -> 1.0.1beta1

      + CHANGE:     Updates to use XUD version 1.0.1

1.0.1
-----
  * Moving to sc_xud 1.0.0rc6

1.0.0
-----
  * Initial Version
