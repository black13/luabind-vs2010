// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include <stdio.h>


BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        printf("DllMain, DLL_PROCESS_ATTACH\n");
        break;
    case DLL_THREAD_ATTACH:
        printf("DllMain, DLL_THREAD_ATTACH\n");
        break;
    case DLL_THREAD_DETACH:
        printf("DllMain, DLL_THREAD_DETACH\n");
        break;
    case DLL_PROCESS_DETACH:
        printf("DllMain, DLL_PROCESS_DETACH\n");
        break;
    default:
        printf("DllMain, ????\n");
        break;
    }
    return TRUE;
}


class S
{
    public:
        static S& getInstance()
        {
            static S    instance; // Guaranteed to be destroyed.
                                  // Instantiated on first use.
            return instance;
        }
    private:
        S() 
        {
        };
        
          
        ~S()
        {
        }
        S(S const&);              // Don't Implement
        void operator=(S const&); // Don't implement
};

S &s = S::getInstance();

#include <Windows.h>
#ifdef _WIN32
#    ifdef LIBRARY_EXPORTS
#        define _VI_FUNC __declspec(dllexport)
#    else
#        define _VI_FUNC __declspec(dllimport)
#    endif
#else if
#    define LIBRARY_API
#endif


#ifdef __cplusplus
extern "C" {  // only need to export C interface if
              // used by C++ source code
#endif
#define _VI_PTR             *
#define _VI_SIGNED          signed
typedef unsigned long       ViUInt32;
typedef _VI_SIGNED long     ViInt32;

typedef ViUInt32    _VI_PTR ViPUInt32;
typedef ViUInt32    _VI_PTR ViAUInt32;
typedef ViInt32     _VI_PTR ViPInt32;
typedef ViInt32     _VI_PTR ViAInt32;

typedef unsigned short      ViUInt16;
typedef ViUInt16    _VI_PTR ViPUInt16;
typedef ViUInt16    _VI_PTR ViAUInt16;

typedef _VI_SIGNED short    ViInt16;
typedef ViInt16     _VI_PTR ViPInt16;
typedef ViInt16     _VI_PTR ViAInt16;


typedef ViUInt32            ViObject;
typedef ViObject    _VI_PTR ViPObject;
typedef ViObject    _VI_PTR ViAObject;

typedef ViObject            ViSession;
typedef ViSession   _VI_PTR ViPSession;
typedef ViSession   _VI_PTR ViASession;

#define ViPtr               _VI_PTR
typedef ViInt32             ViStatus;
typedef ViStatus    _VI_PTR ViPStatus;
typedef ViStatus    _VI_PTR ViAStatus;

typedef char                ViChar;
typedef ViChar      _VI_PTR ViPChar;
typedef ViChar      _VI_PTR ViAChar;

typedef ViPChar             ViString;
typedef ViPChar             ViPString;
typedef ViPChar     _VI_PTR ViAString;

typedef unsigned char       ViByte;
typedef ViByte      _VI_PTR ViPByte;
typedef ViByte      _VI_PTR ViAByte;

typedef ViPByte             ViBuf;
typedef ViPByte             ViPBuf;
typedef ViPByte     _VI_PTR ViABuf;

typedef ViString            ViRsrc;
typedef ViString            ViPRsrc;
typedef ViString    _VI_PTR ViARsrc;

typedef ViString             ViKeyId;
typedef ViPString            ViPKeyId;
typedef ViUInt32             ViJobId;
typedef ViJobId      _VI_PTR ViPJobId;
typedef ViUInt32             ViAccessMode;
typedef ViAccessMode _VI_PTR ViPAccessMode;
typedef ViUInt32             ViEventFilter;

typedef const ViChar * ViConstString;

ViStatus _VI_FUNC  viOpen          (ViSession sesn, ViRsrc name, ViAccessMode mode,ViUInt32 timeout, ViPSession vi);
ViStatus _VI_FUNC  viClear         (ViSession vi);
ViStatus _VI_FUNC  viRead          (ViSession vi, ViPBuf buf, ViUInt32 cnt, ViPUInt32 retCnt);
ViStatus _VI_FUNC  viWrite         (ViSession vi, ViBuf  buf, ViUInt32 cnt, ViPUInt32 retCnt);
ViStatus _VI_FUNC  viWriteAsync    (ViSession vi, ViBuf  buf, ViUInt32 cnt, ViPJobId  jobId);
ViStatus _VI_FUNC  viClear         (ViSession vi);
ViStatus _VI_FUNC  viClose         (ViObject vi);
ViStatus _VI_FUNC  viOpenDefaultRM (ViPSession vi);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C"
#endif
{   
     
     _VI_FUNC ViString DllVersion ()
     {
          return ".01";
     }
 
     //can return VI_SUCCESS or not
     _VI_FUNC ViStatus viOpenDefaultRM (ViPSession vi)
     {
          
          return NULL;   
     }

     ViStatus _VI_FUNC  viRead          (ViSession vi, ViPBuf buf, ViUInt32 cnt, ViPUInt32 retCnt)
     {
          return NULL;
     }

     ViStatus _VI_FUNC  viWrite         (ViSession vi, ViBuf  buf, ViUInt32 cnt, ViPUInt32 retCnt)
     {
          return NULL;
     }

     ViStatus _VI_FUNC  viWriteAsync    (ViSession vi, ViBuf  buf, ViUInt32 cnt, ViPJobId  jobId)
          {
          return NULL;
     }

     ViStatus _VI_FUNC  viClear         (ViSession vi)
          {
          return NULL;
     }

     ViStatus _VI_FUNC  viClose         (ViObject vi)
     {
          return NULL;
     }

     ViStatus _VI_FUNC  viOpen          (ViSession sesn, ViRsrc name, ViAccessMode mode,ViUInt32 timeout, ViPSession vi)
     {
          return NULL;
     }

#ifdef __cplusplus
}
#endif