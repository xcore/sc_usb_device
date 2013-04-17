#include <xclib.h>
#include "mass_storage.h"
#include "xud.h"
#include "usb.h"
#include "print.h"


int MassStorageEndpoint0Requests(XUD_ep c_ep0_out, XUD_ep c_ep0_in, SetupPacket sp) {
    unsigned char buffer[1] = {0};
    switch(sp.bRequest ) { 
    case 0xFE:
        return XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer,  1, sp.wLength);
    }

    return 0;
}


static unsigned char inquiryAnswer[36] = {
    0x00, 0x80, 0x02, 0x02, 0x1F, 0x00, 0x00, 0x00,
    'X', 'M', 'O', 'S',  0,  ' ', ' ', ' ',
    'F', 'l', 'a', 's', 'h', ' ', 'D', 'i',
    's', 'k', 0,   ' ', ' ', ' ', ' ', ' ',
    '0', '.', '1', '0'
};

static unsigned char modeSenseAnswer[4] = {
    0x04, 0x00, 0x10, 0x00
};

static unsigned char requestSenseAnswer[18] = {
    0x70, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x0A,
    0x00, 0x00, 0x00, 0x00, 0x3A, 0x00, 0x00, 0x00,
    0x00, 0x00
};

static unsigned char blockBuffer[MASS_STORAGE_BLOCKLENGTH];

/*
 * This function responds to mass storage requests.
 */
void massStorageClass(chanend chan_ep1_out, chanend chan_ep1_in, int writeProtect) 
{
    unsigned char commandBlock[64];
    unsigned char commandStatus[16];
    int lengths[3];
    int readLength, readAddress;

    int bCBWCBDataTransferLength, bCBWCBDirection, bCBWCBLUN, bCBWCBLength;
    int opcode, allocationLength;

    XUD_ep c_ep1_out = XUD_Init_Ep(chan_ep1_out);
    XUD_ep c_ep1_in = XUD_Init_Ep(chan_ep1_in);
    
    int ready = 1;


    massStorageInit();
    while(1) 
    {
        int failure = 0;
        XUD_GetBuffer(c_ep1_out, commandBlock);
        // verify commandBlock
        bCBWCBDataTransferLength = commandBlock[8] | commandBlock[9]<<8 | commandBlock[10] << 16 | commandBlock[11] << 24;
        bCBWCBDirection = commandBlock[12] >> 7; // 1 = in
        bCBWCBLUN = commandBlock[13];      // ???
        bCBWCBLength = commandBlock[14];
        opcode = commandBlock[15];
        allocationLength = commandBlock[18] << 8 | commandBlock[19];

        switch(opcode) {
        case 0: // Test unit ready:
            failure = ready ? 0 : 1;
            break;
        case 0x03: // Request sense
            requestSenseAnswer[2] = ready ? 0x00 : 0x02;
            XUD_SetBuffer(c_ep1_in, requestSenseAnswer, allocationLength);
            break;
        case 0x12: // Inquiry
            XUD_SetBuffer(c_ep1_in, inquiryAnswer, 36);
            break;
        case 0x1a: // Mode sense (6)
            if (writeProtect) {
                modeSenseAnswer[2] |= 0x80;
            }
            XUD_SetBuffer(c_ep1_in, modeSenseAnswer, 4);
            break;
        case 0x1b: // start/stop
            ready = ((commandBlock[19] >> 1) & 1) == 0;
            break;
        case 0x1e: // Medium removal
            break;            
        case 0x23: // Read Format capacity
            lengths[0] = byterev(8);
            lengths[1] = byterev(massStorageSize());
            lengths[2] = byterev(MASS_STORAGE_BLOCKLENGTH) | 2;
            XUD_SetBuffer(c_ep1_in, (lengths, unsigned char[8]), 12);
            break;
        case 0x25: // Read capacity
            lengths[0] = byterev(massStorageSize()-1);
            lengths[1] = byterev(MASS_STORAGE_BLOCKLENGTH);
            XUD_SetBuffer(c_ep1_in, (lengths, unsigned char[8]), 8);
            break;
        case 0x28: // Read (10)
            readLength = commandBlock[22] << 8 | commandBlock[23];
            readAddress = commandBlock[17] << 24 | commandBlock[18] << 16 | commandBlock[19] << 8 | commandBlock[20];
            for(int i = 0; i < readLength ; i++) {
                failure |= massStorageRead(readAddress, blockBuffer);
                XUD_SetBuffer(c_ep1_in, blockBuffer, MASS_STORAGE_BLOCKLENGTH);
                readAddress++;
            }
            break;
        case 0x2A: // Write
            readLength = commandBlock[22] << 8 | commandBlock[23];
            readAddress = commandBlock[17] << 24 | commandBlock[18] << 16 | commandBlock[19] << 8 | commandBlock[20];
            for(int i = 0; i < readLength ; i++) {
                XUD_GetBuffer(c_ep1_out, blockBuffer);
                failure |= massStorageWrite(readAddress, blockBuffer);
                readAddress++;
            }
            break;
        default:
            printhexln(opcode);
            failure = 1;
            break;
        }

        commandStatus[0] = 0x55;
        commandStatus[1] = 0x53;
        commandStatus[2] = 0x42;
        commandStatus[3] = 0x53;

        commandStatus[4] = commandBlock[4];
        commandStatus[5] = commandBlock[5];
        commandStatus[6] = commandBlock[6];
        commandStatus[7] = commandBlock[7];

        commandStatus[8] = 0;
        commandStatus[9] = 0;
        commandStatus[10] = 0;
        commandStatus[11] = 0;

        commandStatus[12] = failure;

        XUD_SetBuffer(c_ep1_in, commandStatus, 13);
    }
}
