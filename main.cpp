#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ProjectManager.h"
#include "gradientmodel.h"
#include "TaskManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // подсоединение backend с qml
    ProjectManager projectManager;
    TaskManager taskManager;
    GradientModel gradModel;

    QQmlApplicationEngine engine;
    qmlRegisterType<TaskManager>("DevTools", 1, 0, "TaskManager");
    engine.rootContext()->setContextProperty("projectManager", &projectManager);
    engine.rootContext()->setContextProperty("gradientModel", &gradModel);
    engine.rootContext()->setContextProperty("taskManager", &taskManager);



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
