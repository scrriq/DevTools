import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: header
    width: parent.width
    height: 56
    color: "#212121"
    property string currentPage: "Projects"
    signal pageSelected(string page)

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: [ "Projects", "Tasks", "Gradient", "CodeTools", "Account" ]
            delegate: Button {
                id: btn
                text: modelData
                flat: true
                background: Rectangle { color: "transparent" }
                Layout.fillWidth: true
                Layout.preferredHeight: header.height
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.alignment: Qt.AlignVCenter

                contentItem: Text {
                    text: btn.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                    color: header.currentPage === btn.text
                           ? Material.accent
                           : "white"
                    anchors.fill: parent
                }

                onClicked: {
                    header.currentPage = btn.text
                    header.pageSelected(btn.text)
                }
            }
        }
    }
}
