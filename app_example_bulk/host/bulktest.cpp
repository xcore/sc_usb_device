#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include "usb.h"
#else
#include "libusb.h"
#endif

/* the device's vendor and product id */
#define XMOS_BULK_VID 0x20b1
#define XMOS_BULK_PID 0xb1
#define XMOS_BULK_EP_IN 0x81
#define XMOS_BULK_EP_OUT 0x01

#ifdef _WIN32
static usb_dev_handle *devh = NULL;

static int find_xmos_bulk_device(unsigned int id) {
  struct usb_bus *bus;
  struct usb_device *dev;
  int found = 0;

  for (bus = usb_get_busses(); bus; bus = bus->next) {
    for (dev = bus->devices; dev; dev = dev->next) {
      if (dev->descriptor.idVendor == XMOS_BULK_VID && dev->descriptor.idProduct == XMOS_BULK_PID) {
        if (found == id) {
          devh = usb_open(dev);
          break;
        }
      }
    }
  }

  if (!devh)
    return -1;
  
  return 0;
}

static int open_bulk_device() {
  int r = 1;
  
  usb_init();
  usb_find_busses(); /* find all busses */
  usb_find_devices(); /* find all connected devices */

  r = find_xmos_bulk_device(0);
  if (r < 0) {
    fprintf(stderr, "Could not find/open device\n");
    return -1;
  }
 
  r = usb_set_configuration(devh, 1);
  if (r < 0) {
    fprintf(stderr, "Error setting config 1\n");
    usb_close(devh);
    return -1;
  }

  r = usb_claim_interface(devh, 0);
  if (r < 0) {
    fprintf(stderr, "Error claiming interface %d %d\n", 0, r);
    return -1;
  }

  return 0;
}

static int close_bulk_device() {
  usb_release_interface(devh, 0);
  usb_close(devh);
  return 0;
}

int read_bulk_device(char *data, unsigned int length, unsigned int timeout) {
  int result = 0;
  result = usb_bulk_read(devh, XMOS_BULK_EP_IN, data, length, timeout);
  return result;
}

int write_bulk_device(char *data, unsigned int length, unsigned int timeout) {
  int result = 0;
  result = usb_bulk_write(devh, XMOS_BULK_EP_OUT, data, length, timeout);
  return result;
}

#else 
static libusb_device_handle *devh = NULL;

static int find_xmos_bulk_device(unsigned int id) {
  libusb_device *dev;
  libusb_device **devs;
  int i = 0;
  int found = 0;
  
  libusb_get_device_list(NULL, &devs);

  while ((dev = devs[i++]) != NULL) {
    struct libusb_device_descriptor desc;
    libusb_get_device_descriptor(dev, &desc); 
    if (desc.idVendor == XMOS_BULK_VID && desc.idProduct == XMOS_BULK_PID) {
      if (found == id) {
        if (libusb_open(dev, &devh) < 0) {
          return -1;
        }
        break;
      }
      found++;
    }
  }

  libusb_free_device_list(devs, 1);

  return devh ? 0 : -1;
}

static int open_bulk_device() {
  int r = 1;

  r = libusb_init(NULL);
  if (r < 0) {
    fprintf(stderr, "failed to initialise libusb\n");
    return -1;
  }

  r = find_xmos_bulk_device(0);
  if (r < 0) {
    fprintf(stderr, "Could not find/open device\n");
    return -1;
  }

  r = libusb_claim_interface(devh, 0);
  if (r < 0) {
    fprintf(stderr, "Error claiming interface %d %d\n", 0, r);
    return -1;
  }

  return 0;
}

static int close_bulk_device() {
  libusb_release_interface(devh, 0);
  libusb_close(devh);
  libusb_exit(NULL);
  return 0;
}

static int bulk_device_io(int ep, char *bytes, int size, int timeout) {
  int actual_length;
  int r;
  r = libusb_bulk_transfer(devh, ep & 0xff, (unsigned char*)bytes, size, &actual_length, timeout);

  if (r == 0) {
    return 0;
  } else {
    return 1;
  }
}

static int read_bulk_device(char *data, unsigned int length, unsigned int timeout) {
  int result = 0;
  result = bulk_device_io(XMOS_BULK_EP_IN, data, length, timeout);
  return result;
}

static int write_bulk_device(char *data, unsigned int length, unsigned int timeout) {
  int result = 0;
  result = bulk_device_io(XMOS_BULK_EP_OUT, data, length, timeout);
  return result;
}
#endif

#define BUFFERSIZE 128
int main(int argc, char **argv) {
  int i = 0;
  int j = 0;
  unsigned int data[BUFFERSIZE];
  unsigned expected = 10;
  unsigned buffers = 10;
  int failed = 0;

  if (open_bulk_device() < 0) {
    return 1;
  }
  if (argc > 1) {
    buffers = atoi(argv[1]);
  }

  printf("XMOS Bulk USB device opened .....\n");
  printf("XMOS Bulk USB device sending %d buffers .....\n", buffers);

  for (j = 0; j < buffers; j++) {
    for (i = 0; i < BUFFERSIZE; i++) {
      data[i] = expected + i;
    }
    write_bulk_device((char *)data, BUFFERSIZE*4, 1000);
    read_bulk_device((char *)data, BUFFERSIZE*4, 1000);
    // Device increments by one
    expected++;
    for (i = 0; i < BUFFERSIZE; i++) {
      if (data[i] != (expected + i)) {
        printf("*** At data[%d]: Expected %d, got %d\n", i, expected, data[i]);
        failed = 1;
        break;
      } 
    }
  }

  if (!failed) {
    printf("XMOS Bulk USB device data processed correctly .....\n");
  }

  if (close_bulk_device() < 0) {
    return 1;
  }

  printf("XMOS Bulk USB device closed .....\n");

  return 0;
}
