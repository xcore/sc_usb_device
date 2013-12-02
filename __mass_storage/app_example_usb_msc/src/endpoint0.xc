/**
 **/

#include <xs1.h>
#include <print.h>
#include "xud.h"
#include "usb.h"
#include "mass_storage.h"
#include "mass_storage_ep0.h"
#include "DescriptorRequests.h"

// This devices Device Descriptor:
static unsigned char hiSpdDesc[] = {
  0x12,                /* 0  bLength */
  0x01,                /* 1  bdescriptorType */
  0x00,                /* 2  bcdUSB */
  0x02,                /* 3  bcdUSB */
  0x00,                /* 4  bDeviceClass */
  0x00,                /* 5  bDeviceSubClass */
  0x00,                /* 6  bDeviceProtocol */
  0x40,                /* 7  bMaxPacketSize */
  0xb1,                /* 8  idVendor */
  0x20,                /* 9  idVendor */
  0xBA,                /* 10 idProduct */
  0x10,                /* 11 idProduct */
  0x10,                /* 12 bcdDevice */
  0x00,                /* 13 bcdDevice */
  0x01,                /* 14 iManufacturer */
  0x02,                /* 15 iProduct */
  0x00,                /* 16 iSerialNumber */
  0x01                 /* 17 bNumConfigurations */
};

unsigned char fullSpdDesc[] =
{
    0x0a,              /* 0  bLength */
    DEVICE_QUALIFIER,  /* 1  bDescriptorType */
    0x00,              /* 2  bcdUSB */
    0x02,              /* 3  bcdUSB */
    0x00,              /* 4  bDeviceClass */
    0x00,              /* 5  bDeviceSubClass */
    0x00,              /* 6  bDeviceProtocol */
    0x40,              /* 7  bMaxPacketSize */
    0x01,              /* 8  bNumConfigurations */
    0x00               /* 9  bReserved  */
};


static unsigned char hiSpdConfDesc[] = {
  0x09,                /* 0  bLength */
  0x02,                /* 1  bDescriptortype */
  0x20, 0x00,          /* 2  wTotalLength */
  0x01,                /* 4  bNumInterfaces */
  0x01,                /* 5  bConfigurationValue */
  0x00,                /* 6  iConfiguration */
  0x00,                /* 7  bmAttributes */
  0x50,                /* 8  bMaxPower */

  MASS_STORAGE_DESCRIPTOR(0x01, 0x81)
};

#define NUM_EP_OUT 2
#define NUM_EP_IN 2

unsigned char fullSpdConfDesc[] =
{
    0x09,              /* 0  bLength */
    OTHER_SPEED_CONFIGURATION,      /* 1  bDescriptorType */
    0x12,              /* 2  wTotalLength */
    0x00,              /* 3  wTotalLength */
    0x01,              /* 4  bNumInterface: Number of interfaces*/
    0x00,              /* 5  bConfigurationValue */
    0x00,              /* 6  iConfiguration */
    0x80,              /* 7  bmAttributes */
    0xC8,              /* 8  bMaxPower */

    0x09,              /* 0 bLength */
    0x04,              /* 1 bDescriptorType */
    0x00,              /* 2 bInterfaceNumber */
    0x00,              /* 3 bAlternateSetting */
    0x00,              /* 4 bNumEndpoints */
    0x00,              /* 5 bInterfaceClass */
    0x00,              /* 6 bInterfaceSubclass */
    0x00,              /* 7 bInterfaceProtocol */
    0x00,              /* 8 iInterface */

};


static unsigned char stringDescriptors[][40] = {
	"\\004\\009",                      // Language string
  	"XMOS",				               // iManufacturer
 	"xMASSstorage",          		   // iProduct
};


extern int min(int a, int b);

/* Global endpoint status arrays */
#if (NUM_EP_OUT > 0)
unsigned g_epStatusOut[NUM_EP_OUT];
#endif
unsigned g_epStatusIn[NUM_EP_IN];

/* Used when setting/clearing EP halt */
void SetEndpointStatus(unsigned epNum, unsigned status)
{
  /* Inspect for IN bit */
    if( epNum & 0x80 )
    {
        epNum &= 0x7f;

        /* Range check */
        if(epNum < NUM_EP_IN)
        {
            g_epStatusIn[ epNum & 0x7F ] = status;
        }
    }
#if (NUM_EP_OUT > 0)
    else
    {
        if(epNum < NUM_EP_OUT)
        {
            g_epStatusOut[ epNum ] = status;
        }
    }
#endif
}



void Endpoint0( chanend chan_ep0_out, chanend chan_ep0_in, chanend ?c_usb_test)
{
    unsigned char buffer[1024];
    SetupPacket sp;
    unsigned int current_config = 0;

    XUD_ep c_ep0_out = XUD_Init_Ep(chan_ep0_out);
    XUD_ep c_ep0_in  = XUD_Init_Ep(chan_ep0_in);

    while(1)
    {
        /* Do standard enumeration requests */
        int retVal = 1;

        retVal = DescriptorRequests(c_ep0_out, c_ep0_in, hiSpdDesc, sizeof(hiSpdDesc),
            hiSpdConfDesc, sizeof(hiSpdConfDesc), fullSpdDesc, sizeof(fullSpdDesc),
            fullSpdConfDesc, sizeof(fullSpdConfDesc), stringDescriptors, sp, c_usb_test);

        if (retVal)
        {
            /* Request not covered by XUD_DoEnumReqs() so decode ourselves */
            switch(sp.bmRequestType.Type)
            {
                /* Class request */
                case BM_REQTYPE_TYPE_CLASS:
                    switch(sp.bmRequestType.Recipient)
                    {
                        case BM_REQTYPE_RECIP_INTER:

                            /* Inspect for HID interface num */
                            if(sp.wIndex == 0)
                            {
                                retVal = MassStorageEndpoint0Requests(c_ep0_out, c_ep0_in, sp);
                            }
                            break;

                    }
                    break;

                case BM_REQTYPE_TYPE_STANDARD:
                    switch(sp.bmRequestType.Recipient)
                    {
                        case BM_REQTYPE_RECIP_EP:

                            switch(sp.bRequest)
                            {
                                case CLEAR_FEATURE:

                                    switch(sp.wValue)
                                    {
                                        case ENDPOINT_HALT:
                                            /* Mark the endpoint status */
                                            SetEndpointStatus(sp.wIndex, 0);

                                            /* No data stage for this rquest, just do status stage */
                                            retVal = XUD_DoSetRequestStatus(c_ep0_in, 0);
                                            break;
                                    }
                                    break; // CLEAR_FEATURE

                                case SET_FEATURE:

                                    switch(sp.wValue)
                                    {
                                        case ENDPOINT_HALT:

                                            SetEndpointStatus(sp.wIndex, 1);

                                            retVal = XUD_DoSetRequestStatus(c_ep0_in, 0);
                                            break;
                                    }
                                    break;   // SET_FEATURE

                                case GET_STATUS:
                                    buffer[0] = 0;
                                    buffer[1] = 0;

                                    if( sp.wIndex & 0x80 )
                                    {
                                        /* IN Endpoint */
                                        if((sp.wIndex&0x7f) < NUM_EP_IN)
                                        {
                                            buffer[0] = ( g_epStatusIn[ sp.wIndex & 0x7F ] & 0xff );
                                            buffer[1] = ( g_epStatusIn[ sp.wIndex & 0x7F ] >> 8 );
                                        }
                                    }
#if (NUM_EP_OUT > 0)
                                    else
                                    {
                                        /* OUT Endpoint */
                                        if(sp.wIndex < NUM_EP_OUT)
                                        {
                                            buffer[0] = ( g_epStatusOut[ sp.wIndex ] & 0xff );
                                            buffer[1] = ( g_epStatusOut[ sp.wIndex ] >> 8 );
                                        }
                                    }
#endif
                                    retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer,  2, sp.wLength);

                                    break;   // GET_STATUS
                            }
                            break; // BM_REQTYPE_RECIP_EP

                        case BM_REQTYPE_RECIP_INTER:

                            switch(sp.bRequest)
                            {
                                /* Set Interface */
                                case SET_INTERFACE:

                                    /* TODO: Set the interface */

                                    /* No data stage for this request, just do data stage */
                                    XUD_DoSetRequestStatus(c_ep0_in, 0);
                                    break;

                                case GET_INTERFACE:
                                    buffer[0] = 0;
                                    XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer,1, sp.wLength );
                                    break;

                                case GET_STATUS:
                                    buffer[0] = 0;
                                    buffer[1] = 0;
                                    XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                                    break;

                            }
                            break;

                        /* Recipient: Device */
                        case BM_REQTYPE_RECIP_DEV:

                            /* Standard Device requests (8) */
                            switch( sp.bRequest )
                            {
                                /* TODO We could check direction to be double safe */
                                /* Standard request: SetConfiguration */
                                case SET_CONFIGURATION:

                                    /* Set the config */
                                    current_config = sp.wValue;

                                    /* No data stage for this request, just do status stage */
                                    retVal = XUD_DoSetRequestStatus(c_ep0_in,  0);
                                    break;

                                case GET_CONFIGURATION:
                                    buffer[0] = (char)current_config;
                                    retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 1, sp.wLength);
                                    break;

                                case GET_STATUS:
                                    buffer[0] = 0;
                                    buffer[1] = 0;
                                    if (hiSpdConfDesc[7] & 0x40)
                                        buffer[0] = 0x1;
                                    retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                                    break;

                                case SET_ADDRESS:
                                    /* Status stage: Send a zero length packet */
                                    retVal = XUD_SetBuffer(c_ep0_in,  buffer, 0);

                                    /* We should wait until ACK is received for status stage before changing address */
                                    {
                                        timer t;
                                        unsigned time;
                                        t :> time;
                                        t when timerafter(time+50000) :> void;
                                    }

                                    /* Set device address in XUD */
                                    XUD_SetDevAddr(sp.wValue);
                                    break;

                                default:
                                    break;

                            }
                            break;

                        default:
                            /* Got a request to a recipient we didn't recognise... */
                            break;
                    }
                    break;

                default:
                /* Error */
                break;

            }

        } /* if XUD_DoEnumReqs() */

        if(retVal == 1)
        {
            /* Did not handle request - Protocol Stall Secion 8.4.5 of USB 2.0 spec
             * Detailed in Section 8.5.3. Protocol stall is unique to control pipes.
               Protocol stall differs from functional stall in meaning and duration.
               A protocol STALL is returned during the Data or Status stage of a control
               transfer, and the STALL condition terminates at the beginning of the
               next control transfer (Setup). The remainder of this section refers to
               the general case of a functional stall */
              XUD_SetStall_Out(0);
              XUD_SetStall_In(0);
                XUD_PrintSetupPacket(sp);
        }
        else if (retVal == -1)
        {
            XUD_ResetEndpoint(c_ep0_out, c_ep0_in);
        }
    }
}
