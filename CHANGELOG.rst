sc_usb_device Change Log
========================

1.1.0
-----
    - CHANGE:     Functions changed to use new XUD_Result_t type and return value from XUD user functions
    - CHANGE:     XUD_BusSpeed_t now used (previously used unsigned)
    - CHANGE:     Function prototypes now use macros from xccompat.h such that they can be called from
                  standard C
    - CHANGE:     Latest enums/defines from module_usb_shared now used
    - RESOLVED:   (Minor) devDescLength_fs now inspected instead of cfgDescLength when checking for 
                  full-speed Device Descriptor

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
