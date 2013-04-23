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
 
#define USB_CORE        0
/* L1 USB Audio Board */
#define USB_RST_PORT    XS1_PORT_32A

#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <stdio.h>
#include <xs1_su.h>
#include "u_series_support.h"

#include "xud.h"
#include "usb.h"

#define EP_COUNT_OUT   1
#define EP_COUNT_IN    2

/* Endpoint type tables */
XUD_EpType epTypeTableOut[EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE};
XUD_EpType epTypeTableIn[EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL};

/* USB Port declarations */
on stdcore[USB_CORE]: out port p_usb_rst = USB_RST_PORT;
on stdcore[USB_CORE]: clock    clk       = XS1_CLKBLK_3;

void Endpoint0( chanend c_ep0_out, chanend c_ep0_in, chanend ?c_usb_test);

/* Global report buffer, global since used by Endpoint0 core */
unsigned char g_reportBuffer[] = {0, 0, 0, 0};

out port p_adc_trig = PORT_ADC_TRIGGER;
clock cl = XS1_CLKBLK_2;

#ifdef ADC
#define THRESH 20
#endif
#ifdef ADC

/*
 * This function responds to the HID requests - it moves the pointers x axis based on ADC input
 */
void hid_mouse(chanend c_ep_hid, chanend c_adc) 
{
    int lastX = 0;
 
    /* Iniialise the XUD endpoint */   
    XUD_ep ep_hid = XUD_InitEp(c_ep_hid);
    
    adc_config_t adc_config = { { 0, 0, 0, 0, 0, 0, 0, 0 }, 0, 0, 0 };

    adc_config.input_enable[0] = 1;
    adc_config.bits_per_sample = ADC_32_BPS;
    adc_config.samples_per_packet = 1;
    adc_config.calibration_mode = 0;

    adc_enable(xs1_su, c_adc, p_adc_trig, adc_config);

    g_reportBuffer[1] = 0;
    g_reportBuffer[2] = 0;
    
    while(1) 
    {
        unsigned data[1];
        int x;

        /* Get ADC input */
        adc_trigger_packet(p_adc_trig, adc_config);
        adc_read_packet(c_adc, adc_config, data);
        x = data[0];

        /* Move horizontal axis of pointer based on ADC val (absolute) */
        x = x>>20;
        x &= 0xff;
 
        x-= 128;

        if((x+THRESH > lastX) && (x-THRESH < lastX))
        {
            g_reportBuffer[1] = x;
        }

        lastX = x;
        
        /* Send the buffer off to the host.  Note this will return when complete */
        XUD_SetBuffer(ep_hid, g_reportBuffer, 4);
    }
}

#else
/*
 * This function responds to the HID requests - it draws a square using the mouse moving 40 pixels
 * in each direction in sequence every 100 requests.
 */
void hid_mouse(chanend chan_ep_hid, chanend ?c_adc) 
{
    int counter = 0;
    int state = 0;
    int lastX = 0;
    
    XUD_ep ep_hid = XUD_InitEp(chan_ep_hid);

    while(1) 
    {
        int x;
        g_reportBuffer[1] = 0;
        g_reportBuffer[2] = 0;

        /* Move the pointer around in a square (relative) */
        counter++;
        if(counter >= 500 ) 
        {
            counter = 0;
            if(state == 0) 
            {
                g_reportBuffer[1] = 40;
                g_reportBuffer[2] = 0; 
                state+=1;
            } 
            else if(state == 1) 
            {
                g_reportBuffer[1] = 0;
                g_reportBuffer[2] = 40;
                state+=1;
            } 
            else if(state == 2) 
            {
                g_reportBuffer[1] = -40;
                g_reportBuffer[2] = 0; 
                state+=1;
            } 
            else if(state == 3) 
            {
                g_reportBuffer[1] = 0;
                g_reportBuffer[2] = -40;
                state = 0;
            }
        } 
        
        /* Send the buffer off to the host.  Note this will return when complete */
        XUD_SetBuffer(ep_hid, g_reportBuffer, 4);
    }
}
#endif

/*
 * The main function runs thress cores: the XUD manager, Endpoint 0, and a HID endpoint. An array of
 * channels is used for both IN and OUT endpoints, endpoint zero requires both, hid is just an
 * IN endpoint.
 */
int main() 
{
    chan c_ep_out[EP_COUNT_OUT], c_ep_in[EP_COUNT_IN];
#ifdef TEST_MODE_SUPPORT
#warning Building with USB test mode support     
    chan c_usb_test;
#else
#define c_usb_test null
#endif

#ifdef ADC
    chan c_adc;
#else
#define c_adc null
#endif

    par 
    {
        on stdcore[USB_CORE]: XUD_Manager( c_ep_out, EP_COUNT_OUT, c_ep_in, EP_COUNT_IN,
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
            hid_mouse(c_ep_in[1], c_adc);
        }
        
#ifdef ADC
        xs1_su_adc_service(c_adc);
#endif
    }

    return 0;
}
