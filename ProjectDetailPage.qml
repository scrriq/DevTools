import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Controls.Material 2.15
import DevTools 1.0

Page {
    id: detailPage
    property StackView stackView
    property string projectId: ""
    signal goBack()
    property bool isNameValid: taskName.text.trim().length > 0
    property bool isDateRangeValid: parseDate(taskStart.selectedDate) <= parseDate(taskEnd.selectedDate)

    function parseDate(dateStr) {
        var parts = dateStr.split(".")
        return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10))
    }

    TaskManager {
        id: taskModel
        currentProjectId: projectId
        Component.onCompleted: loadFromFile()
    }


    header: ToolBar {
        contentHeight: 56
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 50
            Button {
                text: "< Back"
                onClicked: stackView.pop()
            }
            Label {
                text:"Проект: " + projectManager.getById(projectId).name
                font.pixelSize: 24
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Rectangle {
            color: "#0A194A"; radius: 8
            Layout.fillWidth: true; Layout.preferredHeight: 100

            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.fill: parent; anchors.margins: 20; spacing: 20;
                Text { text: "Состояние:"; font.pixelSize: 24;color:"white"}
                ComboBox {
                    model: ["NotStated","Backlog","InProgress","Waiting"]
                    currentIndex: model.indexOf(projectManager.getById(projectId).status)
                    onCurrentTextChanged: {
                        projectManager.updateStatus(projectId, currentText)
                        projectManager.saveToFile()
                    }
                }
                Text {
                    text: "Срок: " + projectManager.getById(projectId).startDate
                         + " — " + projectManager.getById(projectId).endDate
                    font.pixelSize: 24;color: "white"
                }
                Button {
                    text: "Добавить задачу"
                    icon.name: "add"
                    onClicked: taskDialog.open()
                }
            }
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
            model: taskModel
            spacing: 20

            delegate: TaskCard {
                taskId: id
                taskName: name
                taskState: status
                taskStartDate: startDate
                taskEndDate: endDate
                page: detailPage
                onStatusChanged: (newState) => {
                    taskModel.toggleStatus(taskId, newState)
                    taskModel.saveToFile()
                }
            }
            Layout.fillWidth: true; Layout.fillHeight: true
        }
    }

    Dialog {
        id: taskDialog
        title: "Новая Задача"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width:500
        x: (parent.width  - width ) / 2
        y: (parent.height - height) / 2
        ColumnLayout {
            anchors.fill: parent; spacing: 8;
            TextField { id: taskName; placeholderText: "Название задачи";Layout.fillWidth: true}
            ComboBox { id: taskState; model: ["NotStated","Backlog","InProgress","Waiting"];Layout.fillWidth: true }
            CustomDatePicker { id: taskStart; Layout.fillWidth: true}
            CustomDatePicker { id: taskEnd;Layout.fillWidth: true }
        }
        onAccepted: {
            isNameValid = taskName.text.trim().length > 0
            isDateRangeValid = parseDate(taskStart.selectedDate) <= parseDate(taskEnd.selectedDate)

            if (!isNameValid || !isDateRangeValid) {
                errorText.visible = true
                return
            }

            taskModel.createTask(
                projectId,
                taskName.text.trim(),
                taskState.currentText,
                taskStart.selectedDate,
                taskEnd.selectedDate
            )
            taskModel.saveToFile()

            taskName.text = ""
            taskState.currentIndex = 0
            taskStart.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
            taskEnd.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
            errorText.visible = false
        }
    }
}
