#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ProjectManager.h"
// #include "taskmanager.h"
#include "gradientmodel.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // подсоединение backend с qml
    ProjectManager projectManager;
    GradientModel gradModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("projectManager", &projectManager);
    engine.rootContext()->setContextProperty("gradientModel", &gradModel);



    // обработчик зависаний
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("DevTools", "Main");

    return app.exec();
}
