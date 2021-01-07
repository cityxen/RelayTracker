/* CityXen Amiga Serial Relay Tracker Program
 * By Deadline
 * Writes 16 bit binary strings over serial port for use
 * with the raspberry pi serial bridge
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 * Run from CLI only                                         */

#define VERSION "2.0a"

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
    printf("%s",outstr);
    SerialIO->IOSer.io_Length   = -1;
    SerialIO->IOSer.io_Data     = (APTR)outstr;
    SerialIO->IOSer.io_Command  = CMD_WRITE;
    DoIO((struct IORequest *)SerialIO);
}

void writevalue(int value) {
    char strval[20];
    memset(strval,0,20);
    if(value & 1)  {   strval[0]='1'; }
    else {             strval[0]='0'; }
    if(value & 2)  {   strval[1]='1'; }
    else {             strval[1]='0'; }
    if(value & 4)  {   strval[2]='1'; }
    else {             strval[2]='0'; }
    if(value & 8)  {   strval[3]='1'; }
    else {             strval[3]='0'; }
    if(value & 16) {   strval[4]='1'; }
    else {             strval[4]='0'; }
    if(value & 32) {   strval[5]='1'; }
    else {             strval[5]='0'; }
    if(value & 64) {   strval[6]='1'; }
    else {             strval[6]='0'; }
    if(value & 128){   strval[7]='1'; }
    else {             strval[7]='0'; }
    if(value & 256){   strval[8]='1'; }
    else {             strval[8]='0'; }
    if(value & 512){   strval[9]='1'; }
    else {             strval[9]='0'; }
    if(value & 1024){  strval[10]='1'; }
    else {             strval[10]='0'; }
    if(value & 2048){  strval[11]='1'; }
    else {             strval[11]='0'; }
    if(value & 4096){  strval[12]='1'; }
    else {             strval[12]='0'; }
    if(value & 8192){  strval[13]='1'; }
    else {             strval[13]='0'; }
    if(value & 16384){ strval[14]='1'; }
    else {             strval[14]='0'; }
    if(value & 32768){ strval[15]='1'; }
    else {             strval[15]='0'; }
    printf("VAL [%d]\n[%s]\n",value,strval);
    strval[16]='\n';    
    writeser(strval);
}

void PutValue(int value) {
    printf("Writing value to relays: %d\n",value);
    writevalue(value);
}

void DoTracker(void) {
    printf("DoTracker\n");
}

int main(int nargs, char** pargs) { /* main(void) */
    int i;
    int speed;
    int iterations;
    int command;
    char str[1024];
    char filename[1024];
    FILE *fp;
    char bQuit;

    memset(filename,0,1024);
    bQuit=0;
    fp=0;
    speed=0;
    iterations=0;
    command=0;

    Execute("clear",0,0);
    printf("CityXen Relay Tracker %s  for the Amiga\n",VERSION);
    printf("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n");
    
    if(nargs<2) {
        printf("USAGE: rt <COMMAND> <SPEED> [ITERATIONS] [FILE]\n");
        Printf("Must supply SPEED\n");
        exit(0);
    }

    if (SerialMP=CreateMsgPort()) { /* Create the message port */
        if (SerialIO = (struct IOExtSer *) CreateExtIO(SerialMP,sizeof(struct IOExtSer))) { /* Create the IORequest */
            if (OpenDevice(SERIALNAME,0,(struct IORequest *)SerialIO,0L)) { /* Open the serial device */
                printf("Error: %s did not open\n",SERIALNAME); /* Inform user that it could not be opened */
            }
            else {    

                command=atoi(pargs[1]);

                if(command==1) {
                    PutValue(atoi(pargs[2]));
                    bQuit=1;
                }

                if(nargs>2) { speed=atoi(pargs[2]); }
                
                

                if(nargs>3) { iterations=atoi(pargs[3]); }
                if(iterations==0) { iterations=5; }
                
                

                if(nargs>4) {
                    strcpy(filename,pargs[4]);
                    fp=fopen(filename,"r");
                    if(!fp) {
                        printf("Can not open FILE:[%s] ABORTING!\n",filename);
                        bQuit=1;
                    }
                    else {
                        printf("USING FILE: %s\n",filename);
                    }
                }

                if(!bQuit) {

                    printf("SPEED: %d\n",speed);
                    printf("ITERATIONS: %d\n",iterations);
                    

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
                            writeser("1000000000000001\n"); Delay(speed);
                            writeser("0100000000000010\n"); Delay(speed);
                            writeser("0010000000000100\n"); Delay(speed);
                            writeser("0001000000001000\n"); Delay(speed);
                            writeser("0000100000010000\n"); Delay(speed);
                            writeser("0000010000100000\n"); Delay(speed);
                            writeser("0000001001000000\n"); Delay(speed);
                            writeser("0000000110000000\n"); Delay(speed);
                            writeser("0000000110000000\n"); Delay(speed);
                            writeser("0000001001000000\n"); Delay(speed);
                            writeser("0000010000100000\n"); Delay(speed);
                            writeser("0000100000010000\n"); Delay(speed);
                            writeser("0001000000001000\n"); Delay(speed);
                            writeser("0010000000000100\n"); Delay(speed);
                            writeser("0100000000000010\n"); Delay(speed);
                            writeser("1000000000000001\n"); Delay(speed);                        
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("0000000000000000\n"); Delay(speed);
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("1111111111111111\n"); Delay(speed);
                            writeser("0000000000000000\n"); Delay(speed);
                            writeser("1010101010101010\n"); Delay(speed);
                            writeser("0101010101010101\n"); Delay(speed);
                            writeser("1010101010101010\n"); Delay(speed);
                            writeser("0101010101010101\n"); Delay(speed);
                            writeser("1010101010101010\n"); Delay(speed);
                            writeser("0101010101010101\n"); Delay(speed);
                            writeser("1010101010101010\n"); Delay(speed);
                            writeser("0101010101010101\n"); Delay(speed);
                            writeser("1010101010101010\n"); Delay(speed);
                            writeser("0101010101010101\n"); Delay(speed);
                            writeser("0000000000000000\n"); Delay(speed);
                        }
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


