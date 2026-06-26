#!/usr/bin/env bash
#
# ProportionalResize.spoon — uninstaller
#
#   curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/uninstall.sh | bash
#
# Removes the loader lines it added to init.lua AND deletes the Spoon folder,
# leaving no trace. Your other Hammerspoon config is untouched.
#
set -euo pipefail

HS_DIR="$HOME/.hammerspoon"
SPOON_DIR="$HS_DIR/Spoons/ProportionalResize.spoon"
INIT="$HS_DIR/init.lua"

echo "==> Removing ProportionalResize.spoon"

# 1. strip the marker block from init.lua
if [ -f "$INIT" ] && grep -qF ">>> ProportionalResize >>>" "$INIT"; then
  sed -i '' '/>>> ProportionalResize >>>/,/<<< ProportionalResize <<</d' "$INIT"
  echo "==> Removed loader from $INIT"
fi

# 2. delete the Spoon folder
if [ -d "$SPOON_DIR" ]; then
  rm -rf "$SPOON_DIR"
  echo "==> Deleted $SPOON_DIR"
fi

# 3. reload Hammerspoon if we can
if command -v hs >/dev/null 2>&1; then
  hs -c "hs.reload()" >/dev/null 2>&1 && echo "==> Reloaded Hammerspoon" || true
else
  echo "==> Reload Hammerspoon (menu-bar icon -> Reload Config) to finish."
fi

echo
echo "✓ Uninstalled — no trace left."
