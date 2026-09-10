import QtQuick 2.15

/*
 * ============================================================================
 * ORZHOV - COMPONENTE: CARD
 * ============================================================================
 * Espelha .card + .name_user do login.css (o <li class="card"> da grade de
 * seleção de usuários em login.html): Avatar + nome, empilhados com gap 16px.
 *
 *   .card { flex column; justify:center; align:center; gap:16px; padding:8px }
 *   .name_user { font-size:14px; weight:500; color:var(--light);
 *                text-shadow: 0 4px 8px color-mix(dark 50%, transparent) }
 *
 * Uso típico (dentro do UserGrid do Main.qml):
 *
 *   Card {
 *       userName: model.name
 *       displayName: model.realName
 *       avatarSource: model.icon
 *       onClicked: root.selectUser(model.name)
 *   }
 * ============================================================================
 */
Column {
    id: root

    property string userName: ""
    property string displayName: ""
    property url avatarSource: ""
    property bool selected: false

    signal clicked()

    spacing: 16
    width: 100

    readonly property color colorLight: "#F8F8F8"

    Avatar {
        id: avatar
        anchors.horizontalCenter: parent.horizontalCenter
        source: root.avatarSource
        selected: root.selected
        onClicked: root.clicked()
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.displayName !== "" ? root.displayName : root.userName
        color: root.colorLight
        font.family: "Inter"
        font.pixelSize: 14
        font.weight: Font.Medium
        elide: Text.ElideRight
        width: root.width + 40
        horizontalAlignment: Text.AlignHCenter

        // aproxima o text-shadow do CSS (0 4px 8px dark 50%) sem depender
        // de QtGraphicalEffects, mantendo o componente leve e portável
        style: Text.Raised
        styleColor: Qt.rgba(0.19, 0.19, 0.21, 0.5)
    }
}
