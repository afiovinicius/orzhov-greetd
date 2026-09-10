import QtQuick

/*
 * ============================================================================
 * ORZHOV - COMPONENTE: BUTTON
 * ============================================================================
 * Espelha a classe .btn / .btn.wd do login.css:
 *
 *   .btn { height:36px; radius:14px; background:var(--dark);
 *          padding:8px 16px; color:var(--light); gap:8px }
 *   .btn.wd { width: 100% }
 *
 * Uso típico (dentro do Main.qml):
 *
 *   Button {
 *       text: Translations.current.login
 *       fullWidth: true
 *       onClicked: sddm.login(...)
 *   }
 * ============================================================================
 */
Rectangle {
    id: root

    // --- API pública ---------------------------------------------------
    property string text: ""
    property url icon: ""
    property bool fullWidth: false   // equivalente a .wd
    property bool enabledState: true

    readonly property bool hovered: mouseArea.containsMouse && root.enabledState
    readonly property bool pressed: mouseArea.pressed && root.enabledState

    signal clicked()

    // --- paleta (espelha :root do login.css) ----------------------------
    readonly property color colorDark: "#303036"
    readonly property color colorLight: "#F8F8F8"

    implicitWidth: fullWidth && parent ? parent.width : content.implicitWidth + 32
    implicitHeight: 36
    radius: 14
    opacity: enabledState ? 1.0 : 0.5
    color: pressed ? Qt.darker(colorDark, 1.2) : (hovered ? Qt.lighter(colorDark, 1.25) : colorDark)
    scale: pressed ? 0.97 : 1.0

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Image {
            visible: root.icon !== "" && root.icon != undefined
            source: root.icon
            width: 16
            height: 16
            sourceSize.width: width
            sourceSize.height: height
            anchors.verticalCenter: parent.verticalCenter
            smooth: true
        }

        Text {
            text: root.text
            color: root.colorLight
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.Normal
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabledState
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
