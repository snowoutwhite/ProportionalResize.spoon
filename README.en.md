# Proportional Window Resizing for macOS

[中文](README.md) · [English](README.en.md)

A Hammerspoon tool that adjusts a window's size and position after you drag it to another display and release the mouse. It maps the window's relative frame to the destination display's usable area, reducing manual resizing in multi-monitor workflows.

Designed for windowed workflows across displays with different usable dimensions, such as a Mac's built-in display and an external monitor. The plugin and installation directory remain named `ProportionalResize.spoon`.

## Demo

![A window is resized and repositioned after being dragged to another display](assets/demo.gif)

## Features

| Module | Behavior |
| --- | --- |
| Resizing | Maps width and height as separate fractions of each display's usable area. |
| Positioning | Maps the relative position and clamps the requested frame to the destination area. |
| Trigger | Records the window on mouse-down and checks for a screen change on mouse-up; no resizing during the drag. |
| Configuration | Supports excluded applications and a configurable animation duration. |
| Installation | Scripted installation, updates and removal, plus manual installation. |

Workflow: grab a window → drag it to another display → release → automatically resize and reposition.

Proportional resizing preserves each dimension's share of the usable display area, not necessarily the window's aspect ratio when displays have different aspect ratios. Application minimum sizes or other window constraints may affect the final result. The tool does not change font sizes or in-app page zoom.

## Technology

| Module | Technology |
| --- | --- |
| Window logic | Lua, Hammerspoon Spoon |
| Events and windows | `hs.eventtap`, `hs.window`, usable screen-frame mapping |
| Installation and removal | Bash, Git |

## Project structure

```text
.
├── init.lua          # Mouse events and cross-display frame mapping
├── install.sh        # Install or update and add loader configuration
├── uninstall.sh      # Remove the plugin and marked configuration block
├── assets/demo.gif
├── README.md
└── README.en.md
```

## Requirements

- macOS with at least two displays.
- [Hammerspoon](https://www.hammerspoon.org/) with Accessibility permission.
- Git for scripted installation; the installer checks `/Applications/Hammerspoon.app`.

```sh
brew install --cask hammerspoon
```

Enable Hammerspoon in System Settings → Privacy & Security → Accessibility.

## Installation

### Scripted installation

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/install.sh | bash
```

The script installs to `~/.hammerspoon/Spoons/ProportionalResize.spoon` and adds a marked loader block to `~/.hammerspoon/init.lua`. An existing Git checkout is updated with a fast-forward pull. An existing marked block is not added again.

If the `hs` command is available, the script attempts to reload Hammerspoon. Otherwise, choose **Reload Config** from the Hammerspoon menu.

### Manual installation

```sh
git clone https://github.com/snowoutwhite/ProportionalResize.spoon.git \
  ~/.hammerspoon/Spoons/ProportionalResize.spoon
```

Add the following to `~/.hammerspoon/init.lua`, then reload:

```lua
-- >>> ProportionalResize >>>
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize:start()
-- <<< ProportionalResize <<<
```

## Configuration

Set options before `start()`, then reload:

```lua
-- >>> ProportionalResize >>>
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize.animationDuration = 0.1
spoon.ProportionalResize.excludedApps = { "iTerm2", "Terminal" }
spoon.ProportionalResize:start()
-- <<< ProportionalResize <<<
```

| Option | Default | Meaning |
| --- | --- | --- |
| `animationDuration` | `0` | Animation duration in seconds; `0` applies the frame immediately. |
| `excludedApps` | `{}` | Application names to exclude. |

## How it works

1. On mouse-down, find the topmost standard window under the pointer and record its ID, screen ID and relative frame within the screen's usable area.
2. On mouse-up, check whether that same window is now on another display. Do nothing if its screen has not changed.
3. Map the stored relative frame to the destination screen, constrain the requested bounds and apply it to the window.

The tool targets ordinary windows dragged with the mouse. It does not enter full screen, create Spaces, or react to window moves performed solely with keyboard shortcuts or other tools.

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/uninstall.sh | bash
```

Removes the plugin directory and the marked block in `init.lua`, including any custom options inside that block. Reload Hammerspoon afterward.

## License

[MIT](LICENSE)
