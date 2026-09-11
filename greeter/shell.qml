import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd
import "components"
import "services"

PanelWindow {
    id: window

    anchors { top: true; bottom: true; left: true; right: true }
    color: "black"
    focusable: true

    Component.onCompleted: {
        if (this.WlrLayershell != null)
        {
            this.WlrLayershell.layer = WlrLayer.Overlay
            this.WlrLayershell.namespace = "orzhov-greeter"
        }
        if (Users.loaded && Users.list.length === 1)
        {
            window.pickUser(Users.list[0])
        }
    }

    readonly property string backgroundPath: {
        var env = Quickshell.env("ORZHOV_BACKGROUND")
        return (env && env !== "") ? env : Qt.resolvedUrl("/etc/xdg/quickshell/orzhov-greeter/assets/default-background.jpg")
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
                                                waitingResponse = true
                                                authError = false
                                                if (Greetd.available) Greetd.respond(text)
                                                    }

                                                Connections {
                                                    target: Users
                                                    function onLoadedChanged()
                                                    {
                                                        if (Users.loaded && Users.list.length === 1)
                                                        {
                                                            window.pickUser(Users.list[0])
                                                        }
                                                    }
                                                }

                                                Connections {
                                                    target: Greetd

                                                    function onAuthMessage(message, error, responseRequired, echoResponse)
                                                    {
                                                        promptMessage = message
                                                        promptEcho = echoResponse
                                                        authError = !!error
                                                        waitingResponse = false

                                                        if (responseRequired)
                                                        {
                                                            loginForm.clearAndFocus()
                                                        } else {
                                                        Greetd.respond("")
                                                    }
                                                }

                                                function onAuthFailure(message)
                                                {
                                                    authError = true
                                                    authErrorMessage = message !== "" ? message : Translations.current.wrongPassword
                                                    waitingResponse = false
                                                    promptMessage = ""
                                                    loginForm.clearAndFocus()
                                                    loginForm.triggerShake()

                                                    if (Greetd.available && window.activeUser !== "")
                                                    {
                                                        Qt.callLater(function() {
                                                        Greetd.createSession(window.activeUser)
                                                    })
                                                }
                                            }

                                            function onReadyToLaunch()
                                            {
                                                var session = Sessions.current
                                                if (!session) return

                                                var cmd = Array.isArray(session.exec) ? session.exec: ["sh", "-c", session.exec]
                                                var env = session.env || []

                                                Greetd.launch(cmd, env, true)
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

                                        FastBlur {
                                            anchors.fill: background
                                            source: background
                                            radius: 32
                                            transparentBorder: false
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
                                                font.pixelSize: 14
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
                                                        font.pixelSize: 16
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
                                                        font.pixelSize: 14
                                                        width: parent.width
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }

                                                    Button {
                                                        id: loginButton
                                                        function trigger()
                                                        { window.submitResponse(passwordInput.text) }
                                                            text: window.waitingResponse ? Translations.current.loggingIn : Translations.current.login
                                                            fullWidth: true
                                                            enabled: !window.waitingResponse
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
                                                    spacing: 12

                                                    Dropdown {
                                                        id: sessionDropdown
                                                        // width: 180
                                                        icon: "../assets/icon-session.svg"
                                                        model: {
                                                            var names = []
                                                            for (var i = 0; i < Sessions.list.length; i++) {
                                                                names.push(Sessions.list[i].name)
                                                            }
                                                            return names
                                                        }
                                                        currentIndex: Sessions.currentIndex
                                                        onActivated: (index) => {
                                                        Sessions.select(index)
                                                    }
                                                }

                                                // LayoutKbd
                                            }

                                            Row {
                                                anchors.right: parent.right
                                                anchors.bottom: parent.bottom
                                                anchors.margins: 48
                                                spacing: 12

                                                Dropdown {
                                                    id: powerDropdown
                                                    // width: 150
                                                    icon: "../assets/icon-config.svg"
                                                    model: [Translations.current.sleep, Translations.current.reboot, Translations.current.shutdown]
                                                    currentIndex: 0
                                                    onActivated: (index) => {
                                                    if (index === 0) powerProc.exec(["systemctl", "suspend"])
                                                        else if (index === 1) powerProc.exec(["systemctl", "reboot"])
                                                    else if (index === 2) powerProc.exec(["systemctl", "poweroff"])
                                                    }
                                                }
                                            }

                                            Process {
                                                id: powerProc
                                                function exec(cmd)
                                                {
                                                    command = cmd
                                                    running = true
                                                }
                                            }
                                        }