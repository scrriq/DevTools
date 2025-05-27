import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15


Item {
    id: root
    width: ListView.view ? ListView.view.width : 300
    height: 100

    property string projectName
    property string projectState
    property string projectStartDate
    property string projectEndDate

    Rectangle {
        anchors.fill: parent
        color: "#0A194A"
        radius: 10

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            // Название проекта (1/4 ширины)
            Text {
                text: projectName
                font {
                    pixelSize: 18
                    bold: true
                    family: "Arial"
                }
                color: "white"
                elide: Text.ElideRight
                Layout.preferredWidth: parent.width * 0.25 // 25%
                Layout.maximumWidth: parent.width * 0.25
            }

            // Даты (2/4 ширины)
            Column {
                Layout.preferredWidth: parent.width * 0.5 // 50%
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

            // Статус (1/4 ширины)
            RowLayout {
                spacing: 8
                Layout.preferredWidth: parent.width * 0.25 // 25%
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
                    text: {
                        if (projectState === "NotStated") return "Не начат";
                        if (projectState === "Backlog") return "В очереди";
                        if (projectState === "InProgress") return "В процессе";
                        if (projectState === "Waiting") return "Ожидание";
                        return "Неизвестно";
                    }
                    color: "white"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
            }
        }
    }

}
