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
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

#include <utility>
// We don't want to write std:: every time we're displaying some debug output
using namespace std;

using namespace luabind;
/*
int test_object_param(const object& table)
{
	LUABIND_CHECK_STACK(table.interpreter());

	object current_object;
	current_object = table;
	lua_State* L = table.interpreter();

	if (type(table) == LUA_TTABLE)
	{
		int sum1 = 0;
		for (luabind::iterator i(table), e; i != e; ++i)
		{
			assert(type(*i) == LUA_TNUMBER);
			sum1 += object_cast<int>(*i);
		}

		int sum2 = 0;
		for (raw_iterator i(table), e; i != e; ++i)
		{
			assert(type(*i) == LUA_TNUMBER);
			sum2 += object_cast<int>(*i);
		}

		// test iteration of empty table
		object empty_table = newtable(L);
		for (luabind::iterator i(empty_table), e; i != e; ++i)
		{}
		
		table["sum1"] = sum1;
		table["sum2"] = sum2;
		table["blurp"] = 5;
		table["sum3"] = table["sum1"];
		return 0;
	}
	else
	{
		if (type(table) != LUA_TNIL)
		{
			return 1;
		}
		else
		{
			return 2;
		}
	}
}
*/

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

struct CppClass
{
    int f()
    {
        return 1;
    }
};

template<class T>
struct counted_type
{
    static int count;
    
    counted_type()
    {
        ++count;
    }

    counted_type(counted_type const&)
    {
        ++count;
    }

    ~counted_type()
    {
        TEST_CHECK(--count >= 0);
    }
};

template<class T>
int counted_type<T>::count = 0;

struct test_param : counted_type<test_param>
{
	luabind::object obj;
	luabind::object obj2;

	bool operator==(test_param const& rhs) const
	{ return obj == rhs.obj && obj2 == rhs.obj2; }

	int f(int x)
    {
        return x;
    }
};

using namespace luabind;

int main() {
	// Create a new lua state
	lua_State *L = lua_open();
	luaL_openlibs(L); 
	// Connect LuaBind to this lua state
	luabind::open(L);
	 
	module(L)
	[
        class_<CppClass>("CppClass")
          .def(constructor<>())
          .def("f", &CppClass::f)
    ];


    DOSTRING(L,
        "x = CppClass()\n"
        "y = CppClass()\n"
    );

	{
    
	object a = globals(L)["x"];
	TEST_CHECK(call_member<int>(a, "f"));

	a = globals(L)["y"];
	TEST_CHECK(call_member<int>(a, "f"));

	LUABIND_CHECK_STACK(L);

	}

	lua_close(L);
}