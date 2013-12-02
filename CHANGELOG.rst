sc_usb_device Change Log
========================

1.0.2
-----
  * USB_StandardRequests() function now takes length of string table as an extra parameter such that bounds checking can be performed.
  * Removed invalid response to Microsoft OS String request. Request is now STALLed by default.
  * USB_StandardRequestsi() now makes calls to XUD_ResetEpStateByAddr() in SET_CONFIGURATION to resolve some PID toggling issues on bulk EP's

1.0.1
-----
  * Moving to sc_xud 1.0.0rc6

1.0.0
-----
  * Initial Version
