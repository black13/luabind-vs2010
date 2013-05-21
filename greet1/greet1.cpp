#include <iostream>
#include <string>
using namespace std;

extern "C"
{
    #include <lua.h>
}

#include <luabind.hpp>

void Greet(string name) 
{ 
     cout << "Salutations, " << name << "!" << endl; 
}

using namespace std;
int main()
{
     
     lua_State* state = lua_open();
     luabind::open( state );
     
     luabind::module( state ) [ luabind::def ("Greet", &Greet) ];
     
     int statusLoad = luaL_loadfile( state, "Greet.lua" );
     
     if(statusLoad == LUA_ERRFILE)
          return -1;
     int statusCall = lua_pcall( state, 0, 0, 0 );
     
     cout << "Load: " << statusLoad << ", Call: " << statusCall << endl;
     lua_close( state );
     
     return 0;
}