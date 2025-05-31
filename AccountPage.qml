import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import "."

Page {
    id: accountPage
    signal authSuccess()

    Material.theme: Material.Dark
    Material.accent: Material.Teal

    Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: Auth.isAuthenticated
            ? profileComponent
            : authFormComponent
    }

    Component {
        id: authFormComponent

        Item {
            anchors.fill: parent

            property bool isLoginMode: true

            ColumnLayout {
                id: formLayout
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                Label {
                    text: isLoginMode ? "Login" : "Register"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                TextField {
                    id: loginField
                    placeholderText: "Username"
                    Layout.fillWidth: true
                }

                // Показываем поле "Имя" только в режиме регистрации
                TextField {
                    id: nameField
                    placeholderText: "Your Name"
                    visible: !isLoginMode
                    Layout.fillWidth: true
                }

                TextField {
                    id: pwdField
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                }

                Label {
                    id: errorLabel
                    text: ""
                    color: Material.color(Material.Red)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: isLoginMode ? "Login" : "Register"
                    enabled: isLoginMode
                             ? (loginField.text && pwdField.text)
                             : (loginField.text && nameField.text && pwdField.text)
                    Layout.fillWidth: true
                    onClicked: {
                        errorLabel.text = ""
                        if (isLoginMode) {
                            if (Auth.login(loginField.text, pwdField.text)) {
                                authSuccess()
                            } else {
                                errorLabel.text = "Invalid login or password"
                            }
                        } else {
                            const nameRe = /^[A-Za-z\\s]+$/
                            if (!nameRe.test(nameField.text)) {
                                errorLabel.text = "Name: letters only"
                            } else if (Auth.registerUser(loginField.text, nameField.text, pwdField.text)) {
                                authSuccess()
                            } else {
                                errorLabel.text = "Username already taken"
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Label {
                        text: isLoginMode ? "No account?" : "Already registered?"
                    }

                    Button {
                        text: isLoginMode ? "Register" : "Login"
                        flat: true
                        onClicked: {
                            isLoginMode = !isLoginMode
                            errorLabel.text = ""
                            loginField.text = ""
                            nameField.text = ""
                            pwdField.text = ""
                        }
                    }
                }
            }
        }
    }

    Component {
        id: profileComponent
        ProfilePage {}
    }
}
