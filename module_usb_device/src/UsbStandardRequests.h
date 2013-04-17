/**
 * Module:  module_usb_shared
 * Version: 1v14
 * Build:   2653f22a66739162bd368f5c7d50da8bd7417fd7
 * File:    DescriptorRequests.h
 *
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
/** 
 * @brief      USB Device helper functions
 * @author     Ross Owen, XMOS Limited
 */

#ifndef _USB_STANDARD_REQUESTS_H_
#define _USB_STANDARD_REQUESTS_H_

#include "usb.h"
#include "xud.h"

/** 
  * \brief     This function performs some of the common USB standard descriptor requests.
  *
  * \param     c Channel to XUD (ep 0)
  * \param     c_in Channel from XUD (ep 0) 
  * \param     devDesc Device descriptor
  * \param     devDescLength Length of device descriptor in bytes
  * \param     cfgDesc Configuration descriptor
  * \param     cfgDescLength Length of config descriptor in bytes
  * \param     devQualDesc Device Qualification Descriptor
  * \param     devQualDescLength
  * \param     oSpeedCfgDesc
  * \param     oSpeedCfgDescLength
  * \param     strDescs
  * \param     sp SetupPacket (passed by ref) in which the setup data is returned
  * \param     c_usb_test Optional channel param for USB test mode support
  * \return    1 if dealt with else 
  *
  * This function handles the following standard requests appropriately using values passed to it:
  *
  *   - Get Device Descriptor (Using devDesc argument)
  *   - Get Configuration Descriptor (Using cfgDesc argument)
  *   - String requests (using strDesc argument)
  *   - Get Micro$oft OS String Descriptor (Usings product ID string) 
  *   - Get Device_Qualifier Descriptor 
  *   - Get Other-Speed Configuration Descriptor (using oSpeedCfgDesc argument)
  *   
  *  This function returns 1 if the request has been dealt with successfully, 0 if not.  The SetupPacket
  *  structure should then be examined for device specific requests.

  */
int USB_StandardRequests(XUD_ep c, XUD_ep c_in, unsigned char devDesc[], int devDescLength, unsigned char cfgDesc[], int cfgDescLength,
    unsigned char devQualDesc[], int devQualDescLength, unsigned char oSpeedCfgDesc[], int oSpeedCfgDescLength, 
    unsigned char strDescs[][40], USB_SetupPacket_t &sp, chanend ?c_usb_test);
/**
 *  \brief      TBD
 */
int USB_GetSetupPacket(XUD_ep ep_out, XUD_ep ep_in, USB_SetupPacket_t &sp);

/**
 *  \brief Prints out passed SetupPacket struct using debug IO
 */
void USB_PrintSetupPacket(USB_SetupPacket_t sp);

#endif
