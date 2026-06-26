#!/usr/bin/env bash
#
# ProportionalResize.spoon — installer
#
#   curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/install.sh | bash
#
# Clones the Spoon into ~/.hammerspoon/Spoons, wires it into init.lua
# (idempotently, between markers) and reloads Hammerspoon.
#
set -euo pipefail

REPO_URL="https://github.com/snowoutwhite/ProportionalResize.spoon.git"
HS_DIR="$HOME/.hammerspoon"
SPOON_DIR="$HS_DIR/Spoons/ProportionalResize.spoon"
INIT="$HS_DIR/init.lua"
MARK_BEGIN="-- >>> ProportionalResize >>>"
MARK_END="-- <<< ProportionalResize <<<"

echo "==> Installing ProportionalResize.spoon"

if [ ! -d "/Applications/Hammerspoon.app" ]; then
  echo "!! Hammerspoon is not installed. Install it first:"
  echo "     brew install --cask hammerspoon"
  exit 1
fi

# 1. fetch (or update) the Spoon
mkdir -p "$HS_DIR/Spoons"
if [ -d "$SPOON_DIR/.git" ]; then
  echo "==> Updating existing copy"
  git -C "$SPOON_DIR" pull --ff-only --quiet
else
  rm -rf "$SPOON_DIR"
  git clone --depth 1 --quiet "$REPO_URL" "$SPOON_DIR"
fi

# 2. wire it into init.lua (only once)
touch "$INIT"
if grep -qF "$MARK_BEGIN" "$INIT"; then
  echo "==> init.lua already loads the Spoon"
else
  {
    printf '\n%s\n'                       "$MARK_BEGIN"
    printf 'hs.loadSpoon("ProportionalResize")\n'
    printf 'spoon.ProportionalResize:start()\n'
    printf '%s\n'                         "$MARK_END"
  } >> "$INIT"
  echo "==> Added loader to $INIT"
fi

# 3. reload Hammerspoon if we can
if command -v hs >/dev/null 2>&1; then
  hs -c "hs.reload()" >/dev/null 2>&1 && echo "==> Reloaded Hammerspoon" || true
else
  echo "==> Reload Hammerspoon (menu-bar icon -> Reload Config) to activate."
fi

echo
echo "✓ Installed. One-time step: grant Accessibility permission to Hammerspoon"
echo "  (System Settings -> Privacy & Security -> Accessibility -> enable Hammerspoon)."
