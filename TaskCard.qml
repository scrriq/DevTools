    import QtQuick 2.15
    import QtQuick.Controls 2.15
    import QtQuick.Layouts 2.15
    import QtQuick.Controls.Material 2.15
    import DevTools 1.0

    Item {
        id: root
        width: ListView.view ? ListView.view.width : 300
        height: 80

        property string taskId
        property string taskName
        property string taskState
        property string taskStartDate
        property string taskEndDate

        signal statusChanged(string newState)

        Rectangle {
            anchors.fill: parent
            radius: 10; color: "#04361C"
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 14

                // Название задачи
                Text {
                    text: taskName
                    font.pixelSize: 16; color: "white"
                    elide: Text.ElideRight
                    Layout.preferredWidth: parent.width * 0.2
                }

                // Даты
                Text {
                    text: taskStartDate + " — " + taskEndDate
                    font.pixelSize: 12; color: "#CFCFCF"
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width * 0.2
                }

                // ComboBox для ручного выбора статуса
                ComboBox {
                    id: statusCombo
                    model: ["NotStated","Backlog","InProgress","Waiting"]
                    currentIndex: model.indexOf(taskState)
                    onCurrentTextChanged: statusChanged(currentText)
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: parent.width * 0.2
                }

                // CheckBox: при установке → Waiting
                CheckBox {
                    checked: taskState === "Waiting"
                    text: ""
                    onCheckedChanged: {
                        if (checked)
                            statusChanged("Waiting");
                        else if (taskState === "Waiting")
                            statusChanged("NotStated");
                    }
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: parent.width * 0.1
                }

                Button {
                    id: deleteBtn
                    Layout.preferredWidth: parent.width * 0.1
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
                    width: 350
                    x: (parent.width  - width ) / 2
                    y: (parent.height - height) / 2
                    standardButtons: Dialog.Yes | Dialog.No
                    // тело диалога
                    contentItem: Text {
                        text: "Удалить проект «" + taskName + "»?"
                        wrapMode: Text.WordWrap
                        anchors {
                            left: parent.left; right: parent.right
                            margins: 16
                        }
                    }
                    onAccepted: {
                        taskManager.removeTask(taskId)
                        taskManager.saveToFile("tasks.txt")
                    }
                }
            }
        }
    }
