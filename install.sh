#!/bin/sh
# ==============================================================================
# ORZHOV GREETER - INSTALADOR
# ==============================================================================
# Uso:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/afiovinicius/orzhov-greetd/main/install.sh)"
#
# O que este script faz:
#   1. Confere dependências (greetd, cage, quickshell)
#   2. Copia o launcher para /usr/local/bin
#   3. Copia a config tela do greeter para /etc/xdg/orzhov-greeter
#   4. Faz backup do /etc/greetd/config.toml atual (se existir) e aplica o novo
#   5. Garante o usuário `greeter` e habilita o serviço greetd
#
# Funciona independente do DE/WM que você usa no dia a dia (KDE, Hyprland,
# GNOME...) - o greeter roda isolado, antes de qualquer sessão começar.
# ==============================================================================

set -e

REPO_RAW="https://raw.githubusercontent.com/afiovinicius/orzhov-greetd/main"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

log()  { printf '\033[1;36m[orzhov]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[orzhov]\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m[orzhov]\033[0m %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Rode como root (sudo sh -c \"...\")"

# --- 1. dependências ---------------------------------------------------
log "Checando dependências..."
missing=""
for bin in greetd cage quickshell; do
  command -v "$bin" >/dev/null 2>&1 || missing="$missing $bin"
done

if [ -n "$missing" ]; then
  warn "Faltando:$missing"
  if command -v pacman >/dev/null 2>&1; then
    log "Detectado pacman, instalando dependências..."
    sudo pacman -S --needed --noconfirm greetd cage quickshell || die "Falha instalando dependências"
  else
    die "Instale manualmente:$missing (greetd, cage e quickshell) e rode o script de novo."
  fi
fi

# --- 2. baixa e instala os arquivos do tema -----------------------------
log "Baixando orzhov-greeter..."
git clone --depth 1 "${ORZHOV_REPO:-https://github.com/afiovinicius/orzhov-greetd.git}" "$TMP_DIR/src" \
  || die "Falha ao clonar o repositório"

log "Instalando launcher em /usr/local/bin..."
install -Dm755 "$TMP_DIR/src/bin/orzhov-greeter-launcher" /usr/local/bin/orzhov-greeter-launcher

log "Instalando config do QuickShell em /etc/xdg/orzhov-greeter..."
rm -rf /etc/xdg/quickshell/orzhov-greeter
mkdir -p /etc/xdg/quickshell
cp -r "$TMP_DIR/src/greeter" /etc/xdg/quickshell/orzhov-greeter
chmod -R a+rX /etc/xdg/quickshell/orzhov-greeter

# --- 3. usuário greeter --------------------------------------------------
if ! id greeter >/dev/null 2>&1; then
  log "Criando usuário 'greeter'..."
  useradd -M -G input render video greeter
else
  log "Usuário 'greeter' já existe. Atualizando grupos de acesso..."
  usermod -aG video,render,input greeter
fi

# --- 4. config.toml do greetd (com backup) -------------------------------
mkdir -p /etc/greetd
if [ -f /etc/greetd/config.toml ]; then
  cp /etc/greetd/config.toml "/etc/greetd/config.toml.bak.$(date +%s)"
  log "Backup do config.toml anterior criado."
fi
install -Dm644 "$TMP_DIR/src/etc/greetd/config.toml" /etc/greetd/config.toml
install -Dm644 "$TMP_DIR/src/etc/greetd/orzhov.env" /etc/greetd/orzhov.env
chown -R greeter:greeter /etc/greetd

# --- 5. habilita o serviço -------------------------------------------------
# Desativa qualquer DM ativo (sddm, gdm, lightdm)
log "Desabilitando o Display Manager atual (ex: SDDM)..."
CURRENT_DM=$(readlink /etc/systemd/system/display-manager.service 2>/dev/null || true)
if [ -n "$CURRENT_DM" ]; then
  DM_BASENAME=$(basename "$CURRENT_DM")
  log "DM detectado: $DM_BASENAME"
  systemctl disable "$DM_BASENAME" 2>/dev/null || true
fi
log "Habilitando greetd.service..."
systemctl enable greetd.service --force >/dev/null

log "Pronto! Instalação concluída com sucesso."
log "O Greetd agora é o seu gerenciador de login padrão."
log "Reinicie o sistema para ver o novo login screen."
log "Pra depurar sem reiniciar: sudo -u greeter cage -- quickshell -c orzhov-greeter"
