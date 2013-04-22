/** 
 * @brief      Implements standard USB requests 
 * @author     Ross Owen, XMOS Limited
 */

#include <safestring.h>
#include <xs1.h>

#include "xud.h"     /* XUD Functions and defines */
#include "usb_device.h"     /* Defines related to the USB 2.0 Spec */

#ifndef MAX_INTS
/* Maximum number of interfaces supported */
#define MAX_INTS    16
#endif

#ifndef MAX_EPS
/* Maximum number of EP's supported */
#define MAX_EPS     16
#endif

unsigned char g_current_config = 0;
unsigned char g_interface_alt[MAX_INTS]; /* Global endpoint status arrays */

unsigned short g_epStatusOut[MAX_EPS];
unsigned short g_epStatusIn[MAX_EPS];

void USB_ParseSetupPacket(unsigned char b[], USB_SetupPacket_t &p)
{
  // Byte 0: bmRequestType.
  p.bmRequestType.Recipient = b[0] & 0x1f;
  p.bmRequestType.Type      = (b[0] & 0x60) >> 5;
  p.bmRequestType.Direction = b[0] >> 7;

  // Byte 1:  bRequest 
  p.bRequest = b[1];

  // Bytes [2:3] wValue
  p.wValue = (b[3] << 8) | (b[2]);

  // Bytes [4:5] wIndex
  p.wIndex = (b[5] << 8) | (b[4]);

  // Bytes [6:7] wLength
  p.wLength = (b[7] << 8) | (b[6]);

}


#pragma unsafe arrays
int USB_GetSetupPacket(XUD_ep ep_out, XUD_ep ep_in, USB_SetupPacket_t &sp)
{
    unsigned char sbuffer[120];
    int retVal;

    retVal = XUD_GetSetupBuffer(ep_out, ep_in, sbuffer);

    if(retVal < 0)
    {
        return retVal;
    }

    /* Parse data buffer end populate SetupPacket struct */
    USB_ParseSetupPacket(sbuffer, sp);

    /* Return 0 for success */
    return 0;
}

/* Used when setting/clearing EP halt */
int SetEndpointHalt(unsigned epNum, unsigned halt)
{
    /* Inspect for IN bit */
    if( epNum & 0x80 )
    {
        epNum &= 0x7f;

        /* Range check */
        if(epNum < MAX_EPS)
        {
            g_epStatusIn[ epNum & 0x7F ] = halt;  
            if(halt)
                XUD_SetStall_In(epNum);
            else
                XUD_ClearStall_In(epNum);
            return 0;
        }
    }
    else
    {
        if(epNum < MAX_EPS)
        {
            g_epStatusOut[epNum] = halt;
            if(halt)
                XUD_SetStall_Out(epNum);
            else
                XUD_ClearStall_Out(epNum);
            
            return 0;  
        }
    }

    return 1;
}



/* This function deals with common requests
 * This includes Standard Device Requests listed in table 9-3 of the USB 2.0 Spec
 * all devices must respond to these requests, in some cases a bare minimum implementation 
 * is provided and should be extended in the devices EP0 code 
 */
#pragma unsafe arrays
int USB_StandardRequests(XUD_ep c, XUD_ep c_in, unsigned char devDesc[], int devDescLength, unsigned char cfgDesc[], int cfgDescLength,
    unsigned char devQualDesc[], int devQualDescLength, unsigned char oSpeedCfgDesc[], int oSpeedCfgDescLength, 
    unsigned char strDescs[][40], USB_SetupPacket_t &sp, chanend ?c_usb_test)
{
     /* Return value */
    int datalength;
    int stringID = 0;

    /* Buffer for Setup data */
    unsigned char buffer[120]; 
    
    /* Stick bmRequest type back together for an easier parse... */
    unsigned bmRequestType = (sp.bmRequestType.Direction<<7) | (sp.bmRequestType.Type<<5) | (sp.bmRequestType.Recipient);
    
    switch(bmRequestType)
    {
        /* Standard Device Requests - To Device */
        case BMREQ_H2D_STANDARD_DEV:
 
            /* Inspect for actual request */
            switch(sp.bRequest)
            {
                /* Standard Device Request: ClearFeature (USB Spec 9.4.1) */
                case CLEAR_FEATURE:
                            
                    /* Device Features than could potenially be cleared are as follows (See Figure 9-4)
                     * Self Powered: Cannot be changed by SetFeature() or ClearFeature()
                     * Remote Wakeup: Indicates if the device is currently enabled to request remote wakeup.
                       by default not implemented
                     */
                    break;
                    
                /* Standard Device Request: Set Address (USB spec 9.6.4) */
                /* This is a unique request since the operation is not completed until after the status stage */
                case SET_ADDRESS:
                    
                    if((sp.wValue < 128) && (sp.wIndex == 0) && (sp.wLength == 0))
                    {
                        int retVal;

                        /* Status stage: Send a zero length packet */
                        retVal = XUD_DoSetRequestStatus(c_in);
                        if(retVal < 0)
                            return retVal;

                        /* Note: Really we should wait until ACK is received for status stage before changing address
                         * We will just wait some time... */
                        {
                            timer t;
                            unsigned time;
                            t :> time;
                            t when timerafter(time+50000) :> void;
                        }

                        /* Set the device address in XUD */
                        XUD_SetDevAddr(sp.wValue);

                        /* Return 0 to indicate request handled successfully */
                        return 0;
                    }
                    break;
                    
                /* Standard Device Request: SetConfiguration (USB Spec 9.4.7) */
                case SET_CONFIGURATION:

                    if((sp.wLength == 0) && (sp.wIndex == 0))
                    {                        
                        /* We can ignore sp.Direction if sp.wLength is 0. See USB Spec 9.3.1 */

                        /* Update global configuration value 
                         * Note alot of devices maye wish to implement features here since this 
                         * request indicates the device being placed into its "Configured" state
                         * i.e. the host has accepted the device */
                         g_current_config = sp.wValue;
                        
                        /* No data stage for this request, just do status stage */
                        return XUD_DoSetRequestStatus(c_in);
                    }
                    break;

                /* Standard Device Request: SetDescriptor (USB Spec 9.4.8) */
                case SET_DESCRIPTOR: 

                    /* Optional request for updating or adding new descriptors */
                    /* Not implemented by default */

                    break;
                    
#ifdef TEST_MODE_SUPPORT
                 /* Standard Device Request: SetFeature (USB Spec 9.4.9) */
                 case SET_FEATURE:

                    /* Check we have a test mode channel to XUD.. */
                    if(!isnull(c_usb_test))
                    {
                        if((sp.wValue == TEST_MODE) && (sp.wLength == 0))
                        {
                            /* Inspect for Test Selector (high byte of wIndex, lower byte must be zero) */
                            switch(sp.wIndex)
                            {
                                case WINDEX_TEST_J:
                                case WINDEX_TEST_K:
                                case WINDEX_TEST_SE0_NAK:         
                                case WINDEX_TEST_PACKET:          
                                case WINDEX_TEST_FORCE_ENABLE:    
                                    {
                                        int retVal;
                                        retVal = XUD_DoSetRequestStatus(c_in);                                      
                                        if(retVal < 0)
                                            return retVal;
                                                
                                        c_usb_test <: (unsigned)sp.wIndex;

                                    }
                                    break;
                            }
                        }
                    } 
                    break;
#endif 
            }
            break;

        /* Standard Device Requests - To Host */
        case BMREQ_D2H_STANDARD_DEV:

            switch(sp.bRequest)
            {
                /* Standard Device Request: GetStatus (USB Spec 9.4.5)*/
                case GET_STATUS:
                        
                    /* Remote wakeup not supported */
                    buffer[1] = 0;
                            
                    /* Pull self/bus powered bit from the config descriptor */
                    if (cfgDesc[7] & 0x40)
                        buffer[0] = 0x1;
                    else
                        buffer[0] = 0;
                    
                    return XUD_DoGetRequest(c, c_in, buffer, 2, sp.wLength);

                /* Standard Device Request: GetConfiguration (USB Spec 9.4.2) */
                case GET_CONFIGURATION:

                    /* Return the current configuration of the device */
                    if((sp.wValue == 0) && (sp.wIndex == 0) && (sp.wLength == 1))
                    {
                        buffer[0] = (char)g_current_config;
                        return XUD_DoGetRequest(c, c_in, buffer, 1, sp.wLength);
                    }
                    break;

                /* Standard Device Request: GetDescriptor (USB Spec 9.4.3)*/
                case GET_DESCRIPTOR:
              
                    /* Inspect for which Type of descriptor is required (high byte of wValue) */
                    switch(sp.wValue & 0xff00)
                    {
                        /* Device descriptor */
                        case WVALUE_GETDESC_DEV:              
    
                            /* Currently only 1 device descriptor supported */
                            if((sp.wValue & 0xff) == 0) 
                            {            
                                /* Do get request (send descriptor then 0 length status stage) */
                                return XUD_DoGetRequest(c, c_in, devDesc, devDescLength, sp.wLength); 
                            }
                            break;

                        /* Configuration Descriptor */
                        case WVALUE_GETDESC_CONFIG:
 
                            /* Currently only 1 configuration descriptor supported */
                            /* TODO We currently return the same for all configs */
                            //if((sp.wValue & 0xff) == 0)
                            {                  
                                /* Do get request (send descriptor then 0 length status stage) */
				                return XUD_DoGetRequest(c, c_in,  cfgDesc, cfgDescLength, sp.wLength); 
                            }
                            break;

                        /* Device qualifier descriptor */
                        case WVALUE_GETDESC_DEVQUAL:
 
                            if((sp.wValue & 0xff) == 0)
                            {
                                /* Do get request (send descriptor then 0 length status stage) */
                                return XUD_DoGetRequest(c, c_in, devQualDesc, devQualDescLength, sp.wLength); 
                            }
                            break;

                        /* Other Speed Configuration Descriptor */
                        case WVALUE_GETDESC_OSPEED_CFG:
    
                            if((sp.wValue & 0xff) == 0)
                            {
                                return  XUD_DoGetRequest(c, c_in,  oSpeedCfgDesc, oSpeedCfgDescLength, sp.wLength);
                            }
                            break;

                        /* String Descriptor */ 
                        case WVALUE_GETDESC_STRING:
 
                            /* Set descriptor type */
                            buffer[1] = STRING;

                            /* Send the string that was requested (low byte of wValue) */
                            /* First, generate valid descriptor from string */
                            /* TODO Bounds check */
                            stringID = sp.wValue & 0xff;

                            /* Microsoft OS String special case, send product ID string */
                            if (sp.wValue == 0x03ee)
                            {
                                stringID = 2;
                            }

                            datalength = safestrlen(strDescs[ stringID ] );
                
                            /* String 0 (LangIDs) is a special case*/ 
                            if( stringID == 0 )
                            {
                                buffer[0] = datalength + 2;
                                if( sp.wLength < datalength + 2 )
                                {
                                    datalength = sp.wLength - 2; 
                                }
                                for(int i = 0; i < datalength; i += 1 )
                                {
                                    buffer[i+2] = strDescs[stringID][i];
                                }
                            }
                            else
                            { 
                                 /* Datalength *= 2 due to unicode */
                                datalength <<= 1;
                      
                                /* Set data length in descriptor (+2 due to 2 byte datalength)*/
                                buffer[0] = datalength + 2;

                                if(sp.wLength < datalength + 2)
                                {
                                    datalength = sp.wLength - 2; 
                                }
                                /* Add zero bytes for unicode.. */
                                for(int i = 0; i < datalength; i+=2)
                                {
                                    buffer[i+2] = strDescs[ stringID ][i>>1];
                                    buffer[i+3] = 0;
                                }
                                       
                            }
                                    
                            /* Send back string */
                            return XUD_DoGetRequest(c, c_in, buffer, datalength + 2, sp.wLength); 
                            break;
                    }

            } //switch(sp.bRequest)
            break;

        /* Direction: Host-to-device
         * Type: Standard
         * Recipient: Interface
         */
        case BMREQ_H2D_STANDARD_INT:
 
            switch(sp.bRequest)
            {
                /* Standard Interface Request: SetInterface (USB Spec 9.4.10) */
                case SET_INTERFACE:
                    /* Note it is likely that a lot of devices will over-ride this request in their endpoint 0 code 
                    * For example, in an audio device this request would show the intent of the host to start streaming
                    */

                    if(sp.wLength == 0)
                    {
                        /* Pull number of interfaces from the Configuration Descriptor */
                        int numInterfaces = cfgDesc[4];
                           
                        /* Record interface change */
                        if((sp.wIndex < numInterfaces) && (sp.wIndex < MAX_INTS))
                        {
                            /* Note here we assume the host has given us a valid Alternate setting
                             *  It is hard for use to have a generic check for this here (without parsing the descriptors)
                             * If more robust checking is required this should be done in the endpoint 0 implementation
                             */
                            g_interface_alt[sp.wIndex] = sp.wValue;
                        }
                
                        /* No data stage for this request, just do data stage */
                        return XUD_DoSetRequestStatus(c_in);
                    }
                    break;
            }
            break;

        /* Direction: Device-to-host
         * Type: Standard
         * Recipient: Interface
         */
        case BMREQ_D2H_STANDARD_INT:

            switch(sp.bRequest)
            {
                case GET_INTERFACE:

                    if((sp.wValue == 0) && (sp.wLength == 1))
                    {
                        /* Pull number of interfaces from the Configuration Descriptor */
                        int numInterfaces = cfgDesc[4];

                        if( (sp.wIndex < numInterfaces) && (sp.wIndex < MAX_INTS))
                        {
                            buffer[0] = g_interface_alt[sp.wIndex];
                        
                            return XUD_DoGetRequest(c, c_in,  buffer, 1, sp.wLength);
                        }
                    }
                    break;
            }
            break;
 
        /* Direction: Host-to-device
         * Type: Standard
         * Recipient: Endpoint
         */
        case BMREQ_H2D_STANDARD_EP:

            switch(sp.bRequest)
            {
                /* Standard Endpoint Request: SetFeature (USB Spec 9.4.9) */
                case SET_FEATURE:
               
                    if(sp.wLength == 0)
                    {
                        /* The only Endpoint feature selector is HALT (bit 0) see figure 9-6 */ 
                        if(sp.wValue == ENDPOINT_HALT)  
                        {
                            /* Returns 0 on non-error */
                            if(!SetEndpointHalt(sp.wIndex, 1))
                            {
                                return XUD_DoSetRequestStatus(c_in);
                            }
                        }
                    }
                    break;

                /* Standard Endpoint Request: ClearFeature (USB Spec 9.4.1) */
                case CLEAR_FEATURE:

                    if(sp.wLength == 0)
                    {
                        /* The only feature selector for Endpoint is ENDPOINT_HALT */
                        if(sp.wValue == ENDPOINT_HALT)
                        {
                            /* Returns 0 on non-error */
                            if(!SetEndpointHalt(sp.wIndex, 0))
                            {
                                return XUD_DoSetRequestStatus(c_in);
                            }
                        }
                    }
                    break;
            }
            break;
        
        /* Direction: Host-to-device
         * Type: Standard
         * Recipient: Endpoint
         */
        case BMREQ_D2H_STANDARD_EP:

            switch(sp.bRequest)
            {
                /* Standard Endpoint Request: GetStatus (USB Spec 9.4.5) */
                case GET_STATUS:

                    /* Note: The only status for an EP is Halt (bit 0) */
                    /* Note: Without parsing the descriptors we don't know how many endpoints the device has... */
                    if((sp.wValue == 0) && (sp.wLength == 2))
                    {
                        buffer[0] = 0;
                        buffer[1] = 0;

                        if( sp.wIndex & 0x80 )
                        {
                            /* IN Endpoint */
                            if((sp.wIndex&0x7f) < MAX_EPS)
                            {
                                buffer[0] = ( g_epStatusIn[ sp.wIndex & 0x7F ] & 0xff );
                                buffer[1] = ( g_epStatusIn[ sp.wIndex & 0x7F ] >> 8 );
                                return XUD_DoGetRequest(c, c_in, buffer,  2, sp.wLength);
                            }
                        }
                        else
                        {
                            /* OUT Endpoint */
                            if(sp.wIndex < MAX_EPS)
                            {
                                buffer[0] = ( g_epStatusOut[ sp.wIndex ] & 0xff );
                                buffer[1] = ( g_epStatusOut[ sp.wIndex ] >> 8 );
                                return XUD_DoGetRequest(c, c_in, buffer,  2, sp.wLength);
                            }
                        }
                                   
                    }
                    break;
            }
            break; 
            
    } //switch(bmRequestType)


    /* If we get this far we did not handle request - Protocol Stall Secion 8.4.5 of USB 2.0 spec 
     * Detailed in Section 8.5.3. Protocol stall is unique to control pipes. 
     * Protocol stall differs from functional stall in meaning and duration. 
     * A protocol STALL is returned during the Data or Status stage of a control 
     * transfer, and the STALL condition terminates at the beginning of the 
     * next control transfer (Setup). The remainder of this section refers to 
     * the general case of a functional stall */
    XUD_SetStall_Out(0);
    XUD_SetStall_In(0);
    return 1;
}
