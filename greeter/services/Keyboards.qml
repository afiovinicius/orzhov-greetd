pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/*
* ============================================================================
* ORZHOV GREETER - SERVIÇO: KEYBOARDS
* ============================================================================
* Lista os layouts de teclado disponíveis no sistema lendo a base XKB
* (/usr/share/X11/xkb/rules/base.lst) - a mesma fonte que KDE, GNOME etc
* usam pros seus próprios seletores de layout. Formato do arquivo:
*
* ! layout
* us English (US)
* br Portuguese (Brazil)
* ...
* ! variant
* ...
*
* list -> [{ code, name }] (ex: { code: "br", name: "Portuguese (Brazil)" })
*
* IMPORTANTE - limitação atual: selecionar um layout aqui só atualiza
* `Keyboards.currentIndex`, ainda não troca o teclado ativo em tempo real.
* O labwc lê o layout XKB na inicialização (via XKB_DEFAULT_LAYOUT, que
* o orzhov.env já exporta) - não existe um IPC padrão tipo `hyprctl`/
* `swaymsg` pro labwc pra trocar isso a quente. O jeito correto de
* aplicar depois de selecionado é persistir a escolha (ex: reescrever
* XKB_DEFAULT_LAYOUT no orzhov.env) e reiniciar o compositor - ainda não
* implementado aqui de propósito, pra não inventar um mecanismo não
* verificado.
* ============================================================================
*/
QtObject {
    id: root

    property var list: []
    property int currentIndex: 0
        readonly property var current: list.length > 0 ? list[currentIndex] : null
            property bool loaded: false

                function reload()
                { proc.running = true }
                    function select(index)
                    {
                        if (index >= 0 && index < list.length) currentIndex = index
                    }

                    property Process proc: Process {
                        running: false
                        // extrai só a seção "! layout" do base.lst: código + descrição
                        command: ["sh", "-c",
                        "awk '/^! layout/{f=1;next} /^!/{f=0} f && NF {code=$1; $1=\"\"; sub(/^[ \\t]+/, \"\"); print code\"|\"$0}' /usr/share/X11/xkb/rules/base.lst 2>/dev/null"]

                        stdout: StdioCollector {
                            onStreamFinished: {
                                var raw = this.text.trim()
                                var layouts = []
                                var seen = {}

                                    if (raw !== "")
                                    {
                                        var lines = raw.split("\n")
                                        for (var i = 0; i < lines.length; i++) {
                                            var sep = lines[i].indexOf("|")
                                            if (sep < 0) continue

                                            var code = lines[i].substring(0, sep)
                                            var name = lines[i].substring(sep + 1)
                                            if (code === "" || seen[code]) continue

                                            seen[code] = true
                                            layouts.push({ code: code, name: name })
                                        }
                                    }

                                    layouts.sort(function(a, b) {
                                    return a.name < b.name ? -1: (a.name > b.name ? 1 : 0))
                                })

                                // fallback caso base.lst não exista (xkeyboard-config ausente)
                                if (layouts.length === 0)
                                {
                                    layouts = [{ code: "us", name: "English (US)" }]
                                }

                                root.list = layouts

                                // pré-seleciona o layout ativo (o mesmo que o orzhov.env exportou)
                                var active = Quickshell.env("XKB_DEFAULT_LAYOUT") || "us"
                                for (var j = 0; j < layouts.length; j++) {
                                    if (layouts[j].code === active)
                                    {
                                        root.currentIndex = j
                                        break
                                    }
                                }

                                root.loaded = true
                            }
                        }
                    }

                    Component.onCompleted: reload()
                }
