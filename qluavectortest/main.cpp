#include "stdafx.h"
#include <QtCore/QCoreApplication>
#include <QPointer>
#include <iostream>
#include "LuaContext.h"
#include <QtCore/QCoreApplication>

#include "vectorobject.h"
  

int main(int argc, char *argv[])
{
	try 
	{
		qlua::LuaContext ctx;

		VectorObject myobj3;
		ctx.AddQObject( &myobj3, "myobj3", false, qlua::LuaContext::QOBJ_NO_DELETE );
		/*
		ctx.Eval( "print( myobj3.copyString( 'hi' ) );"
		"vm = myobj3.copyVariantMap( {key1=1,key2='hello'} );" 
		"print( vm['key1'] .. ' ' .. vm['key2'] );"
		"print( myobj3.createObject().objectName );" );

		ctx.Eval( "fl = myobj3.copyShortList( {1,2,3} );\n" 
		"print( fl[1] .. ' ' .. fl[ 3 ] );\n" );
		*/
		ctx.EvalFile("C:\\Users\\jjosburn\\Documents\\programming\\luabind-vs2010\\scripts\\random_vector.lua");

    } 
	catch( const std::exception& e ) 
	{
        std::cerr << e.what() << std::endl;
    }
	/*
	try 
	{
	qlua::LuaContext ctx;
        
		VectorObject myobj;
    myobj.setObjectName( "MyObject" );
		ctx.AddQObject( &myobj, "myobj", false, qlua::LuaContext::QOBJ_NO_DELETE );
		ctx.EvalFile("C:\\Users\\jjosburn\\Documents\\programming\\luabind-vs2010\\scripts\\random_vector.lua");
	} 
	catch( const std::exception& e ) 
	{
        std::cerr << e.what() << std::endl;
    }
	*/
}
