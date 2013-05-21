//#include <xs1.h>
#include <platform.h>
#include <stdio.h>

#include "xud.h"
#include "usb.h"

#define XUD_EP_COUNT_OUT   2
#define XUD_EP_COUNT_IN    2

/* Prototype for Endpoint0 function in endpoint0.xc */
void Endpoint0( chanend c_ep0_out, chanend c_ep0_in, chanend ?c_usb_test);

/* Endpoint type tables - infoms XUD what the transfer types for each Endpoint in use and also
 * if the endpoint wishes to be informed of USB bus resets 
 */
XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL | XUD_STATUS_ENABLE};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL | XUD_STATUS_ENABLE};

#ifdef L_SERIES
/* USB reset port declarations for L series on L1 USB Audio board */
on stdcore[0]: out port p_usb_rst        = XS1_PORT_32A;
on stdcore[0]: clock    clk_usb_rst      = XS1_CLKBLK_3;
#else
/* USB Reset not required for U series - pass null to XUD */
#define p_usb_rst null
#define clk_usb_rst null
#endif

#define BUFFER_SIZE 128
void bulk_endpoint(chanend chan_ep_from_host, chanend chan_ep_to_host) 
{
    int host_transfer_buf[BUFFER_SIZE];
    int host_transfer_length = 0;

    XUD_ep ep_from_host = XUD_InitEp(chan_ep_from_host);
    XUD_ep ep_to_host = XUD_InitEp(chan_ep_to_host);

    printstrln("Starting...");

    while(1) 
    {
        host_transfer_length = XUD_GetBuffer(ep_from_host, (host_transfer_buf, char[BUFFER_SIZE * 4]));
        if (host_transfer_length < 0) {
            XUD_ResetEndpoint(ep_from_host, ep_to_host);
            continue;
        }

        for (int i = 0; i < host_transfer_length/4; i++) {
            host_transfer_buf[i]++;
        }
        host_transfer_length = XUD_SetBuffer(ep_to_host, (host_transfer_buf, char[BUFFER_SIZE * 4]), host_transfer_length);
        if (host_transfer_length < 0)
            XUD_ResetEndpoint(ep_from_host, ep_to_host);
    }
}

/*
 * The main function runs three tasks: the XUD manager, Endpoint 0, and bulk endpoint. An array of
 * channels is used for both IN and OUT endpoints, endpoint zero requires both, buly requires an IN 
 * and an OUT endpoint to receive and send a data buffer to the host.
 */
int main() 
{
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];

    par 
    {
        on stdcore[0]: XUD_Manager(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                   null, epTypeTableOut, epTypeTableIn,
                                   p_usb_rst, clk_usb_rst, -1, XUD_SPEED_HS, null); 

        on stdcore[0]: Endpoint0(c_ep_out[0], c_ep_in[0], null);
       
        on stdcore[0]: bulk_endpoint(c_ep_out[1], c_ep_in[1]);
    }

    return 0;
}
