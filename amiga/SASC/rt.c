/* CityXen Amiga Serial Relay Tracker Program
 * By Deadline
 * Writes 16 bit binary strings over serial port for use
 * with the raspberry pi serial bridge
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 * Run from CLI only                                         */

#define VERSION "1.0a"

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <devices/serial.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }
#endif

struct MsgPort *SerialMP;       /* pointer to our message port */
struct IOExtSer *SerialIO;      /* pointer to our IORequest */

void writeser(char * outstr) {
    /* printf("%s",outstr); taken out because it causes delay */
    SerialIO->IOSer.io_Length   = -1;
    SerialIO->IOSer.io_Data     = (APTR)outstr;
    SerialIO->IOSer.io_Command  = CMD_WRITE;
    DoIO((struct IORequest *)SerialIO);
}

int main(int nargs, char** pargs) { /* main(void) */
    int i;
    int speed;
    int iterations;
    char str[1024];
    FILE *fp;
    speed=0;
    iterations=0;
    Execute("clear",0,0);
    printf("CityXen Relay Tracker %s for the Amiga\n",VERSION);
    printf("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
    if(nargs>1) { speed=atoi(pargs[1]); }
    if(nargs<1 | speed == 0) {
        printf("USAGE: rt <SPEED> [ITERATIONS] [FILE]\n");
        Printf("Must supply SPEED\n");
        exit(0);
    }
    printf("SPEED: %d\n",speed); 
    if(nargs>2) { iterations=atoi(pargs[2]); }
    if(iterations==0) { iterations=5; }
    printf("ITERATIONS: %d\n",iterations);
    if(nargs>3) {
        fp=fopen(pargs[3],"r");
        if(!fp) {
            printf("Can not open FILE:[%s] ABORTING!\n",pargs[3]);
            exit(0);
        }
    }
    printf("FILE: %s\n",pargs[2]);

    if (SerialMP=CreateMsgPort()) { /* Create the message port */
        if (SerialIO = (struct IOExtSer *) CreateExtIO(SerialMP,sizeof(struct IOExtSer))) { /* Create the IORequest */
            if (OpenDevice(SERIALNAME,0,(struct IORequest *)SerialIO,0L)) { /* Open the serial device */
                printf("Error: %s did not open\n",SERIALNAME); /* Inform user that it could not be opened */
            }
            else {

                if(fp) { /* Read in the file and send */
                    while(fgets (str, 1024, fp)!=NULL) {
                        writeser(str); Delay(speed);
                    }
                    fclose(fp);
                }

                else { /* Send some test signals */
                    for(i=0;i<iterations;i++) {
                        writeser("1000000000000000\n"); Delay(speed);
                        writeser("0100000000000000\n"); Delay(speed);
                        writeser("0010000000000000\n"); Delay(speed);
                        writeser("0001000000000000\n"); Delay(speed);
                        writeser("0000100000000000\n"); Delay(speed);
                        writeser("0000010000000000\n"); Delay(speed);
                        writeser("0000001000000000\n"); Delay(speed);
                        writeser("0000000100000000\n"); Delay(speed);
                        writeser("0000000010000000\n"); Delay(speed);
                        writeser("0000000001000000\n"); Delay(speed);
                        writeser("0000000000100000\n"); Delay(speed);
                        writeser("0000000000010000\n"); Delay(speed);
                        writeser("0000000000001000\n"); Delay(speed);
                        writeser("0000000000000100\n"); Delay(speed);
                        writeser("0000000000000010\n"); Delay(speed);
                        writeser("0000000000000001\n"); Delay(speed);
                    }
                }

                CloseDevice((struct IORequest *)SerialIO); /* Close the serial device */
            }
            DeleteExtIO((struct IORequest *)SerialIO); /* Delete the IORequest */
        }
        else {
            printf("Error: Could create IORequest\n"); /* Inform user that the IORequest could be created */
        }
        DeleteMsgPort(SerialMP); /* Delete the message port */
    }
    else {
        printf("Error: Could not create message port\n"); /* Inform user that the message port could not be created */
    }
}


