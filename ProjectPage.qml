import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Controls.Material 2.15

Page {
    id: projectsPage
    Component {
        id: detailPageComponent
        ProjectDetailPage { stackView: projectsPage.stackView }
    }
    property StackView stackView
    property bool isNameValid: nameField.text.trim().length > 0
    property bool isDateRangeValid: parseDate(startDatePicker.selectedDate) <= parseDate(endDatePicker.selectedDate)

    function parseDate(dateStr) {
        var parts = dateStr.split(".")
        return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10))
    }


    header: ToolBar {
        width: parent.width
        contentHeight: 56
        background: Rectangle {
            color: "#001F3F"
        }

        RowLayout {
            anchors.fill: parent
            Label {
                text: "All Projects:"
                font.pixelSize: 24
                color: "white"
                Layout.leftMargin: 40
                Layout.fillWidth: true
            }

            Button {
                text: "Create Project"
                icon.name: "add"
                Layout.rightMargin: 40
                onClicked: dialog.open()
            }
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: projectsPage.header.height + 16
            margins: 16
        }
        spacing: 12
        Text {
            visible: listView.count === 0
            text: "Список проектов пуст"
            color: "red"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
        }
        Text {
            id: errorText
            text: {
                if (!dialog.isNameValid) {
                    return "Ошибка: имя проекта не может быть пустым."
                } else if (!dialog.isDateRangeValid) {
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
            model: projectManager
            spacing: 12
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: ProjectCard {
                projectId: id
                projectName: name
                projectState: status
                projectStartDate: startDate
                projectEndDate: endDate
                onClicked: function(projectId) {
                    let page = detailPageComponent.createObject(stackView, { stackView: stackView, projectId: projectId })
                    stackView.push(page)
                }
            }
        }
    }



    Dialog {
        id: dialog
        width: 400
        modal: true
        title: "Create Project"
        standardButtons: Dialog.Ok | Dialog.Cancel
        x: (parent.width  - width ) / 2
        y: (parent.height - height) / 2

        property bool isNameValid: nameField.text.trim().length > 0
        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            TextField {
                id: nameField
                placeholderText: "Project name"
                Layout.fillWidth: true
                onTextChanged: dialog.isNameValid = text.trim().length > 0
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

             projectManager.createProject(
                 nameField.text.trim(),
                 stateCombo.currentText,
                 startDatePicker.selectedDate,
                 endDatePicker.selectedDate
             )
             projectManager.saveToFile()

             nameField.text = ""
             stateCombo.currentIndex = 0
             startDatePicker.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
             endDatePicker.selectedDate = Qt.formatDate(new Date(), "dd.MM.yyyy")
             errorText.visible = false

             dialog.close()
         }
    }
}
