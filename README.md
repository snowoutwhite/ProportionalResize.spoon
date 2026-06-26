# ProportionalResize.spoon

> Keep a window's **relative size and position** when it moves to another display.
> A [Hammerspoon](https://www.hammerspoon.org/) Spoon for mixed-DPI, multi-monitor Macs.

*[English](#english) · [中文](#中文)*

---

## English

### Who is this for?

Mac users who:

- run **two or more displays at different scaled resolutions** — e.g. a large
  external at "looks like 1920×1080" next to a laptop scaled to keep its text
  comfortably large; and
- work **in ordinary windows**, especially **Stage Manager** users, rather than
  living in full-screen apps.

If dragging a window across screens keeps leaving it overflowing the small one
(or tiny on the big one), this is for you.

### The problem

When a window is dragged between displays, macOS keeps its **point size
constant**. So a window sized for a big, low-density display **overflows** a
smaller one — and a window from the small display looks tiny on the big one.
The result is resizing windows by hand on every screen change.

### What it does

ProportionalResize watches window moves. When a window crosses to a different
screen, it reprojects the window so it keeps the **same fraction** of the
destination screen it had on the source screen — a window filling ~70% of the
big display ends up filling ~70% of the small one, in the same relative position.

Because it only resizes **ordinary windows** — **no full screen, no Spaces** —
it suits the workflow of users who rely on **Stage Manager** and spread work
across several monitors. It runs only on **mouse-up** — the instant a window is
dropped — and does nothing during the drag, so dragging stays smooth.

### Quick install

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/install.sh | bash
```

One command: it drops the Spoon into `~/.hammerspoon/Spoons`, adds two lines to
your `init.lua`, and reloads.

**Prerequisites:** [Hammerspoon](https://www.hammerspoon.org/)
(`brew install --cask hammerspoon`) and, one time, Accessibility permission for
it (*System Settings → Privacy & Security → Accessibility → enable Hammerspoon*).

### Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/uninstall.sh | bash
```

Deletes the Spoon **and** removes the two lines it added — **no trace left**.
The rest of your Hammerspoon config is untouched.

### Configure (optional)

Edit the block the installer added to `~/.hammerspoon/init.lua`, then reload:

```lua
-- >>> ProportionalResize >>>
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize.animationDuration = 0.0           -- resize animation, 0 = instant
spoon.ProportionalResize.excludedApps      = { "iTerm2" }  -- apps to leave alone
spoon.ProportionalResize:start()
-- <<< ProportionalResize <<<
```

| Option | Default | Meaning |
| --- | --- | --- |
| `animationDuration` | `0` | Resize animation length in seconds. `0` is instant; `0.1` glides. |
| `excludedApps` | `{}` | App names to ignore. |

<details>
<summary>Manual install (no script)</summary>

```sh
git clone https://github.com/snowoutwhite/ProportionalResize.spoon \
  ~/.hammerspoon/Spoons/ProportionalResize.spoon
```

Then add to `~/.hammerspoon/init.lua` and reload:

```lua
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize:start()
```

</details>

### How it works

On mouse-down it records the grabbed window's frame as a fraction of its screen's
usable area (`{x, y, w, h}` in 0–1). On mouse-up, if the window ended on a
*different* screen, those fractions are multiplied by the new screen's frame and
applied as the window's new frame (clamped to stay on-screen). Nothing runs
during the drag itself, which keeps dragging smooth.

### License

[MIT](LICENSE) © snowoutwhite

---

## 中文

让窗口在拖到另一块显示器时，**保持相对大小和相对位置**的 Hammerspoon 小工具。

### 适用人群

适合这样的 Mac 用户：

- 同时使用**两块及以上、且缩放分辨率不同**的显示器——例如一块大外接屏
  「看起来像 1920×1080」，旁边的笔记本为了字号舒适而采用更大的缩放；
- 习惯**窗口化操作**，尤其是**台前调度 (Stage Manager)** 用户，而非长期全屏。

若跨屏拖动窗口后，它总在小屏上溢出、或在大屏上显得过小——这个工具正是为此而生。

### 解决什么问题

跨屏拖动窗口时，macOS 会**保持窗口的点尺寸不变**。于是为大屏（低密度）准备的窗口
拖到小屏就**超出屏幕**，反向拖到大屏又显得很小。结果每次换屏都要手动重新拉窗口。

### 它做什么

本工具监听窗口移动。当窗口换到另一块屏时，把它**重新投影**，使其占据目标屏的
**相同比例**——在大屏占约 70% 的窗口，落到小屏后仍占约 70%，相对位置保持一致。

由于它只调整**普通窗口**（**不进全屏、不新建 Spaces**），因此契合**依赖台前调度
(Stage Manager)、在多块屏幕间协作**的用户的工作流。它只在**松开鼠标**（窗口被
放下）的瞬间触发，拖动过程中不做任何处理，因此拖动始终顺滑。

### 快速安装

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/install.sh | bash
```

一条命令搞定：把 Spoon 放进 `~/.hammerspoon/Spoons`，向 `init.lua` 追加两行，并重载。

**前置条件：** [Hammerspoon](https://www.hammerspoon.org/)
（`brew install --cask hammerspoon`），以及一次性给它授予「辅助功能」权限
（*系统设置 → 隐私与安全性 → 辅助功能 → 打开 Hammerspoon*）。

### 卸载

```sh
curl -fsSL https://raw.githubusercontent.com/snowoutwhite/ProportionalResize.spoon/main/uninstall.sh | bash
```

删除 Spoon，**并**移除它写进 `init.lua` 的那两行——**不留任何痕迹**，其余配置原样不动。

### 配置（可选）

编辑安装脚本写进 `~/.hammerspoon/init.lua` 的那段，然后重载：

```lua
-- >>> ProportionalResize >>>
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize.animationDuration = 0.0           -- 缩放动画时长，0 = 瞬间
spoon.ProportionalResize.excludedApps      = { "iTerm2" }  -- 要忽略的 App
spoon.ProportionalResize:start()
-- <<< ProportionalResize <<<
```

| 配置项 | 默认值 | 含义 |
| --- | --- | --- |
| `animationDuration` | `0` | 缩放动画时长（秒），`0` 为瞬间，`0.1` 会有滑动。 |
| `excludedApps` | `{}` | 要忽略的 App 名称列表。 |

<details>
<summary>手动安装（不用脚本）</summary>

```sh
git clone https://github.com/snowoutwhite/ProportionalResize.spoon \
  ~/.hammerspoon/Spoons/ProportionalResize.spoon
```

然后在 `~/.hammerspoon/init.lua` 里加入并重载：

```lua
hs.loadSpoon("ProportionalResize")
spoon.ProportionalResize:start()
```

</details>

### 工作原理

按下鼠标时，记录所抓窗口相对当前屏可用区域的 frame 分数（`{x, y, w, h}`，0–1）。
松开鼠标时，若窗口落在了**另一块屏**上，就把这些分数乘以新屏的 frame 作为新 frame
应用（并做边界钳制，保证不出屏）。拖动过程中不做任何处理，因此拖动始终顺滑。

### 许可证

[MIT](LICENSE) © snowoutwhite
