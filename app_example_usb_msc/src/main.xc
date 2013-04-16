/**
 * Module:  app_l1_usb_hid
 * Version: 1v5
 * Build:   85182b6a76f9342326aad3e7c15c1d1a3111f60e
 * File:    main.xc
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
#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <stdio.h>
#include <xs1_su.h>
#include <xclib.h>

#include "xud.h"
#include "usb.h"
#include "mass_storage.h"

unsigned g_adcVal;
#define XUD_EP_COUNT_OUT   2
#define XUD_EP_COUNT_IN    2

#ifdef XDK
#warning BUILDING FOR XDK
#define USB_RST_PORT    XS1_PORT_1B
#define USB_CORE        1
#else
/* L1 USB Audio Board */
#define USB_RST_PORT    XS1_PORT_32A
#define USB_CORE        0
#endif


out port p = XS1_PORT_1I;
clock cl = XS1_CLKBLK_2;



/* Endpoint type tables */
XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL};

/* USB Port declarations */
on stdcore[USB_CORE]: out port p_usb_rst = USB_RST_PORT;
on stdcore[USB_CORE]: clock    clk       = XS1_CLKBLK_3;

void Endpoint0( chanend c_ep0_out, chanend c_ep0_in, chanend ?c_usb_test);


/*
 * The main function fires of three processes: the XUD manager, Endpoint 0, and hid. An array of
 * channels is used for both in and out endpoints, endpoint zero requires both, hid is just an
 * IN endpoint.
 */


int main(void) 
{
    chan c_ep_out[2], c_ep_in[2];
#ifdef TEST_MODE_SUPPORT
#warning Building with USB test mode support     
    chan c_usb_test;
#else
#define c_usb_test null
#endif

    chan c;

    par 
    {
      
#if 1
        on stdcore[USB_CORE]: XUD_Manager( c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                null, epTypeTableOut, epTypeTableIn,
                                p_usb_rst, clk, -1, XUD_SPEED_HS, c_usb_test); 

        on stdcore[USB_CORE]:
        {
            set_thread_fast_mode_on();
            Endpoint0( c_ep_out[0], c_ep_in[0], c_usb_test);
        }
       
        on stdcore[USB_CORE]:
        {
            set_thread_fast_mode_on();
            massStorageClass(c_ep_out[1], c_ep_in[1], 0);
        }
#endif
    }

    return 0;
}
