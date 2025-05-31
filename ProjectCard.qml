import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Controls.Material 2.15


Item {
    id: root
    width: ListView.view ? ListView.view.width : 300
    height: 100

    property string projectId
    property string projectName
    property string projectState
    property string projectStartDate
    property string projectEndDate

    signal clicked(string projectId)

    Rectangle {
        anchors.fill: parent
        color: "#0A194A"
        radius: 10

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked(root.projectId)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Text {
                text: projectName
                font {
                    pixelSize: 18
                    bold: true
                    family: "Arial"
                }
                color: "white"
                elide: Text.ElideRight
                Layout.preferredWidth: parent.width * 0.25
                Layout.maximumWidth: parent.width * 0.25
            }

            Column {
                Layout.preferredWidth: parent.width * 0.5
                Layout.alignment: Qt.AlignCenter

                Text {
                    text: startDate + " — " + endDate
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: 14
                        family: "Arial"
                    }
                    color: "#CFCFCF"
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                spacing: 8
                Layout.preferredWidth: parent.width * 0.25
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: {
                        if (projectState === "NotStated") return "#A7A7A7";
                        if (projectState === "Backlog") return "#F60707";
                        if (projectState === "InProgress") return "#07F6FA";
                        if (projectState === "Waiting") return "#FBA700";
                        return "gray";
                    }
                }

                Text {
                    text: projectState
                    color: "white"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
            }
            Button {
                id: deleteBtn
                text: "X"
                flat: true
                font.pixelSize: 50
                contentItem: Text {
                    text: deleteBtn.text
                    font.pixelSize: 18
                    color: "#E0115F"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                width: 32; height: 32
                onClicked: confirmDelete.open()
            }
            Dialog {
                id: confirmDelete
                title: "Подтвердите удаление"
                modal: true
                width: 300
                x: (parent.width  - width ) / 2
                y: (parent.height - height) / 2
                standardButtons: Dialog.Yes | Dialog.No
                // тело диалога
                parent: projectsPage
                anchors.centerIn: projectsPage
                contentItem: Text {
                    text: "Удалить проект «" + projectName + "»?"
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left; right: parent.right
                        margins: 16
                    }
                }
                onAccepted: {
                    projectManager.removeProject(projectId)
                    projectManager.saveToFile()
                    taskManager.removeTasksByProject(projectId)
                    taskManager.saveToFile()
                }
            }
        }
    }

}
