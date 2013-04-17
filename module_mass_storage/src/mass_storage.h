#ifndef __mass_storage__
#define __mass_storage__

#define MASS_STORAGE_BLOCKLENGTH 512

/** Function that communicates with the host over the two endpoints that
 * mass storage requires, implementing the mass storage protocol.
 *
 * \param chan_ep1_out  channel end for the OUT endpoint - from XUD
 * \param chan_ep1_in   channel end for the IN endpoint - from XUD
 * \param writeProtect  Set to 1 to set the file system to be write protected.
 */
void massStorageClass(chanend chan_ep1_out, chanend chan_ep1_in, int writeProtect);

/** Call back function to initialise the other three call backs below.
 * Called once on startup. This function should be provided by the caller
 * of this module.
 */
void massStorageInit();

/** Call back function to read a block of data. This function should be
 * provided by the caller of this module. It is called every time a block
 * of data is read. This function should read MASS_STORAGE_BLOCKLENGTH bytes.
 *
 * \param blockNr    the block number to read from flash (or other backing store)
 * \param buffer     array to write the read data into.
 *
 */
int massStorageRead(unsigned int blockNr, unsigned char buffer[]);

/** Call back function to write a block of data. This function should be
 * provided by the caller of this module. It is called every time a block
 * of data is to be written. This function should write
 * MASS_STORAGE_BLOCKLENGTH bytes.
 *
 * \param blockNr    the block number to write to flash (or other backing store)
 * \param buffer     array to read the read data from.
 *
 */
int massStorageWrite(unsigned int blockNr, unsigned char buffer[]);

/** Call back function that computes the size of the flash. This function
 * should be provided by the caller of this module. This function should
 * return the number of blocks that can be stored.
 */
int massStorageSize();

#endif // __mass_storage_ep0__
