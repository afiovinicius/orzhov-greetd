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
* Lemos Name= e Exec= de cada um com grep -H (prefixa o path), agrupamos
* por arquivo em JS e guardamos o tipo (wayland/x11) pra decidir depois
* como lançar a sessão.
*
* list -> [{ name, exec, type }]
*
* NOTA: sessões X11 (type "x11") ainda não têm o wrapper Xorg/xinit
* embutido no launch() do Main.qml — funcionam nativamente as sessões
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

                    // Declarando o Process como uma propriedade
                    property Process proc: Process {
                        running: false
                        command: ["sh", "-c", "grep -H -E '^(Name|Exec)=' /usr/share/wayland-sessions/*.desktop /usr/share/xsessions/*.desktop 2>/dev/null"]

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

                                        sessions.push({
                                        name: entry.Name,
                                        exec: entry.Exec,
                                        type: order[j].indexOf("wayland-sessions") >= 0 ? "wayland" : "x11"
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