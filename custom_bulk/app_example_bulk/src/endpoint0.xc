#include <xs1.h>
#include "usb_device.h"
#include "hid.h"

#define BCD_DEVICE   0x1000
#define VENDOR_ID    0x20B1
#define PRODUCT_ID   0xB100

/* Device Descriptor */
static unsigned char devDesc[] = 
{ 
    0x12,                  /* 0  bLength */
    USB_DEVICE,            /* 1  bdescriptorType */ 
    0x00,                  /* 2  bcdUSB */ 
    0x02,                  /* 3  bcdUSB */ 
    0xFF,                  /* 4  bDeviceClass */ 
    0xFF,                  /* 5  bDeviceSubClass */ 
    0xFF,                  /* 6  bDeviceProtocol */ 
    0x40,                  /* 7  bMaxPacketSize */ 
    (VENDOR_ID & 0xFF),    /* 8  idVendor */ 
    (VENDOR_ID >> 8),      /* 9  idVendor */ 
    (PRODUCT_ID & 0xFF),   /* 10 idProduct */ 
    (PRODUCT_ID >> 8),     /* 11 idProduct */ 
    (BCD_DEVICE & 0xFF),   /* 12 bcdDevice */
    (BCD_DEVICE >> 8),     /* 13 bcdDevice */
    0x01,                  /* 14 iManufacturer */
    0x02,                  /* 15 iProduct */
    0x00,                  /* 16 iSerialNumber */
    0x01                   /* 17 bNumConfigurations */
};


/* Configuration Descriptor */
static unsigned char cfgDesc[] = {  
  0x09,                 /* 0  bLength */ 
  0x02,                 /* 1  bDescriptortype */ 
  0x20, 0x00,           /* 2  wTotalLength */ 
  0x01,                 /* 4  bNumInterfaces */ 
  0x01,                 /* 5  bConfigurationValue */
  0x04,                 /* 6  iConfiguration */
  0x80,                 /* 7  bmAttributes */ 
  0xFA,                 /* 8  bMaxPower */
  
  0x09,                 /* 0  bLength */
  0x04,                 /* 1  bDescriptorType */ 
  0x00,                 /* 2  bInterfacecNumber */
  0x00,                 /* 3  bAlternateSetting */
  0x02,                 /* 4: bNumEndpoints */
  0xFF,                 /* 5: bInterfaceClass */ 
  0xFF,                 /* 6: bInterfaceSubClass */ 
  0xFF,                 /* 7: bInterfaceProtocol*/ 
  0x03,                 /* 8  iInterface */ 
  
  0x07,                 /* 0  bLength */ 
  0x05,                 /* 1  bDescriptorType */ 
  0x01,                 /* 2  bEndpointAddress */ 
  0x02,                 /* 3  bmAttributes */ 
  0x00,                 /* 4  wMaxPacketSize */ 
  0x02,                 /* 5  wMaxPacketSize */ 
  0x01,                  /* 6  bInterval */ 
  
  0x07,                 /* 0  bLength */ 
  0x05,                 /* 1  bDescriptorType */ 
  0x81,                 /* 2  bEndpointAddress */ 
  0x02,                 /* 3  bmAttributes */ 
  0x00,                 /* 4  wMaxPacketSize */ 
  0x02,                 /* 5  wMaxPacketSize */ 
  0x01                  /* 6  bInterval */ 
}; 

/* String table */
static unsigned char stringDescriptors[][40] = 
{
    "\\004\\009",                              // Language string
    "XMOS",                                    // iManufacturer 
    "XMOS Custom Bulk Transfer Device",        // iProduct
    "",                                        // unUsed
    "Config",                                  // iConfiguration
};

/* Endpoint 0 Task */
void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in, chanend ?c_usb_test)
{
    USB_SetupPacket_t sp;
    XUD_BusSpeed usbBusSpeed;
    XUD_ep ep0_out = XUD_InitEp(chan_ep0_out);
    XUD_ep ep0_in  = XUD_InitEp(chan_ep0_in);
    
    while(1)
    {
        /* Returns 0 on success, < 0 for USB RESET */
        int retVal = USB_GetSetupPacket(ep0_out, ep0_in, sp);
        
        if(retVal > 0)
        {
            /* Returns  0 if handled okay,
             *          1 if request was not handled (STALLed),
             *         -1 of USB Reset */
            retVal = USB_StandardRequests(ep0_out, ep0_in, devDesc,
                        sizeof(devDesc), cfgDesc, sizeof(cfgDesc),
                        null, 0, null, 0, stringDescriptors, sp,
                        c_usb_test, usbBusSpeed);
        }

        /* USB bus reset detected, reset EP and get new bus speed */
        if(retVal < 0)
        {
            usbBusSpeed = XUD_ResetEndpoint(ep0_out, ep0_in);
        }
    }
}
//: 


 




