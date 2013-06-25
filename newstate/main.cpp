#include <iostream>
extern "C"
{
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

int main(int argc,char *argv[]) 
{
//Create a Lua state variable	   
	lua_State *L;
	int err;
	L = luaL_newstate();
	char * scriptfile=argv[1];
	//Load Lua libraries	
	luaL_openlibs(L);
	//Load but don't run the Lua script file	
	if ((err=luaL_loadfile(L, "script.lua"))==0)
	{	
		// Push the function name onto the stack
		if ((err = lua_pcall (L, 0, LUA_MULTRET, 0)) == 0)
		{ 
			lua_pushstring (L, "hello");
			// Function is located in the Global Table
			lua_gettable (L, LUA_GLOBALSINDEX);  
			lua_pcall (L, 0, 0, 0);
		}
		else
		{
			std::cerr << "couldn't load main" << std::endl;
		}

	}
	else
	{
		std::cerr << "couldn't load file" << std::endl;
	}
	lua_close(L);
}