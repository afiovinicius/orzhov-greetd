pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/*
 * ============================================================================
 * ORZHOV GREETER - SERVIÇO: USERS
 * ============================================================================
 * O greetd não expõe uma lista de usuários pronta (diferente do userModel
 * do SDDM), então lemos direto do NSS via `getent passwd`.
 *
 * Regras:
 *   - UID entre 1000 e 59999 (convenção de "usuário real", fora de
 *     serviços do sistema)
 *   - shell não pode ser nologin/false
 *   - avatar: usa $HOME/.face quando o arquivo existe, senão fica vazio
 *     (o componente Avatar.qml já cai pro icon-user.svg sozinho)
 *
 * list -> [{ name, realName, icon }]
 * ============================================================================
 */
QtObject {
    id: root

    property var list: []
    property bool loaded: false

    function reload() { proc.running = true }

    Process {
        id: proc
        running: false
        command: ["sh", "-c", "getent passwd | awk -F: '($3>=1000 && $3<60000 && $7 !~ /nologin|\\/false$/){print $1\"|\"$5\"|\"$6}' | while IFS='|' read -r name real home; do face=\"$home/.face\"; [ -f \"$face\" ] && icon=\"$face\" || icon=''; printf '%s|%s|%s\\n' \"$name\" \"$real\" \"$icon\"; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                var raw = this.text.trim()
                var users = []

                if (raw !== "") {
                    var lines = raw.split("\n")
                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split("|")
                        var name = parts[0] || ""
                        if (name === "") continue
                        var realName = (parts[1] || "").split(",")[0]
                        var icon = parts[2] || ""
                        users.push({
                            name: name,
                            realName: realName !== "" ? realName : name,
                            icon: icon !== "" ? "file://" + icon : ""
                        })
                    }
                }

                root.list = users
                root.loaded = true
            }
        }
    }

    Component.onCompleted: reload()
}
