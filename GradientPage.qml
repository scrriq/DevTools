// import QtQuick 2.15
// import QtQuick.Controls 2.15
// import QtQuick.Controls.Material 2.15
// import QtGraphicalEffects 1.15

// Page {
//     id: page; style: Material
//     header: ToolBar { contentHeight: 56; Label { text: "Gradient Builder"; font.pixelSize: 24; color: "white" } }

//     Column { anchors.fill: parent; anchors.topMargin: header.height; spacing: 16; padding: 16 }

//     Rectangle {
//         id: preview; width: parent.width; height: 200; radius: 8
//         gradient: gradientModel.type === "Linear"
//             ? Gradient {
//                 GradientStop { position: gradientModel.stops[0].position; color: gradientModel.stops[0].color }
//                 GradientStop { position: gradientModel.stops[1].position; color: gradientModel.stops[1].color }
//                 GradientStop { position: gradientModel.stops[2].position; color: gradientModel.stops[2].color }
//                 GradientStop { position: gradientModel.stops[3].position; color: gradientModel.stops[3].color }
//               }
//             : RadialGradient {
//                 centerX: preview.width/2; centerY: preview.height/2
//                 radius: Math.min(preview.width, preview.height)/2
//                 GradientStop { position: gradientModel.stops[0].position; color: gradientModel.stops[0].color }
//                 GradientStop { position: gradientModel.stops[1].position; color: gradientModel.stops[1].color }
//                 GradientStop { position: gradientModel.stops[2].position; color: gradientModel.stops[2].color }
//                 GradientStop { position: gradientModel.stops[3].position; color: gradientModel.stops[3].color }
//               }
//     }

//     Row { spacing: 16 }
//     ComboBox {
//         id: typeCombo; model: ["Linear","Radial"]
//         onCurrentTextChanged: gradientModel.type = currentText
//     }
//     Slider {
//         id: angleSlider; from: 0; to: 360; visible: typeCombo.currentText === "Linear"
//         onValueChanged: gradientModel.angle = value
//     }
//     Label { text: typeCombo.currentText === "Linear" ? angleSlider.value + "°" : ""; color: "white" }

//     Repeater {
//         model: 4
//         delegate: Row { spacing: 8; anchors.horizontalCenter: parent.horizontalCenter
//             Slider {
//                 from: 0; to: 100; value: gradientModel.stops[index].position;
//                 onValueChanged: gradientModel.setStop(index, value, gradientModel.stops[index].color)
//             }
//             Rectangle {
//                 width: 32; height: 32; color: gradientModel.stops[index].color; radius: 4
//                 MouseArea { anchors.fill: parent; onClicked: colorDialogs[index].open() }
//             }
//             ColorDialog { id: colorDialogs[index]
//                 onAccepted: gradientModel.setStop(index, gradientModel.stops[index].position, currentColor)
//             }
//         }
//     }
// }
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

Page {
    header: ToolBar { contentHeight: 56; Label { text: "Gradient"; font.pixelSize: 24; color: "white" } }
    Rectangle { anchors.fill: parent; color: "transparent"
        Label { text: "Component is under development"; anchors.centerIn: parent; color: "white"; font.pixelSize: 20 }
    }
}
