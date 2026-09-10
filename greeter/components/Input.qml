import QtQuick
import QtQuick.Controls

/*
 * ============================================================================
 * ORZHOV - COMPONENTE: INPUT
 * ============================================================================
 * Espelha .iptPassword + .checkbox do login.css:
 *
 *   .iptPassword { height:36; radius:14; border:1px solid var(--grey_100);
 *                  background: color-mix(dark 32%, transparent);
 *                  color:var(--light) }
 *   .checkbox label { font-size:10px; color:var(--light) }
 *
 * O toggle "Show Password" já vem embutido (mesmo comportamento do
 * #togglePassword do login.html), então o Main.qml só precisa ler
 * `input.text` — não precisa gerenciar echoMode manualmente.
 *
 * @param isPassword    quando true, mostra o toggle e mascara o texto
 * @param showToggle    permite esconder o checkbox mesmo com isPassword=true
 * @param toggleLabel   texto do checkbox (passar Translations.current aqui)
 * ============================================================================
 */
Column {
    id: root

    property alias text: field.text
    property string placeholder: ""
    property bool isPassword: true
    property bool showToggle: true
    property string toggleLabel: "Show Password"

    signal accepted()

    spacing: 8
    width: 260

    readonly property color colorLight: "#F8F8F8"
    readonly property color colorGrey100: "#B2B3BB"

    function forceFocus() { field.forceActiveFocus() }
    function clear() { field.text = "" }

    Rectangle {
        width: root.width
        height: 36
        radius: 14
        // color-mix(in srgb, var(--dark) 32%, transparent) -> #303036 @ 32%
        color: Qt.rgba(48 / 255, 48 / 255, 54 / 255, 0.32)
        border.width: 1
        border.color: root.colorGrey100

        TextField {
            id: field
            anchors.fill: parent
            leftPadding: 16
            rightPadding: 16
            verticalAlignment: Text.AlignVCenter
            echoMode: root.isPassword && !toggle.checked ? TextInput.Password : TextInput.Normal
            placeholderText: root.placeholder
            font.family: "Inter"
            font.pixelSize: 14
            color: root.colorLight
            placeholderTextColor: Qt.rgba(1, 1, 1, 0.5)
            background: Item {}
            selectByMouse: true
            onAccepted: root.accepted()
        }
    }

    Row {
        visible: root.isPassword && root.showToggle
        spacing: 4

        CheckBox {
            id: toggle
            implicitWidth: 14
            implicitHeight: 14
            padding: 0
            indicator: Rectangle {
                implicitWidth: 12
                implicitHeight: 12
                radius: 3
                border.width: 1
                border.color: root.colorLight
                color: toggle.checked ? root.colorLight : "transparent"
            }
        }

        Text {
            anchors.verticalCenter: toggle.verticalCenter
            text: root.toggleLabel
            color: root.colorLight
            font.family: "Inter"
            font.pixelSize: 10

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: toggle.checked = !toggle.checked
            }
        }
    }
}
