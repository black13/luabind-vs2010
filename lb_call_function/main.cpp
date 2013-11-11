#include <iostream>
#include <string>
#include<luabind/luabind.hpp>
extern "C"
  {
#include <lualib.h>
#include <lua.h>
#include <lauxlib.h>
  }

using namespace std;
using namespace luabind;

int main(int argc, char * argv[])
{
     lua_State * l = luaL_newstate();
     luaL_openlibs(l);
     
     luabind::open(l);

     luaL_dofile(l,".\\visa_sim.lua");
     try 
     {    
          std::string result;
          //call_function<void>(l, "hello");
          //int ret = call_function<int>(l,"add",1,1);
          //cout << ret << endl;
          result = call_function<const char*>(l,"concat","1","2");
     } 
     catch (const error &e) 
     {
          static_cast<void>(e);
          cout << "call_function: " << lua_tostring(l, -1) << endl;
     }

     lua_close(l);
     return 0;
}