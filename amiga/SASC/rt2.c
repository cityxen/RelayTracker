/*
 * CityXen Amiga Serial Relay Tracker Program
 * 
 * Writes 16 bit binary strings over serial port for use
 * with the raspberry pi serial bridge
 * 
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <devices/serial.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

void main(void)
{
struct MsgPort *SerialMP;       /* pointer to our message port */
struct IOExtSer *SerialIO;      /* pointer to our IORequest */

/* Create the message port */
if (SerialMP=CreateMsgPort())
    {
    /* Create the IORequest */
    if (SerialIO = (struct IOExtSer *)
                    CreateExtIO(SerialMP,sizeof(struct IOExtSer)))
        {
        /* Open the serial device */
        if (OpenDevice(SERIALNAME,0,(struct IORequest *)SerialIO,0L))

            /* Inform user that it could not be opened */
            printf("Error: %s did not open\n",SERIALNAME);
        else {

            while(1) {
                /* device opened, write NULL-terminated string */
                SerialIO->IOSer.io_Length   = -1;
                SerialIO->IOSer.io_Data     = (APTR)"1100110011001100\n";
                SerialIO->IOSer.io_Command  = CMD_WRITE;
                DoIO((struct IORequest *)SerialIO);     /* execute write */

                Delay(20);

                /* printf("Write failed.  Error - %ld\n",SerialIO->IOSer.io_Error); */

                SerialIO->IOSer.io_Length   = -1;
                SerialIO->IOSer.io_Data     = (APTR)"0011001100110011\n";
                SerialIO->IOSer.io_Command  = CMD_WRITE;
                DoIO((struct IORequest *)SerialIO);     /* execute write */

                Delay(20);

            }

            /* Close the serial device */
            CloseDevice((struct IORequest *)SerialIO);
        }
        /* Delete the IORequest */
        DeleteExtIO((struct IORequest *)SerialIO);
        }
    else
        /* Inform user that the IORequest could be created */
        printf("Error: Could create IORequest\n");

    /* Delete the message port */
    DeleteMsgPort(SerialMP);
    }
else
    /* Inform user that the message port could not be created */
    printf("Error: Could not create message port\n");
}

/*
   DoIO() vs. SendIO().
   --------------------
   The above example code contains some simplifications.  The DoIO()
   function in the example is not always appropriate for executing the
   CMD_READ or CMD_WRITE commands.  DoIO() will not return until the I/O
   request has finished.  With serial handshaking enabled, a write
   request may never finish.  Read requests will not finish until
   characters arrive at the serial port.  The following sections will
   demonstrate a solution using the SendIO() and AbortIO() functions.

*/