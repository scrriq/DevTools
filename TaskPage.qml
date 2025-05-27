import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

Page {
    header: ToolBar { contentHeight: 56; Label { text: "Tasks"; font.pixelSize: 24; color: "white" } }
    Rectangle { anchors.fill: parent; color: "transparent"
        Label { text: "Component is under development"; anchors.centerIn: parent; color: "white"; font.pixelSize: 20 }
    }
}
