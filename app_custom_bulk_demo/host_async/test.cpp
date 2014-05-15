/*
 * libusb example program to test XMOS isochronous performance
 *
 * Based on libusb example program to measure Atmel SAM3U isochronous performance
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>

#include <libusb.h>

#define DEVICE_VID   0x20B1   /* XMOS VID */
#define DEVICE_PID   0x00B1

#define EP_ISO_IN    0x81
#define EP_ISO_OUT   0x01

typedef enum
{
   TRANSFER_TYPE_ISO,
   TRANSFER_TYPE_BULK,
} transfertype_t;

static int do_exit = 0;
static struct libusb_device_handle *devh = NULL;

static unsigned long num_bytes = 0, num_xfer = 0;
static struct timeval tv_start;

static void cb_xfr_out (struct libusb_transfer *xfr)
{
    unsigned int i;

    fprintf(stdout, "OUT BUFFER\n");
}

static void cb_xfr(struct libusb_transfer *xfr)
{
    unsigned int i;

    fprintf(stdout, "IN BUFFER\n");

    if (xfr->status != LIBUSB_TRANSFER_COMPLETED) {
        fprintf(stderr, "transfer status %d\n", xfr->status);
        libusb_free_transfer(xfr);
        exit(3);
    }

#if 1
    if (xfr->type == LIBUSB_TRANSFER_TYPE_ISOCHRONOUS) {
        for (i = 0; i < xfr->num_iso_packets; i++) {
            struct libusb_iso_packet_descriptor *pack = &xfr->iso_packet_desc[i];

            if (pack->status != LIBUSB_TRANSFER_COMPLETED) {
                fprintf(stderr, "Error: pack %u status %d\n", i, pack->status);
                exit(5);
            }

            printf("pack%u length:%u, actual_length:%u\n", i, pack->length, pack->actual_length);
        }
    }
#endif
    printf("length:%u, actual_length:%u\n", xfr->length, xfr->actual_length);
    for (i = 0; i < xfr->length; i++) {
        printf("%02x", xfr->buffer[i]);
        //if (i % 16)
          //  printf("\n");
        //else if (i % 8)
          //  printf("  ");
        //else
            printf(" ");
    }
    num_bytes += xfr->actual_length;
    num_xfer++;

   // if (libusb_submit_transfer(xfr) < 0) {
    //    fprintf(stderr, "error re-submitting URB\n");
    //    exit(1);
   // }
}

static int benchmark_in(uint8_t ep)
{
    static uint8_t buf[2048];
    static struct libusb_transfer *xfr;
    int num_iso_pack = 0;

    if (ep == EP_ISO_IN)
        num_iso_pack = 16;

    xfr = libusb_alloc_transfer(num_iso_pack);
    if (!xfr)
        return -ENOMEM;

    if (ep == EP_ISO_IN) 
    {
        libusb_fill_iso_transfer(xfr, devh, ep, buf,
                sizeof(buf), num_iso_pack, cb_xfr, NULL, 0);
        libusb_set_iso_packet_lengths(xfr, sizeof(buf)/num_iso_pack);
    } 
    else
    {
        libusb_fill_bulk_transfer(xfr, devh, ep, buf, sizeof(buf), cb_xfr, NULL, 0);
    }

    gettimeofday(&tv_start, NULL);

    /* NOTE: To reach maximum possible performance the program must
     * submit *multiple* transfers here, not just one.
     *
     * When only one transfer is submitted there is a gap in the bus
     * schedule from when the transfer completes until a new transfer
     * is submitted by the callback. This causes some jitter for
     * isochronous transfers and loss of throughput for bulk transfers.
     *
     * This is avoided by queueing multiple transfers in advance, so
     * that the host controller is always kept busy, and will schedule
     * more transfers on the bus while the callback is running for
     * transfers which have completed on the bus.
     */

    return libusb_submit_transfer(xfr);
}
static int benchmark_out_in(uint8_t ep_out, uint8_t ep_in, transfertype_t transtype)
{
    static uint8_t buf[2048];
    static struct libusb_transfer *xfr_in, *xfr_out;
    int num_iso_pack = 0;

    if (ep_in == EP_ISO_IN)
        num_iso_pack = 16;

    xfr_in = libusb_alloc_transfer(num_iso_pack);
    if (!xfr_in)
        return -ENOMEM;
    
    xfr_out = libusb_alloc_transfer(num_iso_pack);
    if (!xfr_out)
        return -ENOMEM;

    if (ep_in == EP_ISO_IN) 
    {
        libusb_fill_iso_transfer(xfr_in, devh, ep_in, buf,
                sizeof(buf), num_iso_pack, cb_xfr, NULL, 0);
        libusb_set_iso_packet_lengths(xfr_in, sizeof(buf)/num_iso_pack);

        libusb_fill_iso_transfer(xfr_out, devh, ep_out, buf,
                sizeof(buf), num_iso_pack, cb_xfr_out, NULL, 0);
        libusb_set_iso_packet_lengths(xfr_out, sizeof(buf)/num_iso_pack);
    } 
    else
    {
        /* TODO */
        libusb_fill_bulk_transfer(xfr_in, devh, ep_in, buf, sizeof(buf), cb_xfr, NULL, 0);
    }

    gettimeofday(&tv_start, NULL);

    /* NOTE: To reach maximum possible performance the program must
     * submit *multiple* transfers here, not just one.
     *
     * When only one transfer is submitted there is a gap in the bus
     * schedule from when the transfer completes until a new transfer
     * is submitted by the callback. This causes some jitter for
     * isochronous transfers and loss of throughput for bulk transfers.
     *
     * This is avoided by queueing multiple transfers in advance, so
     * that the host controller is always kept busy, and will schedule
     * more transfers on the bus while the callback is running for
     * transfers which have completed on the bus.
     */

    /* TODO.. this is not quite right.. */
    libusb_submit_transfer(xfr_out);
    return libusb_submit_transfer(xfr_in);
}

static void measure(void)
{
    struct timeval tv_stop;
    unsigned int diff_msec;

    gettimeofday(&tv_stop, NULL);

    diff_msec = (tv_stop.tv_sec - tv_start.tv_sec)*1000;
    diff_msec += (tv_stop.tv_usec - tv_start.tv_usec)/1000;

    printf("%lu transfers (total %lu bytes) in %u miliseconds => %lu bytes/sec\n",
        num_xfer, num_bytes, diff_msec, (num_bytes*1000)/diff_msec);
}

static void sig_hdlr(int signum)
{
    switch (signum) {
    case SIGINT:
        measure();
        do_exit = 1;
        break;
    }
}

int main(int argc, char **argv)
{
    int rc;
    struct sigaction sigact;

    sigact.sa_handler = sig_hdlr;
    sigemptyset(&sigact.sa_mask);
    sigact.sa_flags = 0;
    sigaction(SIGINT, &sigact, NULL);

    rc = libusb_init(NULL);
    if (rc < 0) 
    {
        //fprintf(stderr, "Error initializing libusb: %s\n", libusb_error_name(rc));
        fprintf(stderr, "Error initializing libusb\n");
        exit(1);
    }

    devh = libusb_open_device_with_vid_pid(NULL, DEVICE_VID, DEVICE_PID);
    if (!devh) 
    {
        fprintf(stderr, "Error finding USB device\n");
        goto out;
    }
    else
    {
        fprintf(stdout, "Opened USB device: %x %x\n", DEVICE_VID, DEVICE_PID);
    }

    rc = libusb_claim_interface(devh, 2);
    if (rc < 0) 
    {
        //fprintf(stderr, "Error claiming interface: %s\n", libusb_error_name(rc));
        fprintf(stderr, "Error claiming interface\n");
        goto out;
    }

    //benchmark_in(EP_ISO_IN);
    benchmark_out_in(EP_ISO_OUT, EP_ISO_IN, TRANSFER_TYPE_ISO);

    //while (!do_exit) 
    {
        rc = libusb_handle_events(NULL);
        if (rc != LIBUSB_SUCCESS)
        {
            //break;
        }
    }

    /* Measurement has already been done by the signal handler. */

    libusb_release_interface(devh, 0);
out:
    if (devh)
        libusb_close(devh);
    libusb_exit(NULL);
    return rc;
}
