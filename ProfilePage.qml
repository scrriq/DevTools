// ProfilePage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1

Page {
    id: profilePage

    Material.theme: Material.Light
    Material.accent: Material.Teal

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: parent.width * 0.8

        Label {
            text: "Welcome, " + Auth.userName
            font.pixelSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 100; height: 100

            Image {
                anchors.fill: parent
                source: Auth.userAvatarPath && Auth.userAvatarPath !== ""
                        ? Auth.userAvatarPath
                        : ""
                fillMode: Image.PreserveAspectFit
            }
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                radius: width / 2
            }
        }

        Button {
            text: "Change Avatar"
            Layout.alignment: Qt.AlignHCenter
            onClicked: avatarDialog.open()
        }

        FileDialog {
            id: avatarDialog
            title: "Select Avatar Image"
            folder: StandardPaths.pictures
            nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
            onAccepted: {
                if (avatarDialog.file && avatarDialog.file !== "") {
                    Auth.updateUserAvatar(avatarDialog.file)
                }
            }
        }

        TextArea {
            id: descriptionArea
            placeholderText: "Tell us about yourself..."
            text: Auth.userDescription
            Layout.fillWidth: true
            wrapMode: TextArea.Wrap
            height: 100
        }

        TextField {
            id: preferencesField
            placeholderText: "Your preferences (e.g., dark mode, notifications...)"
            text: Auth.userPreferences
            Layout.fillWidth: true
        }


        Button {
            text: "Save Profile"
            Layout.alignment: Qt.AlignHCenter
            onClicked: Auth.updateUserProfile(descriptionArea.text, preferencesField.text)
        }

        Button {
            text: "Logout"
            Layout.alignment: Qt.AlignHCenter
            onClicked: Auth.logout()
        }
    }
}
