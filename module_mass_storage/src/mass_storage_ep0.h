extern int MassStorageEndpoint0Requests(XUD_ep c_ep0_out, XUD_ep c_ep0_in, SetupPacket sp);


#define MASS_STORAGE_DESCRIPTOR(epo, epi) \
  0x09,                /* 0  bLength */ \
  0x04,                /* 1  bDescriptorType */  \
  0x00,                /* 2  bInterfacecNumber */ \
  0x00,                /* 3  bAlternateSetting */ \
  0x02,                /* 4: bNumEndpoints */ \
  0x08,                /* 5: bInterfaceClass */  \
  0x06,                /* 6: bInterfaceSubClass */  \
  0x50,                /* 7: bInterfaceProtocol*/  \
  0x00,                /* 8  iInterface */  \
   \
  0x07,                /* 0  bLength */  \
  0x05,                /* 1  bDescriptorType */  \
  0x01,                /* 2  bEndpointAddress */  \
  0x02,                /* 3  bmAttributes */  \
  0x00,                /* 4  wMaxPacketSize */  \
  0x02,                /* 5  wMaxPacketSize */  \
  0x00,                /* 6  bInterval */  \
 \
  0x07,                /* 0  bLength */  \
  0x05,                /* 1  bDescriptorType */  \
  0x81,                /* 2  bEndpointAddress */  \
  0x02,                /* 3  bmAttributes */  \
  0x00,                /* 4  wMaxPacketSize */  \
  0x02,                /* 5  wMaxPacketSize */  \
  0x00                 /* 6  bInterval */ 
