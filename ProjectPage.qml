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
            if (!isNameValid) return;
            projectManager.createProject(
                nameField.text,
                stateCombo.currentText,
                startDatePicker.selectedDate,
                endDatePicker.selectedDate
            )
            projectManager.saveToFile("projects.txt")
            nameField.text = ""
        }
    }
}
