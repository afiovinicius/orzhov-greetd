import QtQuick

Text {
    id: root
    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    text: Qt.formatTime(now, "hh:mm:ss")
    color: "#F8F8F8"
    font.family: "Inter"
    font.pixelSize: 56
    font.weight: Font.Medium
    horizontalAlignment: Text.AlignHCenter
    style: Text.Raised
    styleColor: Qt.rgba(0.19, 0.19, 0.21, 0.5)
}
