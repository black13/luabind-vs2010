#include <iostream>

extern "C"
{
#include <lualib.h>
#include <lua.h>
#include <lauxlib.h>
}

#include<luabind/luabind.hpp>

using namespace std;
using namespace luabind;


int main()
{

    try
    {
        
		lua_State *L = luaL_newstate();
 
		// Connect LuaBind to this lua state
		luabind::open(L);

	   luaL_openlibs(L);
       luabind::open(L);

        lua_close(myLuaState);

    }
    catch (const luabind::error &er)
	{
		
	}
	catch (...)
	{
	    
	}

	return 0;
}