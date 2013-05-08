/*
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   
/* 
 * @brief      USB Device helper functions
 */

#ifndef _USB_DEVICE_H_
#define _USB_DEVICE_H_

/* Define used by the main.xc when created using code generation */
#define USB_DEVICE_EXISTS

#include "usb.h"
#include "xud.h"

/** 
  * \brief    This function deals with common requests This includes Standard Device Requests listed 
  *           in table 9-3 of the USB 2.0 Spec all devices must respond to these requests, in some 
  *           cases a bare minimum implementation is provided and should be extended in the devices EP0 code 
  *           It handles the following standard requests appropriately using values passed to it:
  *
  *   Get Device Descriptor (using devDesc_hs/devDesc_fs arguments)
  *
  *   Get Configuration Descriptor (using cfgDesc_hs/cfgDesc_fs arguments)
  *
  *   String requests (using strDesc argument)
  *
  *   Get Microsoft OS String Descriptor (re-uses product ID string)
  *
  *   Get Device_Qualifier Descriptor
  *
  *   Get Other-Speed Configuration Descriptor
  *
  *   Set/Clear Feature (Endpoint Halt)
  *
  *   Get/Set Interface
  *
  *   Set Configuration
  *
  *   If the request is not recognised the endpoint is marked STALLED
  *
  *
  * \param     ep_out   Endpoint from XUD (ep 0)
  * \param     ep_in    Endpoint from XUD (ep 0) 
  * \param     devDesc_hs The Device descriptor to use, encoded according to the USB standard
  * \param     devDescLength_hs Length of device descriptor in bytes
  * \param     cfgDesc_hs Configuration descriptor
  * \param     cfgDescLength_hs Length of config descriptor in bytes
  * \param     devDesc_fs The Device descriptor to use, encoded according to the USB standard
  * \param     devDescLength_fs Length of device descriptor in bytes
  * \param     cfgDesc_fs Configuration descriptor
  * \param     cfgDescLength_fs Length of config descriptor in bytes
  * \param     strDescs
  * \param     sp ``USB_SetupPacket_t`` (passed by ref) in which the setup data is returned
  * \param     c_usb_test Optional channel param for USB test mode support
  * \param     usbBusSpeed The current bus speed (XUD_SPEED_HS or XUD_SPEED_FS)
  *
  *  \return   Returns 0 if the request has been dealt with successfully, 1 if not. -1 for bus reset 
  */
int USB_StandardRequests(XUD_ep ep_out, XUD_ep ep_in, 
        unsigned char devDesc_hs[], int devDescLength_hs, 
        unsigned char cfgDesc_hs[], int cfgDescLength_hs,
        unsigned char ?devDesc_fs[], int devDescLength_fs, 
        unsigned char ?cfgDesc_fs[], int cfgDescLength_fs, 
        unsigned char strDescs[][40], USB_SetupPacket_t &sp, chanend ?c_usb_test, XUD_BusSpeed usbBusSpeed);
/**
 *  \brief  Receives a Setup data packet and parses it into the passed USB_SetupPacket_t structure.
 *  \param  ep_out   OUT endpint from XUD
 *  \param  ep_in    IN endpoint to XUD
 *  \param  sp       SetupPacket structure to be filled in (passed by ref)
 *  \return          0 on non-error, -1 for bus-reset
 */
int USB_GetSetupPacket(XUD_ep ep_out, XUD_ep ep_in, USB_SetupPacket_t &sp);

/**
 *  \brief Prints out passed ``USB_SetupPacket_t`` struct using debug IO
 */
void USB_PrintSetupPacket(USB_SetupPacket_t sp);

#endif
