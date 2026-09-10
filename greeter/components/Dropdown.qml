import QtQuick
import QtQuick.Controls

ComboBox {
  id: control
  implicitHeight: 36
  // implicitWidth: 140

  property url icon: ""

    background: Rectangle {
      color: control.pressed ? "#222226" : (control.hovered ? "#3A3A42" : "#303036")
      radius: 14
      border.width: control.activeFocus ? 2 : 0
      border.color: "#F8F8F8"
      Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Row {
      anchors.fill: parent
      leftPadding: 12
      rightPadding: 12
      spacing: 8

      Image {
        visible: control.icon.toString().length > 0
        source: control.icon
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        sourceSize.width: 16
        sourceSize.height: 16
        fillMode: Image.PreserveAspectFit
      }

      Text {
        text: control.displayText
        color: "#F8F8F8"
        font.family: "Inter"
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    delegate: ItemDelegate {
      width: control.width
      contentItem: Text {
        text: modelData
        color: control.highlightedIndex === index ? "#303036" : "#F8F8F8"
        font.family: "Inter"
        font.pixelSize: 14
      }
      background: Rectangle {
        color: control.highlightedIndex === index ? "#F8F8F8" : "transparent"
        radius: 8
      }
    }

    popup: Popup {
      y: control.height + 4
      width: control.width
      padding: 4
      background: Rectangle {
        color: "#303036"
        radius: 14
      }
      contentItem: ListView {
        clip: true
        implicitHeight: contentHeight
        model: control.popup.visible ? control.delegateModel : null
        currentIndex: control.highlightedIndex
      }
    }
  }