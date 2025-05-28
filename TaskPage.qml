import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 2.15
import DevTools 1.0

Page {
    id: taskPage

    TaskManager {
        id: taskModel
        Component.onCompleted: {
            loadFromFile("tasks.txt");
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
        ListView {
            id: listView
            model: taskModel
            spacing: 8
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Rectangle {
                x: 16
                width: listView.width - 32
                height: 70
                radius: 6
                color: "#04361C"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    Text { text: name; font.pixelSize: 16; color: "white"; elide: Text.ElideRight; Layout.preferredWidth: parent.width * 0.2; Layout.alignment: Qt.AlignVCenter }
                    Text { text: projectManager.getById(projectId).name ? projectManager.getById(projectId).name : "-"; font.pixelSize: 14; color: "#CFCFCF"; elide: Text.ElideRight; Layout.preferredWidth: parent.width * 0.2; Layout.alignment: Qt.AlignVCenter }
                    Text { text: startDate + " — " + endDate; font.pixelSize: 14; color: "#CFCFCF"; elide: Text.ElideRight; Layout.preferredWidth: parent.width * 0.2; Layout.alignment: Qt.AlignVCenter }
                    ComboBox { model: ["NotStated","Backlog","InProgress","Waiting"]; currentIndex: model.indexOf(status); onCurrentTextChanged: { taskModel.toggleStatus(id, currentText); taskModel.saveToFile("tasks.txt"); } Layout.preferredWidth: parent.width * 0.2; Layout.alignment: Qt.AlignVCenter }
                    Button { text: "X"; flat: true; font.pixelSize: 16; width: 24; height: 24; Layout.alignment: Qt.AlignVCenter; onClicked: deleteDialog.open() }

                    Dialog {
                        id: deleteDialog
                        modal: true
                        title: "Confirm Deletion"
                        standardButtons: Dialog.Yes | Dialog.No
                        width: 300
                        x: (taskPage.width - width)/2; y: (taskPage.height - height)/2
                        onAccepted: { taskModel.removeTask(id); taskModel.saveToFile("tasks.txt"); }
                        Text { text: "Delete task \"" + name + "\"?"; wrapMode: Text.WordWrap; anchors.centerIn: parent }
                    }
                }
            }
        }
    }

    // Dialog to create a task
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
            anchors.margins: 16
            anchors.centerIn: parent
            spacing: 8

            TextField { id: nameField; placeholderText: "Task name"; Layout.fillWidth: true }
            ComboBox { id: stateCombo; model: ["NotStated","Backlog","InProgress","Waiting"]; currentIndex: 0; Layout.fillWidth: true }
            CustomDatePicker { id: startPicker; Layout.fillWidth: true }
            CustomDatePicker { id: endPicker; Layout.fillWidth: true }
        }

        onAccepted: {
            if (!nameField.text.trim()) return;
            taskModel.createTask("", nameField.text, stateCombo.currentText, startPicker.selectedDate, endPicker.selectedDate);
            taskModel.saveToFile("tasks.txt"); nameField.text = "";
        }
    }
}
