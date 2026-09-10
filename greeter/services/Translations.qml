pragma Singleton
import QtQuick

/*
 * ============================================================================
 * ORZHOV GREETER - i18n
 * ============================================================================
 * Segue o locale do sistema (Qt.locale()), igual definido no tema original.
 * Sem seletor manual: pt_BR no sistema -> textos em pt_BR, qualquer outro
 * locale cai pro inglês.
 * ============================================================================
 */
QtObject {
    readonly property string localeName: Qt.locale().name

    readonly property var en: ({
        password:      "Password",
        typePassword:  "Type your password",
        login:         "Login",
        otherUser:     "Other User",
        session:       "Session",
        sleep:         "Sleep",
        reboot:        "Reboot",
        shutdown:      "Shutdown",
        wrongPassword: "Incorrect password, try again",
        loggingIn:     "Signing in…",
        greetdUnavailable: "greetd not detected — running in preview mode"
    })

    readonly property var ptBR: ({
        password:      "Senha",
        typePassword:  "Digite sua senha",
        login:         "Entrar",
        otherUser:     "Outro usuário",
        session:       "Sessão",
        sleep:         "Repouso",
        reboot:        "Reiniciar",
        shutdown:      "Desligar",
        wrongPassword: "Senha incorreta, tente novamente",
        loggingIn:     "Entrando…",
        greetdUnavailable: "greetd não detectado — rodando em modo de pré-visualização"
    })

    readonly property var current: localeName.toLowerCase().indexOf("pt") === 0 ? ptBR : en
}
