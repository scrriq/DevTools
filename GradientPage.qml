import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15
import App.Controls 1.0

Page {
    id: root
    title: "Gradient Builder"

    property alias model: gradientModel
    GradientModel { id: gradientModel }

    header: ToolBar {
        Label {
            text: root.title
            font.pixelSize: 20
            anchors.centerIn: parent
            color: "white"
        }
        background: Rectangle { color: "#2c3e50" }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentLayout.height + 40

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 20

            Canvas {
                id: preview
                Layout.fillWidth: true; height: 200

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var grd
                    if (gradientModel.gradientType === GradientModel.Linear) {
                        var cx   = width/2, cy = height/2
                        var diag = Math.sqrt(width*width + height*height)
                        var half = diag/2
                        var rad  = gradientModel.angle * Math.PI/180
                        var dx   = Math.cos(rad)*half
                        var dy   = Math.sin(rad)*half
                        grd = ctx.createLinearGradient(
                            cx - dx, cy - dy,
                            cx + dx, cy + dy
                        )
                    } else {
                        var cx = width/2, cy = height/2
                        var r  = Math.min(width, height)/2
                        grd = ctx.createRadialGradient(cx,cy, 0, cx,cy, r)
                    }

                    // проходим по валидным остановкам
                    gradientModel.stopsList.forEach(function(stop) {
                        if (stop
                            && typeof stop.position === "number"
                            && stop.color !== undefined
                        ) {
                            var pos = Math.min(1, Math.max(0, stop.position/100))
                            grd.addColorStop(pos, stop.color)
                        }
                    })

                    ctx.fillStyle = grd
                    ctx.fillRect(0,0, width, height)
                }

                Connections {
                    target: gradientModel
                    function onStopsChanged()        { preview.requestPaint() }
                    function onAngleChanged()        { preview.requestPaint() }
                    function onGradientTypeChanged() { preview.requestPaint() }
                    function onCurrentColorChanged(){ preview.requestPaint() }
                }
            }

            RowLayout {
                spacing: 10
                Button {
                    text: "Linear"
                    checked: gradientModel.gradientType === GradientModel.Linear
                    checkable: true
                    onClicked: gradientModel.gradientType = GradientModel.Linear
                }
                Button {
                    text: "Radial"
                    checked: gradientModel.gradientType === GradientModel.Radial
                    checkable: true
                    onClicked: gradientModel.gradientType = GradientModel.Radial
                }
                Slider {
                    visible: gradientModel.gradientType === GradientModel.Linear
                    from: 0
                    to: 360
                    value: gradientModel.angle
                    onMoved: gradientModel.angle = value
                    Layout.fillWidth: true
                }
            }

            ListView {
                id: stopsList
                model: gradientModel
                spacing: 5
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                clip: true

                delegate: RowLayout {
                    width: stopsList.width
                    spacing: 10

                    Rectangle {
                        width: 40; height: 40; radius: 5
                        color: model.stopColor
                        border.color: "#7f8c8d"
                    }

                    TextField {
                        id: posField
                        text: model.stopPosition
                        validator: IntValidator { bottom: 0; top: 100 }
                        onEditingFinished: {
                            var newPos = parseInt(text)
                            if (!isNaN(newPos)) {
                                gradientModel.updateStop(index, model.stopColor, newPos)
                            } else {
                                text = model.stopPosition  // откатываем
                            }
                        }
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: colorField
                        text: model.stopColor
                        placeholderText: "#RRGGBB"
                        onEditingFinished: {
                            // проверяем, что пользователь ввёл корректный #RGB или #RRGGBB
                            var m = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.exec(text)
                            if (m) {
                                var c = Qt.color(text)
                                if (c !== undefined) {
                                    gradientModel.updateStop(index, c, model.stopPosition)
                                    text = model.stopColor
                                }
                            } else {
                                text = model.stopColor
                            }
                        }
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "✕"
                        onClicked: gradientModel.removeStop(index)
                    }
                }
            }


            GridLayout {
                columns: 2
                width: parent.width

                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    RowLayout {
                        Label { text: "Red:" }
                        SpinBox {
                            from: 0
                            to: 255
                            value: gradientModel.currentColor.r * 255
                            onValueModified: gradientModel.currentColor = Qt.rgba(value/255, gradientModel.currentColor.g, gradientModel.currentColor.b, gradientModel.currentColor.a)
                        }
                    }

                    RowLayout {
                        Label { text: "Green:" }
                        SpinBox {
                            from: 0
                            to: 255
                            value: gradientModel.currentColor.g * 255
                            onValueModified: gradientModel.currentColor = Qt.rgba(gradientModel.currentColor.r, value/255, gradientModel.currentColor.b, gradientModel.currentColor.a)
                        }
                    }

                    RowLayout {
                        Label { text: "Blue:" }
                        SpinBox {
                            from: 0
                            to: 255
                            value: gradientModel.currentColor.b * 255
                            onValueModified: gradientModel.currentColor = Qt.rgba(gradientModel.currentColor.r, gradientModel.currentColor.g, value/255, gradientModel.currentColor.a)
                        }
                    }

                    RowLayout {
                        Label { text: "Alpha:" }
                        SpinBox {
                            from: 0
                            to: 100
                            value: gradientModel.currentColor.a * 100
                            onValueModified: gradientModel.currentColor = Qt.rgba(gradientModel.currentColor.r, gradientModel.currentColor.g, gradientModel.currentColor.b, value/100)
                        }
                    }
                }

                ColumnLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignTop

                    Rectangle {
                        width: 100
                        height: 100
                        color: gradientModel.currentColor
                        border.color: "#34495e"
                        radius: 8
                    }

                    Button {
                        text: "Add Stop"
                        onClicked: gradientModel.addStop(gradientModel.currentColor, 50)
                    }

                    Button {
                        text: "Pick Color"
                        onClicked: colorDialog.open()
                    }
                }
            }
        }
    }

    ColorDialog {
        id: colorDialog
        selectedColor: gradientModel.currentColor
        onAccepted: gradientModel.currentColor = selectedColor
    }
}
