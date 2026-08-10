#!/bin/bash
set -euo pipefail

# omarchy-config-verify installer
# Copies the command into ~/.local/bin and wires up the post-update hook so it
# runs automatically after every `omarchy update`.

PROJECT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT_SRC="$PROJECT_DIR/omarchy-config-verify"
HOOK_SRC="$PROJECT_DIR/hooks/post-update/verify-config.hook"
BIN_DIR="$HOME/.local/bin"
HOOK_TYPE="post-update"

command -v omarchy &>/dev/null || {
  echo "warning: 'omarchy' CLI not found. This tool targets Omarchy systems." >&2
}

echo "Installing omarchy-config-verify to $BIN_DIR..."
mkdir -p "$BIN_DIR"
install -m 755 "$SCRIPT_SRC" "$BIN_DIR/omarchy-config-verify"
echo "  installed: $BIN_DIR/omarchy-config-verify"

echo "Installing $HOOK_TYPE hook..."
if command -v omarchy &>/dev/null && omarchy hook install --help &>/dev/null 2>&1; then
  omarchy hook install "$HOOK_TYPE" "$HOOK_SRC"
else
  HOOK_DIR="$HOME/.config/omarchy/hooks/$HOOK_TYPE.d"
  mkdir -p "$HOOK_DIR"
  install -m 755 "$HOOK_SRC" "$HOOK_DIR/$(basename "$HOOK_SRC")"
  echo "  installed: $HOOK_DIR/$(basename "$HOOK_SRC")"
fi

echo
echo "Done. Next steps:"
echo "  omarchy-config-verify              # check current state (report only)"
echo "  omarchy-config-verify --apply      # restore anything an update changed"
echo "  omarchy update                     # auto-verifies via the post-update hook"
echo
echo "Note: the dotfiles repo defaults to ~/dotfiles. Point elsewhere with"
echo "DOTFILES_DIR=/path/to/repo."
