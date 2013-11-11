#include <iostream>
#include<luabind/luabind.hpp>
extern "C"
{
     #include <lualib.h>
     #include <lua.h>
     #include <lauxlib.h>
}

#include <luabind/luabind.hpp>
#include <luabind/adopt_policy.hpp>
#include <luabind/detail/debug.hpp>
#include <luabind/error.hpp>
#include <luabind/operator.hpp>
#include <luabind/object.hpp>
//#include <boost/lexical_cast.hpp>

#include <utility>

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

void report_failure(char const* err, char const* file, int line)
{
	std::cerr << file << ":" << line << "\"" << err << "\"\n";
}

bool dostring(lua_State* L, const char* str)
{
	if (luaL_loadbuffer(L, str, std::strlen(str), str) || lua_pcall(L, 0, 0, 0))
	{
		const char* a = lua_tostring(L, -1);
		std::cout << a << "\n";
		lua_pop(L, 1);
		return true;
	}
	return false;
}

int main()
{
	lua_State *L = lua_open();
	luaL_openlibs(L);
     luabind::open(L);

     int inner_sum = 0;
     DOSTRING(L, "t = { {1}, {2}, {3}, {4} }");

     for (luabind::iterator i(globals(L)["t"]), e; i != e; ++i)
     {
          inner_sum += object_cast<int>((*i)[1]);
     }

	lua_close(L);
}
/*
int main(int argc,char *argv[])
{
     
     return 0;
}
*/