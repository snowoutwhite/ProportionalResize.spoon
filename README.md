# ProportionalResize.spoon

A [Hammerspoon](https://www.hammerspoon.org/) Spoon that keeps a window's
**relative size and position** when you drag it to another display.

*[English](#english) · [中文](#中文)*

---

## English

### The problem

On a multi-monitor setup, displays often use different *scaled (effective)
resolutions* — e.g. a 27″ external at "looks like 1920×1080" next to a 13″
laptop scaled to "looks like 1280×832" so its text stays comfortably large.

When you drag a window between them, macOS keeps the window's **point size
constant**. So a window sized for the big, low-density display **overflows** the
smaller one (and a window from the small display looks tiny on the big one). You
end up resizing windows by hand every time they cross screens.

### What it does

ProportionalResize watches window moves. When a window crosses to a different
screen, it reprojects the window so it keeps the **same fraction** of the
destination screen that it had on the source screen:

> A window filling ~70% of the big display ends up filling ~70% of the small one,
> in the same relative position.

It resizes ordinary windows — **no full screen, no Spaces** — so it stays fully
compatible with **Stage Manager** and your normal windowed workflow. The move is
debounced, so it only fires *after* you drop the window, never mid-drag.

### Requirements

- [Hammerspoon](https://www.hammerspoon.org/) (`brew install --cask hammerspoon`)
- Accessibility permission granted to Hammerspoon
  (*System Settings → Privacy & Security → Accessibility → enable Hammerspoon*)

### Installation

Clone into your Hammerspoon Spoons directory:

```sh
git clone https://github.com/snowoutwhite/ProportionalResize.spoon \
  ~/.hammerspoon/Spoons/ProportionalResize.spoon
```

Or download the repo and drop the `ProportionalResize.spoon` folder into
`~/.hammerspoon/Spoons/`.

### Usage

Add to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize:start()
```

Then reload your config (Hammerspoon menu → *Reload Config*).

### Configuration

Set any option before calling `:start()`:

```lua
hs.loadSpoon("ProportionalResize")

-- seconds for the reposition animation (0 = instant, larger = smoother glide)
spoon.ProportionalResize.animationDuration = 0.12

-- seconds to wait after a window stops moving before reprojecting it
spoon.ProportionalResize.settleDelay = 0.22

-- app names to leave completely untouched
spoon.ProportionalResize.excludedApps = { "iTerm2" }

spoon.ProportionalResize:start()
```

| Option | Default | Meaning |
| --- | --- | --- |
| `animationDuration` | `0.12` | Reposition animation length in seconds. `0` is instant. |
| `settleDelay` | `0.22` | Wait after movement stops before acting (avoids yanking mid-drag). |
| `excludedApps` | `{}` | List of app names to ignore. |

### How it works

For every window it tracks the frame as a fraction of its current screen's usable
area (`{x, y, w, h}` in 0–1). When a `windowMoved` event settles on a *different*
screen than last seen, it multiplies the stored fractions by the new screen's
frame and applies that as the window's new frame (clamped to stay on-screen).

### API

- `ProportionalResize:start()` — start watching window moves.
- `ProportionalResize:stop()` — stop watching.

### License

[MIT](LICENSE) © snowoutwhite

---

## 中文

让窗口在拖到另一块显示器时，**保持相对大小和相对位置**的 Hammerspoon 小工具。

### 解决什么问题

多屏场景下，两块屏常常用不同的**缩放（逻辑）分辨率** —— 比如 27″ 外接屏
是「看起来像 1920×1080」，旁边 13″ 笔记本为了字号舒适缩到「看起来像 1280×832」。

跨屏拖动窗口时，macOS 会**保持窗口的点尺寸不变**。于是为大屏（低密度）准备的窗口
拖到小屏就**超出屏幕**（反向拖则显得很小）。结果每次跨屏都要手动重新拉窗口。

### 它做什么

本工具监听窗口移动。当窗口换到另一块屏时，把它**重新投影**，使其占据目标屏的
**相同比例**：

> 在大屏占约 70% 的窗口，落到小屏后仍占约 70%，相对位置也保持一致。

它调整的是**普通窗口**——**不进全屏、不新建 Spaces**——因此与**台前调度
(Stage Manager)** 和你日常的窗口化习惯完全兼容。动作带防抖，只在你**松手放下**
窗口后才触发，绝不会在拖动途中拽走窗口。

### 前置条件

- [Hammerspoon](https://www.hammerspoon.org/)（`brew install --cask hammerspoon`）
- 给 Hammerspoon 授予「辅助功能」权限
  （*系统设置 → 隐私与安全性 → 辅助功能 → 打开 Hammerspoon*）

### 安装

克隆到 Hammerspoon 的 Spoons 目录：

```sh
git clone https://github.com/snowoutwhite/ProportionalResize.spoon \
  ~/.hammerspoon/Spoons/ProportionalResize.spoon
```

或下载本仓库，把 `ProportionalResize.spoon` 文件夹放进 `~/.hammerspoon/Spoons/`。

### 使用

在 `~/.hammerspoon/init.lua` 里加：

```lua
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize:start()
```

然后重载配置（Hammerspoon 菜单 → *Reload Config*）。

### 配置项

在调用 `:start()` 之前设置：

```lua
hs.loadSpoon("ProportionalResize")

-- 投影动画时长（秒），0 = 瞬间，越大越顺滑
spoon.ProportionalResize.animationDuration = 0.12

-- 窗口停止移动后等待多久再投影（秒）
spoon.ProportionalResize.settleDelay = 0.22

-- 完全不参与缩放的 App 名称
spoon.ProportionalResize.excludedApps = { "iTerm2" }

spoon.ProportionalResize:start()
```

| 配置项 | 默认值 | 含义 |
| --- | --- | --- |
| `animationDuration` | `0.12` | 投影动画时长（秒），`0` 为瞬间。 |
| `settleDelay` | `0.22` | 移动停止后等待多久再动作（避免拖到一半被拽走）。 |
| `excludedApps` | `{}` | 要忽略的 App 名称列表。 |

### 工作原理

对每个窗口，记录它相对当前屏可用区域的 frame 分数（`{x, y, w, h}`，0–1）。当
`windowMoved` 事件在**与上次不同的屏**上稳定下来时，把存下的分数乘以新屏的 frame，
作为窗口的新 frame 应用（并做边界钳制，保证不出屏）。

### API

- `ProportionalResize:start()` —— 开始监听窗口移动。
- `ProportionalResize:stop()` —— 停止监听。

### 许可证

[MIT](LICENSE) © snowoutwhite
