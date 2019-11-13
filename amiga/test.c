#include <proto/exec.h>
#include <proto/dos.h>

struct DosLibrary *myDOSBase;

main()
{
    if(myDOSBase=(struct DosLibrary *)OpenLibrary("dos.library",0)){
        Write(Output(),"Hello, world!\n",14);
        CloseLibrary((struct Library *)myDOSBase);
    }
    return 0;
}