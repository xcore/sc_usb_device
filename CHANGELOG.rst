sc_usb_device Change Log
========================

1.0.2
-----
  * USB_StandardRequests() function now takes length of string table as an extra parameter such that bounds checking can be performed.
  * Removed invalid response to Microsoft OS String request. Request is now STALLed by default.
  * USB_StandardRequestsi() now makes calls to XUD_ResetEpStateByAddr() in SET_CONFIGURATION to resolve some PID toggling issues on bulk EP's

  * Changes to dependencies:

    - sc_xud: 1.0.0rc6 -> 1.0.1beta2

      + CHANGE:     Power signalling state machines simplified in order to reduce memory usage.
      + FIXED:      (Minor) Reduced delay before transmitting k-chirp for high-speed mode, this improves high-speed handshake reliability on some hosts
      + FIXED:      (Major) Resolved a compatibility issue with Intel USB 3.0 xHCI host controllers relating to tight inter-packet timing resulting in packet loss

    - sc_usb: 1.0.0rc0 -> 1.0.1beta0

      + Updates to use latest XUD version

1.0.1
-----
  * Moving to sc_xud 1.0.0rc6

1.0.0
-----
  * Initial Version
