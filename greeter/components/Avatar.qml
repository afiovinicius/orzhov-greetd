import QtQuick

/*
* ============================================================================
* ORZHOV - COMPONENTE: AVATAR
* ============================================================================
* Espelha a classe .avatar do login.css:
*
* .avatar { 100x100; radius:32; overflow:hidden; cursor:pointer;
* background: color-mix(light 32%, transparent) }
* .icon_avatar { cobre 100% (object-fit:cover) }
* .icon_avatar.empty { 32x32 centralizado -> fallback sem foto }
* .avatar:hover { scale(0.9) }
*
* Nota: o backdrop-filter: blur(16px) do CSS original não é replicado por
* elemento aqui (custaria uma ShaderEffectSource por avatar). Como o
* Main.qml já aplica um blur geral no background, o efeito visual final
* fica equivalente sem o custo extra de performance.
*
* @param source url da foto do usuário (AccountsService .face). Vazio
* cai automaticamente no fallback icon-user.svg
* @param selected realça a borda quando este é o usuário ativo
* ============================================================================
*/

Item {
    id: root

    property url source: ""
        property bool selected: false
            readonly property bool hasPhoto: source.toString().length > 0

                readonly property bool hovered: mouseArea.containsMouse

                    signal clicked()

                    readonly property color colorLight: "#F8F8F8"

                        width: 100
                        height: 100

                        scale: hovered ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

                        Rectangle {
                            id: badge
                            anchors.fill: parent
                            radius: 32
                            clip: true
                            antialiasing: true
                            color: Qt.rgba(1, 1, 1, 0.32)
                            border.width: root.selected ? 2 : 0
                            border.color: root.colorLight

                            Behavior on border.width { NumberAnimation { duration: 150 } }

                            Image {
                                anchors.fill: parent
                                visible: root.hasPhoto
                                source: root.hasPhoto ? root.source : ""
                                fillMode: Image.PreserveAspectCrop
                                antialiasing: true
                                asynchronous: true
                            }

                            Image {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                visible: !root.hasPhoto
                                source: "../assets/icon-user.svg"
                                sourceSize.width: width
                                sourceSize.height: height
                                antialiasing: true
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.clicked()
                        }
                    }