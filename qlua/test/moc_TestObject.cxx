/****************************************************************************
** Meta object code from reading C++ file 'TestObject.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.5)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "TestObject.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TestObject.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.5. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_TestObject[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      12,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      12,   11,   11,   11, 0x05,

 // slots: signature, parameters, type, tag, flags
      33,   29,   11,   11, 0x0a,
      49,   29,   11,   11, 0x0a,
      69,   29,   11,   11, 0x0a,
      94,   92,   84,   11, 0x0a,
     129,  126,  114,   11, 0x0a,
     173,  170,  157,   11, 0x0a,
     212,   11,  203,   11, 0x0a,
     242,  240,  227,   11, 0x0a,
     287,  285,  270,   11, 0x0a,
     332,  240,  319,   11, 0x0a,
     375,  285,  360,   11, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_TestObject[] = {
    "TestObject\0\0aSignal(QString)\0msg\0"
    "method(QString)\0emitSignal(QString)\0"
    "aSlot(QString)\0QString\0s\0copyString(QString)\0"
    "QVariantMap\0vm\0copyVariantMap(QVariantMap)\0"
    "QVariantList\0vl\0copyVariantList(QVariantList)\0"
    "QObject*\0createObject()\0QList<float>\0"
    "l\0copyFloatList(QList<float>)\0"
    "QVector<float>\0v\0copyFloatVector(QVector<float>)\0"
    "QList<short>\0copyShortList(QList<short>)\0"
    "QVector<short>\0copyShortVector(QVector<short>)\0"
};

void TestObject::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        TestObject *_t = static_cast<TestObject *>(_o);
        switch (_id) {
        case 0: _t->aSignal((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 1: _t->method((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->emitSignal((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 3: _t->aSlot((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 4: { QString _r = _t->copyString((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = _r; }  break;
        case 5: { QVariantMap _r = _t->copyVariantMap((*reinterpret_cast< const QVariantMap(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = _r; }  break;
        case 6: { QVariantList _r = _t->copyVariantList((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = _r; }  break;
        case 7: { QObject* _r = _t->createObject();
            if (_a[0]) *reinterpret_cast< QObject**>(_a[0]) = _r; }  break;
        case 8: { QList<float> _r = _t->copyFloatList((*reinterpret_cast< const QList<float>(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QList<float>*>(_a[0]) = _r; }  break;
        case 9: { QVector<float> _r = _t->copyFloatVector((*reinterpret_cast< const QVector<float>(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVector<float>*>(_a[0]) = _r; }  break;
        case 10: { QList<short> _r = _t->copyShortList((*reinterpret_cast< const QList<short>(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QList<short>*>(_a[0]) = _r; }  break;
        case 11: { QVector<short> _r = _t->copyShortVector((*reinterpret_cast< const QVector<short>(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVector<short>*>(_a[0]) = _r; }  break;
        default: ;
        }
    }
}

const QMetaObjectExtraData TestObject::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject TestObject::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_TestObject,
      qt_meta_data_TestObject, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &TestObject::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *TestObject::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *TestObject::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_TestObject))
        return static_cast<void*>(const_cast< TestObject*>(this));
    return QObject::qt_metacast(_clname);
}

int TestObject::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 12)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    }
    return _id;
}

// SIGNAL 0
void TestObject::aSignal(const QString & _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
