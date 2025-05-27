cmake_minimum_required(VERSION 3.16)

project(DevTools VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appDevTools
    main.cpp
)

qt_add_qml_module(appDevTools
    URI DevTools
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES
        SOURCES Project.h
        SOURCES
        QML_FILES ProjectPage.qml
        SOURCES
        SOURCES gradientmodel.h gradientmodel.cpp
        SOURCES ProjectManager.h ProjectManager.cpp
        SOURCES
        QML_FILES Header.qml
        SOURCES
        QML_FILES TaskPage.qml
        QML_FILES GradientPage.qml
        QML_FILES CodeToolsPage.qml
        QML_FILES AccountPage.qml
        QML_FILES CustomDatePicker.qml
        QML_FILES ProjectCard.qml
        RESOURCES resources.qrc
        SOURCES devtools.h
        SOURCES Project.cpp
        SOURCES devtools.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDevTools PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDevTools
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDevTools
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appDevTools
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
