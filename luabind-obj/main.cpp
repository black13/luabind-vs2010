#include <iostream>
#include<luabind/luabind.hpp>
extern "C"
  {
#include <lualib.h>
#include <lua.h>
#include <lauxlib.h>
  }

using namespace std;
using namespace luabind;
int DebuggerFunc(lua_State* L)
{

object error_msg(luabind::from_stack(L, -1));
cerr << error_msg << endl;
  return 0;
}

class teste
{
public:
 void Print()
 {
      cout<<"aaaa"<<endl;
 }

};


int main()
{

    try
    {
        teste *obj=new teste;

	   lua_State *myLuaState = lua_open();
	   luaL_openlibs(myLuaState);
        luabind::open(myLuaState);

         module(myLuaState)
            [
            class_<teste >("teste")
        .def(constructor<>())
        .def("Print", &teste::Print)
            ];

        std::string scriptPath = "C:\\Users\\josburn\\Documents\\programming\\luabind-vs2010\\luabind-obj\\script.lua";
        luaL_dofile(myLuaState,scriptPath.c_str());
        luabind::call_function<void>(myLuaState,"DoStuff", obj);

        lua_close(myLuaState);

    }
    catch (const luabind::error &er)
	{
		cerr << er.what() << endl;
		lua_State* Ler=er.state();
		DebuggerFunc(Ler);
	}
	catch (...)
	{
	    cerr<<"Uknow error!"<<endl;
	}

	return 0;
}