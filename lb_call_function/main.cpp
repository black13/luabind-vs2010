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

#define DOSTRING(state_, str)                   \
{                                               \
    try                                         \
    {                                           \
        dostring(state_, str);                  \
    }                                           \
    catch (luabind::error const& e)             \
    {                                           \
        TEST_ERROR(lua_tostring(e.state(), -1)); \
            lua_pop(L, 1);                      \
    }                                           \
    catch (std::string const& s)                \
    {                                           \
        TEST_ERROR(s.c_str());                  \
    }                                           \
}

#define TEST_REPORT_AUX(x, line, file) \
	report_failure(x, line, file)

#define TEST_CHECK(x) \
    if (!(x)) \
        TEST_REPORT_AUX("TEST_CHECK failed: \"" #x "\"", __FILE__, __LINE__)

#define TEST_ERROR(x) \
	TEST_REPORT_AUX((std::string("ERROR: \"") + x + "\"").c_str(), __FILE__, __LINE__)

#define TEST_CHECK(x) \
    if (!(x)) \
        TEST_REPORT_AUX("TEST_CHECK failed: \"" #x "\"", __FILE__, __LINE__)

#define TEST_ERROR(x) \
	TEST_REPORT_AUX((std::string("ERROR: \"") + x + "\"").c_str(), __FILE__, __LINE__)

#define TEST_NOTHROW(x) \
	try \
	{ \
		x; \
	} \
	catch (...) \
	{ \
		TEST_ERROR("Exception thrown: " #x); \
	}
int main(int argc, char * argv[])
{
     lua_State * l = luaL_newstate();
     luaL_openlibs(l);
     
     luabind::open(l);

     luaL_dofile(l,".\\visa_sim.lua");
	 double *p = new double[10];
     try 
     {    
          std::string result;
          //call_function<void>(l, "hello");
          //int ret = call_function<int>(l,"add",1,1);
          //cout << ret << endl;
          //result = call_function<const char*>(l,"concat","1","2");
		  /*result = call_function<const char*>(l,"randstring",10);

		  for (int i = 0 ; i < 10; i++ )
		  {
			  result[i] 
		  }*/
     } 
     catch (const error &e) 
     {
          static_cast<void>(e);
          cout << "call_function: " << lua_tostring(l, -1) << endl;
     }
	 delete p;
     lua_close(l);
     return 0;
}