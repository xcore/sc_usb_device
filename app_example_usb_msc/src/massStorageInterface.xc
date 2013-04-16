#include "mass_storage.h"

#define LIBFLASH

#ifdef SDCARD
#include "diskio.h"

void massStorageInit() {
    disk_initialize(0);
}

int massStorageRead(unsigned int blockNr, unsigned char buffer[]) {
    disk_read(0, buffer, blockNr, MASS_STORAGE_BLOCKLENGTH);
    return 0;
}

int massStorageWrite(unsigned int blockNr, unsigned char buffer[]) {
    disk_write(0, buffer, blockNr, MASS_STORAGE_BLOCKLENGTH);
    return 0;
}

int massStorageSize() {
    int length[1];
    disk_ioctl(0, GET_SECTOR_COUNT, (length, unsigned char[]));
    return length[0];
}

#endif


#ifdef LIBFLASH
#include "flashlib.h"
#include <xs1.h>

static fl_SPIPorts f = {
    XS1_PORT_1A,
    XS1_PORT_1B,
    XS1_PORT_1C,
    XS1_PORT_1D,
    XS1_CLKBLK_1
};

fl_DeviceSpec spiSpec[2] = {
  FL_DEVICE_ATMEL_AT25DF041A, FL_DEVICE_MICRON_M25P40
}; 

int pagesPerBlock;
int bytesPerPage;

void massStorageInit() {
    fl_connectToDevice(f, spiSpec, 2);
    bytesPerPage = fl_getPageSize();
    pagesPerBlock = MASS_STORAGE_BLOCKLENGTH/bytesPerPage;
}

unsigned char pageBuffer[512];

int massStorageRead(unsigned int blockNr, unsigned char buffer[]) {
    for(int i = 0; i < pagesPerBlock; i++) {
        fl_readDataPage(blockNr*pagesPerBlock + i, pageBuffer);
        for(int j = 0; j < bytesPerPage; j++) {
            buffer[i*bytesPerPage + j] = pageBuffer[j];
        }
    }
    return 0;
}

int massStorageWrite(unsigned int blockNr, unsigned char buffer[]) {
    for(int i = 0; i < pagesPerBlock; i++) {
        for(int j = 0; j < bytesPerPage; j++) {
            pageBuffer[j] = buffer[i*bytesPerPage + j];
        }
        fl_writeDataPage(blockNr*pagesPerBlock + i, buffer);
    }
    return 0;
}

int massStorageSize() {
    int x = fl_getNumDataPages();
    return x / pagesPerBlock;
}

#endif
