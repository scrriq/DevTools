import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import "."

ApplicationWindow {
    id: win
    visible: true
    width: 1024; height: 768
    title: "DevTools"

    Material.theme: Material.Dark

    Header { id: header }

    StackView {
        id: stack
        anchors {
            top: header.bottom
            left: parent.left; right: parent.right; bottom: parent.bottom
        }


        // Объявляем сразу нужные компоненты
        Component { id: projectsComponent; ProjectPage {} }
        Component { id: tasksComponent;    TaskPage {} }
        Component { id: gradientComponent; GradientPage {} }
        Component { id: codeToolsComponent; CodeToolsPage {} }
        Component { id: accountComponent;   AccountPage {} }

        // Стартуем с Projects
        initialItem: projectsComponent

        Connections {
            target: header
            function onPageSelected(page) {
                header.currentPage = page  // чтобы Header знал, что подсвечивать
                switch (page) {
                case "Projects":
                    stack.replace(projectsComponent)
                    break
                case "Tasks":
                    stack.replace(tasksComponent)
                    break
                case "Gradient":
                    stack.replace(gradientComponent)
                    break
                case "CodeTools":
                    stack.replace(codeToolsComponent)
                    break
                case "Account":
                    stack.replace(accountComponent)
                    break
                }
            }
        }
    }
}
