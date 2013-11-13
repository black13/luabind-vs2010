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
#include <luabind/tag_function.hpp>
#include <boost/bind.hpp>

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

int f(int x, int y)
{
    return x + y;
}

struct X
{
    int f(int x, int y)
    {
        return x + y;
    }
};


int main()
{
    lua_State *L = lua_open();
    luaL_openlibs(L);
    luabind::open(L);

    int inner_sum = 0;
     
        module(L) [
        def("f", tag_function<int(int)>(boost::bind(&f, 5, _1))),

        class_<X>("X")
            .def(constructor<>())
            .def("f", tag_function<int(X&, int)>(boost::bind(&X::f, _1, 10, _2)))
    ];

    DOSTRING(L,
        "assert(f(0) == 5)\n"
        "assert(f(1) == 6)\n"
        "assert(f(5) == 10)\n"
    );

    DOSTRING(L,
        "x = X()\n"
        "assert(x:f(0) == 10)\n"
        "assert(x:f(1) == 11)\n"
        "assert(x:f(5) == 15)\n"
    );

    lua_close(L);
}
