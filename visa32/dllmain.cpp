// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include <stdio.h>

extern "C"
{
	#include <lualib.h>
	#include <lua.h>
	#include <lauxlib.h>
}

#include<luabind/luabind.hpp>

using namespace std;
using namespace luabind;


BOOL APIENTRY DllMain( HMODULE hModule,DWORD  ul_reason_for_call,LPVOID lpReserved)
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
		lua_State *L;
        S():L(NULL)
        {
			L = luaL_newstate();
			luaL_openlibs(L);
        };
        
        ~S()
        {
			lua_close(L);
        }
        S(S const&);
        void operator=(S const&);
};

S &s = S::getInstance();


#ifdef __cplusplus
extern "C" {
#endif

     _VI_FUNC ViString DllVersion ()
     {
          return ".01";
     }
 
     //can return VI_SUCCESS or not
     _VI_FUNC ViStatus viOpenDefaultRM (ViPSession vi)
     {
          //
		  *vi = NULL;
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
