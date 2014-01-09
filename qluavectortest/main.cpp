#include "stdafx.h"
#include <QtCore/QCoreApplication>
#include <QPointer>
#include <iostream>
#include "LuaContext.h"
#include <QtCore/QCoreApplication>

class TestObject : public QObject {
    Q_OBJECT
public slots:
    void method( const QString& msg ) {
        std::cout << msg.toStdString() << std::endl;
    }
    void emitSignal( const QString& msg ) { 
        std::cout << "emitting signal aSignal(" << msg.toStdString() << ")" << std::endl;
        emit aSignal( msg );
    }
    void aSlot( const QString& msg ) { 
        std::cout << "aSlot() called with data: " << msg.toStdString() << std::endl; 
    }
    QVector< float > copyFloatVector( const QVector< float >& v ) 
	{ 
		return v; 
	}
  
signals:
    void aSignal(const QString&);
};

int main(int argc, char *argv[])
{
	QCoreApplication a(argc, argv);

	qlua::LuaContext ctx;
        
    TestObject myobj;
    myobj.setObjectName( "MyObject" );

	return a.exec();
}
