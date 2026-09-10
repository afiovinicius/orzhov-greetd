import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import "components"
import "services"

/*
* ============================================================================
* ORZHOV GREETER - SHELL.QML
* ============================================================================
* Fluxo de autenticação (Quickshell.Services.Greetd):
*
* 1. usuário escolhido -> Greetd.createSession(userName)
* 2. greetd/PAM pedem algo -> authMessage(message, error, responseRequired, echoResponse)
* responseRequired=true -> mostramos o campo e esperamos o usuário
* responseRequired=false -> só exibimos a mensagem e respondemos "" pra
* destravar o protocolo (alguns módulos PAM,
* como fprintd, mandam avisos sem esperar texto)
* 3. sucesso -> readyToLaunch() -> Greetd.launch(["sh", "-c", exec], [], true)
* 4. falha -> authFailure(message) -> mostra erro, permite tentar de novo
*
* Rodando fora do greetd (preview/teste): Greetd.available fica false,
* exibimos um aviso e a tela continua navegável pra visualizar o layout.
* ============================================================================
*/

PanelWindow {
    id: window

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    focusable: true

    readonly property string backgroundPath: {
        var env = Quickshell.env("ORZHOV_BACKGROUND")
        return (env && env !== "") ? env : Qt.resolvedUrl("assets/default-background.jpg")
    }

    property string screenState: Users.list.length > 1 ? "select" : "password"
        property string activeUser: Users.list.length === 1 ? Users.list[0].name : ""
            property string activeUserRealName: ""
                property url activeUserIcon: ""
                    property bool authError: false
                        property string authErrorMessage: ""

                            property string promptMessage: ""
                                property bool promptEcho: false
                                    property bool waitingResponse: false

                                        function pickUser(user)
                                        {
                                            activeUser = user.name
                                            activeUserRealName = user.realName
                                            activeUserIcon = user.icon
                                            authError = false
                                            screenState = "password"
                                            if (Greetd.available) Greetd.createSession(user.name)
                                                }

                                            function backToSelection()
                                            {
                                                if (Greetd.available && Greetd.state !== GreetdState.Inactive)
                                                {
                                                    Greetd.cancelSession()
                                                }
                                                screenState = "select"
                                                authError = false
                                            }

                                            function submitResponse(text)
                                            {
                                                waitingResponse = false
                                                if (Greetd.available) Greetd.respond(text)
                                                    }

                                                Connections {
                                                    target: Greetd

                                                    function onAuthMessage(message, error, responseRequired, echoResponse)
                                                    {
                                                        promptMessage = message
                                                        promptEcho = echoResponse
                                                        authError = !!error

                                                        if (responseRequired)
                                                        {
                                                            waitingResponse = true
                                                            loginForm.clearAndFocus()
                                                        } else {
                                                        waitingResponse = false
                                                        Greetd.respond("")
                                                    }
                                                }

                                                function onAuthFailure(message)
                                                {
                                                    authError = true
                                                    authErrorMessage = message !== "" ? message : Translations.current.wrongPassword
                                                    waitingResponse = false
                                                    loginForm.clearAndFocus()
                                                    loginForm.triggerShake()
                                                }

                                                function onReadyToLaunch()
                                                {
                                                    var session = Sessions.current
                                                    var execCmd = session ? session.exec: (Quickshell.env("SHELL") || "/bin/sh")
                                                    Greetd.launch(["sh", "-c", execCmd], [], true)
                                                }
                                            }

                                            Image {
                                                id: background
                                                anchors.fill: parent
                                                source: window.backgroundPath
                                                fillMode: Image.PreserveAspectCrop
                                                asynchronous: true
                                                cache: true
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                color: Qt.rgba(48 / 255, 48 / 255, 54 / 255, 0.55)
                                            }

                                            Rectangle {
                                                visible: !Greetd.available
                                                anchors.top: parent.top
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.topMargin: 16
                                                radius: 8
                                                antialiasing: true
                                                color: "#E5484D"
                                                width: warnText.implicitWidth + 24
                                                height: 32

                                                Text {
                                                    id: warnText
                                                    anchors.centerIn: parent
                                                    text: Translations.current.greetdUnavailable
                                                    color: "#F8F8F8"
                                                    font.family: "Inter"
                                                    font.pixelSize: 12
                                                }
                                            }

                                            Column {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.top: parent.top
                                                anchors.topMargin: 132
                                                spacing: 16

                                                ClockWidget { anchors.horizontalCenter: parent.horizontalCenter }
                                                CalendarWidget { anchors.horizontalCenter: parent.horizontalCenter }
                                            }

                                            Item {
                                                anchors.centerIn: parent
                                                width: parent.width
                                                height: 320

                                                Row {
                                                    id: userGrid
                                                    anchors.centerIn: parent
                                                    spacing: 24
                                                    opacity: window.screenState === "select" ? 1 : 0
                                                    visible: opacity > 0
                                                    enabled: window.screenState === "select"
                                                    Behavior on opacity { NumberAnimation { duration: 260 } }

                                                    Repeater {
                                                        model: Users.list
                                                        delegate: Card {
                                                            userName: modelData.name
                                                            displayName: modelData.realName
                                                            avatarSource: modelData.icon
                                                            onClicked: window.pickUser(modelData)
                                                        }
                                                    }
                                                }

                                                Column {
                                                    id: loginForm
                                                    anchors.centerIn: parent
                                                    spacing: 24
                                                    width: 320
                                                    opacity: window.screenState === "password" ? 1 : 0
                                                    visible: opacity > 0
                                                    enabled: window.screenState === "password"
                                                    Behavior on opacity { NumberAnimation { duration: 260 } }

                                                    function clearAndFocus()
                                                    {
                                                        passwordInput.text = ""
                                                        Qt.callLater(function() { passwordInput.forceFocus() })
                                                    }
                                                    function triggerShake()
                                                    { shakeAnim.start() }

                                                        Avatar {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            source: window.activeUserIcon
                                                            selected: true
                                                        }

                                                        Text {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: window.activeUserRealName !== "" ? window.activeUserRealName : window.activeUser
                                                            color: "#F8F8F8"
                                                            font.family: "Inter"
                                                            font.pixelSize: 14
                                                            font.weight: Font.Medium
                                                        }

                                                        Item {
                                                            id: shakeWrapper
                                                            width: parent.width
                                                            height: passwordInput.height

                                                            SequentialAnimation {
                                                                id: shakeAnim
                                                                NumberAnimation { target: shakeWrapper; property: "x"; to: shakeWrapper.x - 10; duration: 45 }
                                                                NumberAnimation { target: shakeWrapper; property: "x"; to: shakeWrapper.x + 10; duration: 45 }
                                                                NumberAnimation { target: shakeWrapper; property: "x"; to: shakeWrapper.x - 6; duration: 45 }
                                                                NumberAnimation { target: shakeWrapper; property: "x"; to: shakeWrapper.x; duration: 45 }
                                                            }

                                                            Input {
                                                                id: passwordInput
                                                                anchors.centerIn: parent
                                                                width: parent.width
                                                                isPassword: !window.promptEcho
                                                                showToggle: !window.promptEcho
                                                                placeholder: window.promptMessage !== "" ? window.promptMessage : Translations.current.typePassword
                                                                toggleLabel: Translations.current.password
                                                                onAccepted: loginButton.trigger()
                                                            }
                                                        }

                                                        Text {
                                                            visible: window.authError
                                                            text: window.authErrorMessage !== "" ? window.authErrorMessage : Translations.current.wrongPassword
                                                            color: "#E5484D"
                                                            font.family: "Inter"
                                                            font.pixelSize: 12
                                                            width: parent.width
                                                            horizontalAlignment: Text.AlignHCenter
                                                        }

                                                        Button {
                                                            id: loginButton
                                                            function trigger()
                                                            { window.submitResponse(passwordInput.text) }
                                                                text: window.waitingResponse ? Translations.current.login : Translations.current.loggingIn
                                                                fullWidth: true
                                                                enabledState: window.waitingResponse
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                onClicked: trigger()
                                                            }

                                                            Button {
                                                                visible: Users.list.length > 1
                                                                text: Translations.current.otherUser
                                                                fullWidth: true
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                onClicked: window.backToSelection()
                                                            }
                                                        }
                                                    }

                                                    Row {
                                                        anchors.left: parent.left
                                                        anchors.bottom: parent.bottom
                                                        anchors.margins: 48
                                                        spacing: 8

                                                        Repeater {
                                                            model: Sessions.list
                                                            delegate: Rectangle {
                                                                width: 160
                                                                height: 40
                                                                radius: 14
                                                                antialiasing: true
                                                                visible: index === Sessions.currentIndex
                                                                color: Qt.rgba(1, 1, 1, 0.14)
                                                                Text {
                                                                    anchors.centerIn: parent
                                                                    text: modelData.name
                                                                    color: "#F8F8F8"
                                                                    font.family: "Inter"
                                                                    font.pixelSize: 14
                                                                }
                                                                MouseArea {
                                                                    anchors.fill: parent
                                                                    cursorShape: Qt.PointingHandCursor
                                                                    onClicked: Sessions.select((Sessions.currentIndex + 1) % Sessions.list.length)
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Row {
                                                        anchors.right: parent.right
                                                        anchors.bottom: parent.bottom
                                                        anchors.margins: 48
                                                        spacing: 12

                                                        Button {
                                                            text: Translations.current.sleep
                                                            onClicked: powerProc.exec(["systemctl", "suspend"])
                                                        }
                                                        Button {
                                                            text: Translations.current.reboot
                                                            onClicked: powerProc.exec(["systemctl", "reboot"])
                                                        }
                                                        Button {
                                                            text: Translations.current.shutdown
                                                            onClicked: powerProc.exec(["systemctl", "poweroff"])
                                                        }
                                                    }

                                                    Process {
                                                        id: powerProc
                                                        function exec(cmd)
                                                        { command = cmd; running = true }
                                                        }
                                                    }