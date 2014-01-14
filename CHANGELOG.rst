sc_usb_device Change Log
========================

1.0.3
-----
  * Changes to dependencies:

    - sc_xud: 1.0.1beta3 -> 1.0.3alpha2

      + RESOLVED:   (Minor) ULPI data-lines driven hard low and XMOS pull-up on STP line disabled

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
