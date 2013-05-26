#include <iostream>
#include <vector>
#include <luabind.hpp>
#include <lua.hpp>
#include <lualib.h>

//#include "Location.h"
//#include "ItemWrapper.h"
//#include "Utils.h"

int main()
{
    lua_State* luaState = lua_open();
    luaL_openlibs(luaState);
    luabind::open(luaState);
    std::string itemsList;
    std::string scriptPath = "content/scripts/items.lua";
    int loadState = luaL_dofile( luaState, scriptPath.c_str() );
    if ( loadState != 0 )
    {
        std::cerr << "ERROR - Trying to load script \"" + scriptPath + "\" failed. \nReturn code is " << loadState << std::endl;
    }

    try 
    {
        itemsList = luabind::call_function<std::string>( luaState, "item_GetItemsOnMap", "Bathroom" );
    } 
    catch( luabind::error e ) 
    {
        std::cerr << "ERROR: " << lua_tostring( luaState, -1 ) << " @ OutputItemsOnMap" << std::endl;
    }
    
    lua_close(luaState);
    return 0;
};
