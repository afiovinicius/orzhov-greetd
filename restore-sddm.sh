#!/bin/sh
# ==============================================================================
# ORZHOV GREETER - RESTAURAR SDDM
# ==============================================================================
# Se algo der errado com o greetd ou você ficar preso num TTY de tela preta,
# basta abrir um TTY (Ctrl + Alt + F2) e rodar este script.
# ==============================================================================

set -e

log()  { printf '\033[1;36m[orzhov]\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m[orzhov]\033[0m %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root (sudo ./restore-sddm.sh)"

log "Desabilitando greetd..."
systemctl disable greetd.service 2>/dev/null || true

log "Habilitando sddm..."
# Habilita o sddm usando --force para recriar o link do display-manager.service
systemctl enable sddm.service --force

log "Pronto! O SDDM foi restaurado como o seu Display Manager padrão."
log "Você pode reiniciar o computador ou iniciar o SDDM imediatamente rodando:"
log "  sudo systemctl start sddm.service"
