pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/*
* ============================================================================
* ORZHOV GREETER - SERVIÇO: SESSIONS
* ============================================================================
* O greetd também não expõe sessionModel. As sessões instaladas no sistema
* ficam em arquivos .desktop padrão:
*
* /usr/share/wayland-sessions/*.desktop -> Hyprland, KDE Plasma (Wayland)...
* /usr/share/xsessions/*.desktop -> KDE Plasma (X11), i3...
*
* Lemos Name=, Exec= e DesktopNames= de cada um com grep -H (prefixa o
* path), agrupamos por arquivo em JS e guardamos o tipo (wayland/x11).
*
* list -> [{ name, exec, type, env }]
*
* O `env` é o pulo do gato: sem XDG_CURRENT_DESKTOP/XDG_SESSION_DESKTOP
* setados, DEs "pesados" como o Plasma não conseguem disparar os targets
* systemd/dbus certos e a sessão nunca fica usável (o Hyprland não sente
* falta disso por ser autocontido - por isso "só funciona no Hyprland").
* Normalmente é o display manager quem injeta essas variáveis a partir do
* DesktopNames= do .desktop; como o greetd não faz isso sozinho, fazemos
* aqui.
*
* NOTA: sessões X11 (type "x11") ainda não têm o wrapper Xorg/xinit
* embutido no launch() do shell.qml — funcionam nativamente as sessões
* Wayland (Hyprland, Plasma Wayland, GNOME Wayland etc). Se precisar de
* X11 também, dá pra adicionar um wrapper `startx` depois.
* ============================================================================
*/

QtObject {
    id: root

    property var list: []
    property int currentIndex: 0
        property bool loaded: false
            readonly property var current: list.length > 0 && currentIndex >= 0 && currentIndex < list.length ? list[currentIndex] : null

                function reload()
                { proc.running = true }
                    function select(index)
                    {
                        if (index >= 0 && index < list.length) currentIndex = index
                    }

                    property Process proc: Process {
                        running: false
                        command: ["sh", "-c", "grep -H -E '^(Name|Exec|DesktopNames)=' /usr/share/wayland-sessions/*.desktop /usr/share/xsessions/*.desktop 2>/dev/null"]

                        stdout: StdioCollector {
                            onStreamFinished: {
                                var byPath = {}
                                    var order = []
                                    var lines = this.text.split("\n")

                                    for (var i = 0; i < lines.length; i++) {
                                        var line = lines[i]
                                        if (line === "") continue

                                        var sep = line.indexOf(":")
                                        if (sep < 0) continue

                                        var path = line.substring(0, sep)
                                        var rest = line.substring(sep + 1)
                                        var eq = rest.indexOf("=")
                                        if (eq < 0) continue

                                        var key = rest.substring(0, eq)
                                        var value = rest.substring(eq + 1)

                                        if (!byPath[path])
                                        {
                                            byPath[path] = { path: path }
                                            order.push(path)
                                        }
                                        byPath[path][key] = value
                                    }

                                    var sessions = []
                                    for (var j = 0; j < order.length; j++) {
                                        var entry = byPath[order[j]]
                                        if (!entry.Name || !entry.Exec) continue

                                        var type = order[j].indexOf("wayland-sessions") >= 0 ? "wayland" : "x11"

                                        var desktopNames = entry.DesktopNames || ""
                                        var primaryDesktop = desktopNames.split(":")[0] || entry.Name

                                        var env = [
                                        "XDG_SESSION_TYPE=" + type,
                                    ]
                                    if (desktopNames !== "")
                                    {
                                        env.push("XDG_CURRENT_DESKTOP=" + desktopNames)
                                        env.push("XDG_SESSION_DESKTOP=" + primaryDesktop)
                                        env.push("DESKTOP_SESSION=" + primaryDesktop.toLowerCase())
                                    }

                                    sessions.push({
                                    name: entry.Name,
                                    exec: entry.Exec,
                                    type: type,
                                    env: env
                                })
                            }

                            root.list = sessions
                            root.currentIndex = 0
                            root.loaded = true
                        }
                    }
                }

                Component.onCompleted: reload()
            }