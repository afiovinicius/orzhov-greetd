import QtQuick

Text {
    id: root
    property date now: new Date()

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    text: now.toLocaleDateString(Qt.locale(), Qt.locale().name.toLowerCase().indexOf("pt") === 0
                                  ? "dddd, dd 'de' MMMM 'de' yyyy"
                                  : "dddd, MMMM dd, yyyy")

    color: "#F8F8F8"
    font.family: "Inter"
    font.pixelSize: 32
    font.weight: Font.Normal
    horizontalAlignment: Text.AlignHCenter
    capitalization: Font.Capitalize
    style: Text.Raised
    styleColor: Qt.rgba(0.19, 0.19, 0.21, 0.5)
}
