import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: trigger.implicitWidth + 16
    implicitHeight: trigger.implicitHeight

    property string selectedDate: Qt.formatDate(new Date(), "dd.MM.yyyy")
    signal dateChanged(string newDate)

    function dateFromString(str) {
        var parts = str.split(".")
        return new Date(parseInt(parts[2], 10),
                        parseInt(parts[1], 10) - 1,
                        parseInt(parts[0], 10))
    }

    Rectangle {
        id: triggerBg
        anchors.fill: trigger
        color: "#333333"
        border { color: "#FFA100"; width: 1 }
        radius: 4
    }

    Button {
        id: trigger
        anchors.fill: parent
        flat: true
        contentItem: Text {
            text: root.selectedDate
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.pixelSize: 16
        }
        onClicked: popup.open()
    }

    Popup {
        id: popup
        x: trigger.mapToItem(null, 0, 0).x + 40
        y: trigger.mapToItem(null, 0, 0).y - 100
        width: 280
        height: 320
        modal: true
        focus: true

        Rectangle {
            anchors.fill: parent
            color: "#2E2E2E"
            border { color: "#FFA100"; width: 1 }
            radius: 6
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            DayOfWeekRow { locale: Qt.locale(); Layout.fillWidth: true }

            MonthGrid {
                id: grid
                month: 0
                year: 1900
                locale: Qt.locale()
                Layout.fillWidth: true

                onClicked: (date) => {
                    var formatted = Qt.formatDate(date, "dd.MM.yyyy")
                    root.selectedDate = formatted
                    root.dateChanged(formatted)
                    popup.close()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Button {
                    text: "<"
                    onClicked: {
                        if (grid.month > 0) {
                            grid.month--
                        } else {
                            grid.month = 11
                            grid.year--
                        }
                    }
                }
                Text {
                    text: Qt.locale().standaloneMonthName(grid.month + 1) + " " + grid.year
                    font.bold: true
                    color: "#FFFFFF"
                }
                Button {
                    text: ">"
                    onClicked: {
                        if (grid.month < 11) {
                            grid.month++
                        } else {
                            grid.month = 0
                            grid.year++
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Text { text: "Год:"; color: "#FFFFFF" }
                SpinBox {
                    id: yearSelector
                    from: 1900
                    to: 2100
                    value: grid.year
                    editable: true
                    inputMethodHints: Qt.ImhDigitsOnly
                    onValueChanged: grid.year = value
                }
            }
        }

        onOpened: {
            var d = dateFromString(root.selectedDate)
            grid.month = d.getMonth()
            grid.year = d.getFullYear()
        }
    }
}
