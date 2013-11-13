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
// We don't want to write std:: every time we're displaying some debug output
using namespace std;

// --------------------------------------------------------------------------------------------- //

struct ResourceManager {
	ResourceManager() :
		m_ResourceCount(0) {}
	 
	void loadResource(const string &sFilename) {
		++m_ResourceCount;
	}
	
	size_t getResourceCount() const {
		return m_ResourceCount;
	}
	 
	size_t m_ResourceCount;
};

class NumberPrinter {
public:
	NumberPrinter(int number) :
		m_number(number) {}
	 
	void print() {
		cout << m_number << endl;
	}
	 
private:
	int m_number;
};

void print_hello(int number) {
cout << "Printing [" << number << "]" << endl;
}
 
int main() {
	// Create a new lua state
	lua_State *myLuaState = lua_open();
	 
	// Connect LuaBind to this lua state
	luabind::open(myLuaState);
	 
	// Add our function to the state's global scope
	luabind::module(myLuaState) [
		luabind::def("print_hello", print_hello)
	];

	// Export our classes with LuaBind
	luabind::module(myLuaState) [
		luabind::class_<NumberPrinter>("NumberPrinter")
		.def(luabind::constructor<int>())
		.def("print", &NumberPrinter::print)
	];

	luabind::module(myLuaState) [
		luabind::class_<ResourceManager>("ResourceManager")
		.def("loadResource", &ResourceManager::loadResource)
		.property("ResourceCount", &ResourceManager::getResourceCount)
	];

	 
	//Test 1) Just call a global C++ function
	luaL_dostring(myLuaState, "print_hello(1337)\n"); //Inline LUA Script
	luaL_dofile(myLuaState, "test.lua"); //Or from a file

	//Test 2) Create a C++ Class (NumberPrinter) and perform a member function.
	luaL_dostring(
		myLuaState,
		"Print2000 = NumberPrinter(2000)\n"
		"Print2000:print()\n"
	);

	//Test 3) ResourceManager
	try {
		ResourceManager MyResourceManager;
		 
		// Assign MyResourceManager to a global in lua
		luabind::globals(myLuaState)["MyResourceManager"] = &MyResourceManager;
		 
		// Execute a script to load some resources
		luaL_dostring(
			myLuaState,
			"MyResourceManager:loadResource(\"abc.res\")\n"
			"MyResourceManager:loadResource(\"xyz.res\")\n"
			"\n"
			"ResourceCount = MyResourceManager.ResourceCount\n"
		);
		 
		// Read a global from the lua script
		size_t ResourceCount = luabind::object_cast<size_t>(
			luabind::globals(myLuaState)["ResourceCount"]
		);
		cout << "# of Resources: " << ResourceCount << endl;
	}
		catch(const std::exception &theProblemIs) {
		cerr << theProblemIs.what() << endl;
	}



	//Call Lua Function from C++.
	// Define a lua function that we can call
	luaL_dostring(
		myLuaState,
		"function add(first, second)\n"
		"  return first + second\n"
		"end\n"
	);
	 
	cout << "Result: "
		<< luabind::call_function<int>(myLuaState, "add", 2, 3)
		<< endl;

	lua_close(myLuaState);
}