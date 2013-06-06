// lua-blob.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
/** Lua blob.cpp
 * Blob object for Lua
 * http://code.google.com/p/lua-blob/
 * 
 * Basically a byte array. Faster than using tables or string manipulation to
 * store lots of numbers.
 * 
 * @author HyperHacker
 * @version 86336
 * 
 * Copyright (c) 2010, HyperHacker
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the software nor the names of its contributors may be
 *     used to endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL HYPERHACKER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * How to use:
 * require("blob"), and then use one of the Blob.Create* functions to create a
 * blob. This is basically a large block of memory for you to play with.
 * Mostly you will want to simply index the Blob you create like:
 * MyBlob[1] = 4
 * By doing this you access individual bytes of the memory block. Indexes start
 * at 1 like everything else in Lua. Attempting to assign values outside the
 * range 0-255 is undefined, but on most systems the value is simply truncated.
 * 
 * For more advanced usage, you can access the memory as other data types:
 * Byte (one byte), Short (2 bytes), Int (4 bytes), Long (8 bytes), Float or
 * Double; e.g. MyBlob.Short[6] = 1024. Be careful with this; it's easy to
 * break something. Points to keep in mind:
 * -The size of float and double are not always the same on all platforms. The
 *  fields Blob._floatsize and Blob._doublesize provide the size on the current
 *  platform.
 * -All tables use byte indexes. In other words, MyBlob.Short[4] access the same
 *  2 bytes as MyBlob.Byte[4] and MyBlob.Byte[5]. Accessing byte indices which
 *  are not multiples of the size is undefined (e.g. MyBlob.Int[5]). On some
 *  platforms the index will be rounded; others will trigger an unaligned access
 *  exception which probably means your program gets killed.
 *  Generally, you should avoid using different data types within one Blob
 *  unless you're completely sure of what you're doing, don't intend for your
 *  code to ever run on any other platform, and really need to for some reason.
 * -Similarly, sizes are given as a number of bytes. If you intend to store
 *  n floats, pass n*Blob._floatsize for the size parameter, etc.
 * -Note that you could get a potentially confusing error message like "Index
 *  out of range (8/10)" when using larger data types; in this example, if the
 *  data type is larger than 2 bytes - it begins at 8, but extends past 10, thus
 *  exceeding the size of the block.
 * There are also SByte, SShort, SInt and SLong, which treat the values as
 * signed integers.
 * 
 * Blobs can be converted to strings (note that strings can contain embedded
 * zeros) and dumped to files. Note that creating a blob from a file reads the
 * entire file into memory.
 * 
 * There is no resize function, since a resize operation would require creating
 * a new blob and copying the contents - you may as well do that manually.
 * 
 * For general file I/O, you should use the io library. For general string
 * manipulation, you should use the string library. For general numeric arrays,
 * you should use tables. This library is intended to take the place of very
 * large tables containing nothing but numbers, especially being read/written to
 * binary files, where normal tables and strings don't offer sufficient
 * performance. Examples are raw image data and decoding arbitrary binary data
 * from a file. If you don't think you need this, you probably don't.
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
//#include <lua5.1/lua.h>
//#include <lua5.1/lauxlib.h>
//#include <lua5.1/lualib.h>


#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "config.h"

/* Convenient macros. */
/* see http://tinyurl.com/42mood if you don't understand while(0). */
#define EXPORT_FUNC(f) {#f, Lua_Blob_##f}
#define LUA_FUNC_NAME(f) Lua_Blob_##f
#define LUA_FUNC(f) static int Lua_Blob_##f(lua_State *Lua)
#define GET_SELF() Blob *self = (Blob*)lua_touserdata(Lua, 1);
#define GET_PARENT() lua_pushstring(Lua, "parent");\
	lua_rawget(Lua, 1);\
	Blob *parent = (Blob*)lua_touserdata(Lua, -1);\
	lua_pop(Lua, 1);

#define LUA_PUSH_TABLE_VALUE(luastate, keytype, key, valtype, val) do {\
	lua_push##keytype((luastate), (key));\
	lua_push##valtype((luastate), (val));\
	lua_settable((luastate), -3);\
} while(0)

#define LUA_PUSH_NAMED_OBJECT_FUNC(luastate, funcname, obj, name) do {\
	lua_pushstring((luastate), (#funcname));\
	lua_pushcfunction((luastate), (Lua_##obj##_##name));\
	lua_settable((luastate), -3);\
} while(0)

#define LUA_RETURN_ERRMSG(luastate, message) do {\
	/* DebugOut(DO_ALL, "%s:%d: LUA_PUSH_ERRMSG: %s\n", __FILE__, __LINE__, (message));\ */\
	lua_pushnil((luastate));\
	lua_pushstring((luastate), (message));\
	return 2;\
} while(0)

#define LUA_RETURN_NIL(luastate) do {\
	lua_pushnil(luastate);\
	return 1;\
} while(0)

#define DEFINE_METAMETHODS(type) LUA_FUNC(type##_index){\
	return subtable_index(Lua, type); }\
	LUA_FUNC(type##_newindex){\
	return subtable_newindex(Lua, type);}\


/** Blob object that holds the raw Byte.
 */
typedef struct {
	size_t Size;
	uint8_t Byte[];
} Blob;

/** Data type sizes and identifiers.
 */
typedef enum {
	Byte, SByte, Short, SShort, Int, SInt, Long, SLong, Float, Double
} DataType;

const size_t DataSize[] = {
	sizeof(uint8_t), sizeof(int8_t), sizeof(uint16_t), sizeof(int16_t),
	sizeof(uint32_t), sizeof(int32_t), sizeof(uint64_t), sizeof(int64_t),
	sizeof(float), sizeof(double)
};

/** Function prototypes.
 */
static Blob* Create_Blob(lua_State *Lua, size_t Size);
LUA_FUNC(Create);
LUA_FUNC(CreateFilled);
LUA_FUNC(CreateFromFile);
LUA_FUNC(CreateFromString);
LUA_FUNC(DumpToFile);
LUA_FUNC(Meta_index);
LUA_FUNC(Meta_newindex);
LUA_FUNC(Meta_tostring);
LUA_FUNC(Meta_len);
LUA_FUNC(Byte_index);	LUA_FUNC(Byte_newindex);
LUA_FUNC(SByte_index);	LUA_FUNC(SByte_newindex);
LUA_FUNC(Short_index);	LUA_FUNC(Short_newindex);
LUA_FUNC(SShort_index);	LUA_FUNC(SShort_newindex);
LUA_FUNC(Int_index);	LUA_FUNC(Int_newindex);
LUA_FUNC(SInt_index);	LUA_FUNC(SInt_newindex);
LUA_FUNC(Long_index);	LUA_FUNC(Long_newindex);
LUA_FUNC(SLong_index);	LUA_FUNC(SLong_newindex);
LUA_FUNC(Float_index);	LUA_FUNC(Float_newindex);
LUA_FUNC(Double_index);	LUA_FUNC(Double_newindex);

/** Blob object functions, to be looked up by __index. */
static const char *MetaFuncName[] = {
	"DumpToFile",
	NULL
};

static lua_CFunction MetaFuncPtr[] = {
	LUA_FUNC_NAME(DumpToFile),
	NULL
};

/** Creates a Blob and the associated Lua objects.
 * @param Lua Lua state to create in.
 * @param Size Size of the blob.
 * @return Blob object.
 */
static Blob* Create_Blob(lua_State *Lua, size_t Size)
{
	//Create the Lua object
	Blob *self = (Blob*)lua_newuserdata(Lua, Size + sizeof(Blob));
	self->Size = Size;
	
	//Create metatable
	lua_createtable(Lua, 0, 4);
	LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __index, Blob, Meta_index);
	LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __newindex, Blob, Meta_newindex);
	LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __tostring, Blob, Meta_tostring);
	LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __len, Blob, Meta_len);
	lua_setmetatable(Lua, -2);
	
	return self;
}

/** Creates a Blob.
 * @param Size Capacity in bytes.
 * @return Blob, or nil and error message.
 */
LUA_FUNC(Create)
{
	size_t Size = luaL_checkint(Lua, 1);
	Create_Blob(Lua, Size);
	return 1;
}

/** Creates a Blob filled with a certain value.
 * @param Size Capacity in bytes.
 * @param Val Value to fill with.
 * @return Blob, or nil and error message.
 */
LUA_FUNC(CreateFilled)
{
	unsigned char Byte = luaL_checkint(Lua, 2);
	size_t Size = luaL_checkint(Lua, 1);
	Blob *self = Create_Blob(Lua, Size);
	memset(self->Byte, Byte, self->Size);
	return 1;
}

/** Creates a Blob from a file.
 * @param Path Path to file.
 * @return Blob, or nil and error message.
 */
LUA_FUNC(CreateFromFile)
{
	const char *Path = lua_tostring(Lua, 1);
	if(!Path) LUA_RETURN_ERRMSG(Lua, "Invalid filename.");
	
	FILE *File = fopen(Path, "rb");
	if(!File) LUA_RETURN_ERRMSG(Lua, "Cannot open file.");
	
	fseek(File, 0, SEEK_END);
	size_t Size = ftell(File);
	fseek(File, 0, SEEK_SET);
	
	Blob *self = Create_Blob(Lua, Size);
	size_t Read = fread(self->Byte, 1, Size, File);
	//if(Read < Size) DebugOut(DO_MINOR,
	//	"Blob: Did not read all of file \"%s\" (%u of %u)\n", Path, Read, Size);
	fclose(File);
	
	return 1;
}

/** Creates a Blob from a string.
 * @param String String to copy.
 * @return Blob, or nil and error message.
 */
LUA_FUNC(CreateFromString)
{
	const char *Str = lua_tostring(Lua, 1);
	if(!Str) LUA_RETURN_ERRMSG(Lua, "Invalid string.");
	
	size_t Size = lua_objlen(Lua, 1);
	Blob *self = Create_Blob(Lua, Size);
	memcpy(self->Byte, Str, Size);
	
	return 1;
}

/** Dumps a Blob to a file.
 * @param self Blob to dump.
 * @param Path Path to file.
 * @return 1, or nil and error message.
 */
LUA_FUNC(DumpToFile)
{
	GET_SELF();
	if(!self) LUA_RETURN_ERRMSG(Lua, "Invalid Blob.");
	
	const char *Path = lua_tostring(Lua, 2);
	if(!Path) LUA_RETURN_ERRMSG(Lua, "Invalid filename.");
	
	FILE *File = fopen(Path, "wb");
	if(!File) LUA_RETURN_ERRMSG(Lua, "Cannot open file.");
	
	fwrite(self->Byte, 1, self->Size, File);
	fclose(File);
	
	lua_pushboolean(Lua, 1);
	return 1;
}

/** Blob's __index metamethod.
 * @param self Blob being indexed.
 * @param Idx Key being looked up.
 * @return Corresponding byte/value, or nil and error message.
 */
LUA_FUNC(Meta_index)
{
	GET_SELF();
	if(lua_isnumber(Lua, 2))
	{
		size_t Idx = lua_tointeger(Lua, 2) - 1;
		if(Idx < self->Size) lua_pushinteger(Lua, self->Byte[Idx]);
		else lua_pushnil(Lua);
	}
	else if(lua_isstring(Lua, 2))
	{
		int i;
		const char *Idx = lua_tostring(Lua, 2);
		if(!strcmp(Idx, "Ptr")) //mainly for gl.TexImage2D(..., MyBlob.Ptr)
		{
			lua_pushlightuserdata(Lua, (void*)self->Byte);
			return 1;
		}
		
		
		//Generate tables for .Byte, .Short, etc.
		const char *SubTableNames[] = {
			"Byte", "SByte", "Short", "SShort", "Int", "SInt", "Long", "SLong",
			"Float", "Double", NULL
		};
		
		lua_CFunction Lua_Blob_SubTableIndex[] = {
			LUA_FUNC_NAME(Byte_index), LUA_FUNC_NAME(SByte_index),
			LUA_FUNC_NAME(Short_index), LUA_FUNC_NAME(SShort_index),
			LUA_FUNC_NAME(Int_index), LUA_FUNC_NAME(SInt_index),
			LUA_FUNC_NAME(Long_index), LUA_FUNC_NAME(SLong_index),
			LUA_FUNC_NAME(Float_index), LUA_FUNC_NAME(Double_index)
		};
			
		lua_CFunction Lua_Blob_SubTableNewIndex[] = {
			LUA_FUNC_NAME(Byte_newindex), LUA_FUNC_NAME(SByte_newindex),
			LUA_FUNC_NAME(Short_newindex), LUA_FUNC_NAME(SShort_newindex),
			LUA_FUNC_NAME(Int_newindex), LUA_FUNC_NAME(SInt_newindex),
			LUA_FUNC_NAME(Long_newindex), LUA_FUNC_NAME(SLong_newindex),
			LUA_FUNC_NAME(Float_newindex), LUA_FUNC_NAME(Double_newindex)
		};
		
		for(i=0; SubTableNames[i]; i++)
		{
			if(!strcmp(Idx, SubTableNames[i]))
			{
				lua_createtable(Lua, 0, 1);
				LUA_PUSH_TABLE_VALUE(Lua, string, "parent", lightuserdata,self);
				lua_createtable(Lua, 0, 2); //metatable
				LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __index, Blob,SubTableIndex[i]);
				LUA_PUSH_NAMED_OBJECT_FUNC(Lua, __newindex, Blob,
					SubTableNewIndex[i]);
				lua_setmetatable(Lua, -2);
				return 1;
			}
		}
		
		
		//Look up metamethods
		for(i=0; MetaFuncName[i]; i++)
		{
			if(!strcmp(MetaFuncName[i], Idx))
			{
				lua_pushcfunction(Lua, MetaFuncPtr[i]);
				return 1;
			}
		}
		LUA_RETURN_NIL(Lua);
	}
	else lua_pushnil(Lua);
	return 1;
}

/** Blob's __newindex metamethod.
 * @param self Blob being indexed.
 * @param Idx Key being modified.
 * @param Val New value.
 */
LUA_FUNC(Meta_newindex)
{
	GET_SELF();
	if(!lua_isnumber(Lua, 2))
	{
		return luaL_error(Lua,
			"Cannot assign to non-numeric fields of Blob (got %s)",
			luaL_typename(Lua, 2));
	}
	if(!lua_isnumber(Lua, 3))
	{
		return luaL_error(Lua,
			"Cannot assign non-numeric values to Blob (got %s)",
			luaL_typename(Lua, 3));
	}
	
	size_t Idx = lua_tointeger(Lua, 2) - 1;
	if(Idx < self->Size) self->Byte[Idx] = lua_tointeger(Lua, 3);
	else return luaL_error(Lua, "Index out of range (%d/%d)",
		Idx+1, self->Size);
	return 0;
}

/** Blob's __tostring metamethod.
 * @param self Blob being converted.
 * @return String.
 */
LUA_FUNC(Meta_tostring)
{
	GET_SELF();
	lua_pushlstring(Lua, (const char*)self->Byte, self->Size);
	return 1;
}

/** Blob's __len metamethod.
 * @param self Blob being checked.
 * @return Size of blob.
 */
LUA_FUNC(Meta_len)
{
	GET_SELF();
	lua_pushinteger(Lua, self->Size);
	return 1;
}

/** Internal function to handle __index for .Byte, .Short, etc.
 * @param Lua The Lua state to operate on.
 * @param Type The value type requested.
 * @return The requested value, or nil.
 */
static int subtable_index(lua_State *Lua, DataType Type)
{
	GET_PARENT();
	if(!lua_isnumber(Lua, 2)) LUA_RETURN_NIL(Lua);
	
	size_t Size = DataSize[Type];
	size_t Idx = (lua_tointeger(Lua, 2) - 1);
	if((Idx + Size) > (parent->Size / Size)) LUA_RETURN_NIL(Lua);
	
	switch(Type)
	{
		case Byte:
			lua_pushinteger(Lua, parent->Byte[Idx]);
		break;
		
		case SByte:
			lua_pushinteger(Lua, (int8_t)parent->Byte[Idx]);
		break;
		
		case Short:
			lua_pushinteger(Lua, *((uint16_t*)&parent->Byte[Idx]));
		break;
		
		case SShort:
			lua_pushinteger(Lua, *((int16_t*)&parent->Byte[Idx]));
		break;
		
		case Int:
			lua_pushinteger(Lua, *((uint32_t*)&parent->Byte[Idx]));
		break;
		
		case SInt:
			lua_pushinteger(Lua, *((int32_t*)&parent->Byte[Idx]));
		break;
		
		case Long:
			lua_pushinteger(Lua, *((uint64_t*)&parent->Byte[Idx]));
		break;
		
		case SLong:
			lua_pushinteger(Lua, *((int64_t*)&parent->Byte[Idx]));
		break;
		
		case Float:
			lua_pushnumber(Lua, *((float*)&parent->Byte[Idx]));
		break;
		
		case Double:
			lua_pushnumber(Lua, *((double*)&parent->Byte[Idx]));
		break;
		
		default: break;
	}
	return 1;
}

/** Internal function to handle __newindex for .Byte, .Short, etc.
 * @param Lua The Lua state to operate on.
 * @param Size The value size requested.
 * @return The requested value, or nil.
 */
static int subtable_newindex(lua_State *Lua, DataType Type)
{
	GET_PARENT();
	if(!lua_isnumber(Lua, 2)) LUA_RETURN_NIL(Lua);
	
	size_t Size = DataSize[Type];
	size_t Idx = (lua_tointeger(Lua, 2) - 1);
	if((Idx + Size) > (parent->Size / Size)) return luaL_error(Lua,
		"Index out of range (%d/%d)", Idx+1, parent->Size);
	
	switch(Type)
	{
		case Byte: case SByte:
			parent->Byte[Idx] = lua_tointeger(Lua, 3);
		break;
		
		case Short: case SShort:
			*((uint16_t*)&parent->Byte[Idx]) = lua_tointeger(Lua, 3);
		break;
		
		case Int: case SInt:
			*((uint32_t*)&parent->Byte[Idx]) = lua_tointeger(Lua, 3);
		break;
		
		case Long: case SLong:
			*((uint64_t*)&parent->Byte[Idx]) = lua_tointeger(Lua, 3);
		break;
		
		case Float:
			*((float*)&parent->Byte[Idx]) = lua_tonumber(Lua, 3);
		break;
		
		case Double:
			*((double*)&parent->Byte[Idx]) = lua_tonumber(Lua, 3);
		break;
		
		default: break;
	}
	return 0;
}

DEFINE_METAMETHODS(Byte); DEFINE_METAMETHODS(SByte);
DEFINE_METAMETHODS(Short); DEFINE_METAMETHODS(SShort);
DEFINE_METAMETHODS(Int); DEFINE_METAMETHODS(SInt);
DEFINE_METAMETHODS(Long); DEFINE_METAMETHODS(SLong);
DEFINE_METAMETHODS(Float); DEFINE_METAMETHODS(Double);

/** Called by Lua to open the library.
 * @param Lua The Lua state.
 * @return The library function table.
 */

//LUALIB_API int LUAOPENFUNC (lua_State *Lua) {
LUALIB_API int luaopen_blob  (lua_State *Lua) {
	/** Lua function table. All functions exported to Lua go here.
	 */
	const luaL_Reg libfuncs[] = {
		EXPORT_FUNC(Create),
		EXPORT_FUNC(CreateFilled),
		EXPORT_FUNC(CreateFromFile),
		EXPORT_FUNC(CreateFromString),
		{NULL, NULL}
	};
	luaL_register(Lua, LUANAME, libfuncs);
	
	lua_createtable(Lua, 0, 1); //_info = {
	
		LUA_PUSH_TABLE_VALUE(Lua, string, "version", integer, BUILD_ID);
		
		//Lua version library was written for; not guaranteed to work on others
		LUA_PUSH_TABLE_VALUE(Lua, string, "luaver", number, 5.1);
		
		lua_pushstring(Lua, "build_date"); //build_date = 
		lua_createtable(Lua, 0, 3); //{
			LUA_PUSH_TABLE_VALUE(Lua, string, "year", integer, BUILD_YEAR+2000);
			LUA_PUSH_TABLE_VALUE(Lua, string, "month", integer, BUILD_MONTH);
			LUA_PUSH_TABLE_VALUE(Lua, string, "day", integer, BUILD_DAY);
		lua_settable(Lua, -3); // }, --build_date
		
		LUA_PUSH_TABLE_VALUE(Lua, string, "author", string, "HyperHacker");
		LUA_PUSH_TABLE_VALUE(Lua, string, "license", string, "New BSD License");
		LUA_PUSH_TABLE_VALUE(Lua, string, "purpose", string,
			"Library for fast, efficient manipulation of numeric arrays.");
		//LUA_PUSH_TABLE_VALUE(Lua, string, "credits", string,
		//	"Extra credits go here.");
		LUA_PUSH_TABLE_VALUE(Lua, string, "'sup", string, "#xkcd");
	
	lua_setfield(Lua, -2, "_info"); // } --_info
	
	LUA_PUSH_TABLE_VALUE(Lua, string, "_floatsize", integer, sizeof(float));
	LUA_PUSH_TABLE_VALUE(Lua, string, "_doublesize", integer, sizeof(double));
	
	return 1;
}

#ifdef __cplusplus
} //extern "C"
#endif

