import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 2.15
import DevTools 1.0

Page {
    id: taskPage
    property bool isNameValid: nameField.text.trim().length > 0
    property bool isDateRangeValid: parseDate(startDatePicker.selectedDate) <= parseDate(endDatePicker.selectedDate)
    function parseDate(dateStr) {
        var parts = dateStr.split(".")
        return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10))
    }

    TaskManager {
        id: taskModel
        Component.onCompleted: {
            loadFromFile();
            setProjectFilter("");
        }
    }

    header: ToolBar {
        id: toolbar
        width: parent.width
        contentHeight: 56
        background: Rectangle { color: "#001F3F" }
        RowLayout {
            anchors.fill: parent
            Label {
                text: "All Tasks"
                font.pixelSize: 24
                color: "white"
                Layout.leftMargin: 20
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
            Button {
                text: "Create Task"
                icon.name: "add"
                Layout.rightMargin: 20
                Layout.alignment: Qt.AlignVCenter
                onClicked: taskDialog.open()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: toolbar.height
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Список задач пуст"
            color: "red"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            visible: listView.count === 0
            Layout.fillWidth: true
        }
        Text {
            id: errorText
            text: {
                if (!isNameValid) {
                    return "Ошибка: имя проекта не может быть пустым."
                } else if (!isDateRangeValid) {
                    return "Ошибка: дата начала не может быть позже даты окончания."
                }
                return ""
            }
            color: "red"
            visible: false
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        ListView {
               id: listView
               model: taskModel
               spacing: 8
               clip: true
               Layout.fillWidth: true
               Layout.fillHeight: true

               delegate: TaskCard {

                  page: taskPage
                  taskManager: taskModel
                   taskId: id
                   taskName: name
                   taskState: status
                   taskStartDate: startDate
                   taskEndDate: endDate

                   onStatusChanged: (newState) => {
                       taskModel.toggleStatus(taskId, newState)
                       taskModel.saveToFile()
                   }
               }
           }
    }

    Dialog {
        id: taskDialog
        modal: true
        title: "New Task"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 450
        x: (taskPage.width - width)/2
        y: (taskPage.height - height)/2

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            TextField {
                id: nameField
                placeholderText: "Project name"
                Layout.fillWidth: true
                onTextChanged: isNameValid = text.trim().length > 0
            }

            ComboBox {
                id: stateCombo
                Layout.fillWidth: true
                model: ["NotStated", "Backlog", "InProgress", "Waiting"]
                currentIndex: 0
            }
            CustomDatePicker {
                id: startDatePicker
                Layout.fillWidth: true
            }

            CustomDatePicker {
                id: endDatePicker
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            isNameValid = nameField.text.trim().length > 0
            isDateRangeValid = parseDate(startDatePicker.selectedDate) <= parseDate(endDatePicker.selectedDate)

            if (!isNameValid || !isDateRangeValid) {
                errorText.visible = true
                return
            }

            taskModel.createTask(
                "",
                nameField.text.trim(),
                stateCombo.currentText,
                startDatePicker.selectedDate,
                endDatePicker.selectedDate
            )
            taskModel.saveToFile()

            nameField.text = ""
            stateCombo.currentIndex = 0
            startDatePicker.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
            endDatePicker.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
            errorText.visible = false

            taskDialog.close()
        }
    }
}
