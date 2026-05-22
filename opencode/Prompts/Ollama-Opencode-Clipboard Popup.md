# Quickshell Customization Guide

This guide covers three Quickshell/Omarchy customizations:
1. **Power Popup** — system actions (Lock, Screensaver, Suspend, Hibernate, Logout, Reboot, BIOS Setup, Shutdown) in a popup at the far right of the top bar.
2. **Clipboard Popup** — clipboard history viewer (via `cliphist`) with up to 10 recent items, opening to the right of the screen-record button.
3. **Bluetooth Auto-Connect** — trusted devices (keyboard, mouse, etc.) connect before the login screen.

All popups use the same visual style: vertical bordered-item lists with icon + label, keyboard navigation (arrows + Enter), and mouse click support.

---

## 1. Power Popup

### 1.1 Create the Popup (`PowerPopup.qml`)

Place this file in `~/.config/quickshell/desktop/`:

```qml
import QtQuick
import QtQuick.Layouts

CardWindow {
    id: powerPopup
    required property var root

    theme: root
    revealed: root.powerVisible
    cardWidth: 320
    cardHeight: -1       // auto-size to content
    layerNamespace: "omarchy-power"

    anchorBarX: root.popupAnchorX
    anchorBarY: root.popupAnchorY

    title: "POWER"
    subtitle: root.batVal + "%" + (root.batState !== "Unknown" ? "  ·  " + root.batState.toUpperCase() : "")

    onDismiss: root.powerVisible = false

    onKeyPressed: function(event) {
        const k = event.key;
        const n = actions.length;
        if (k === Qt.Key_Up) {
            selIndex = (selIndex - 1 + n) % n;
            event.accepted = true;
        } else if (k === Qt.Key_Down) {
            selIndex = (selIndex + 1) % n;
            event.accepted = true;
        } else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
            const a = actions[selIndex];
            if (a && a.cmd) root.run(a.cmd);
            root.powerVisible = false;
            event.accepted = true;
        }
    }

    property int selIndex: 0
    readonly property var actions: [
        { glyph: "\U000f00fe", label: "LOCK"         , cmd: "hyprlock" },
        { glyph: "\U000f03d9", label: "SCREENSAVER"  , cmd: "hyprlock & sleep 0.5 && hyprctl dispatch dpms off" },
        { glyph: "\U000f0124", label: "SUSPEND"      , cmd: "systemctl suspend" },
        { glyph: "\U000f02cb", label: "HIBERNATE"    , cmd: "systemctl hibernate" },
        { glyph: "\U000f05fd", label: "LOGOUT"       , cmd: "hyprctl dispatch exit" },
        { glyph: "\U000f0709", label: "REBOOT"       , cmd: "systemctl reboot" },
        { glyph: "\U000f09f3", label: "BIOS SETUP"   , cmd: "systemctl reboot --firmware-setup" },
        { glyph: "\U000f0425", label: "SHUTDOWN"     , cmd: "systemctl poweroff" }
    ]

    Column {
        id: listCol
        width: parent.width
        spacing: 6

        Repeater {
            model: powerPopup.actions

            delegate: Item {
                required property var modelData
                required property int index

                width: listCol.width
                height: 36

                Rectangle {
                    anchors.fill: parent
                    radius: root.cornerRadius
                    color: powerPopup.selIndex === index
                           ? Qt.rgba(root.seal.r, root.seal.g, root.seal.b, 0.20)
                           : mouse.containsMouse
                              ? Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.10)
                              : "transparent"
                    border.color: powerPopup.selIndex === index ? root.seal : root.sep
                    border.width: powerPopup.selIndex === index ? 2 : 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.glyph
                        color: powerPopup.selIndex === index ? root.seal : root.ink
                        font.family: root.mono
                        font.pixelSize: 15
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: powerPopup.selIndex === index ? root.seal : root.ink
                        font.family: root.mono
                        font.pixelSize: 12
                        font.letterSpacing: 2
                        font.weight: Font.Medium
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powerPopup.selIndex = index;
                        if (modelData.cmd) root.run(modelData.cmd);
                        root.powerVisible = false;
                    }
                }
            }
        }
    }
}
```

> **Note:** Glyph codepoints use Nerd Font PUA ranges (`\U000f...`). In the actual source you can paste the rendered glyph directly. Use a [Nerd Font cheat sheet](https://www.nerdfonts.com/cheat-sheet) to find icons.

### 1.2 Add State to Navbar

In `Navbar.qml` (or your root component), add:

**Anchor item** — alongside other anchors:
```qml
property Item powerAnchorItem: null
```

**Visibility flag:**
```qml
property bool   powerVisible: false
```

**Open function:**
```qml
function openPowerPopup() {
    if (root.powerAnchorItem) root.anchorPopupTo(root.powerAnchorItem);
    root.powerVisible = true;
}
```

**Instantiate the popup** — alongside other popups:
```qml
PowerPopup       { root: root }
```

### 1.3 Add Bar Module

In `Bar.qml`, add a `Module` at the far right (before the edge chevron):

```qml
Module {
    id: powerBtn
    root: bar.root
    glyph: bar.root.icoPower    // or any icon string, e.g. "\U000f0425"
    tooltip: "Power"
    color: "#ffffff"
    fontSize: 15
    Component.onCompleted: bar.root.powerAnchorItem = powerBtn
    onActivated: bar.root.openPowerPopup()
}
```

### 1.4 Restart Quickshell

```bash
pkill -9 -f "qs" && sleep 2 && qs -n -d -c desktop &
```

---

## 2. Clipboard Popup

### 2.1 Install cliphist

`cliphist` is a Wayland clipboard history daemon. It stores everything you copy (`wl-paste --watch cliphist store`) and lets you retrieve items later.

```bash
# Arch / Omarchy
sudo pacman -S cliphist

# Start the clipboard store service
systemctl --user enable --now cliphist
```

This runs `/usr/bin/wl-paste --watch cliphist store` in the background, capturing every clipboard write into a persistent database.

### 2.2 Create the Popup (`ClipboardPopup.qml`)

Place this file in `~/.config/quickshell/desktop/`:

```qml
import QtQuick
import Quickshell
import Quickshell.Io

CardWindow {
    id: clipPopup
    required property var root

    theme: root
    revealed: root.clipboardVisible
    cardWidth: 420
    cardHeight: -1
    layerNamespace: "omarchy-clipboard"

    anchorEdge: root.barEdge
    anchorBarX: root.popupAnchorX
    anchorBarY: root.popupAnchorY

    title: "CLIPBOARD"
    subtitle: clipItems.length + " ITEM" + (clipItems.length !== 1 ? "S" : "")

    onDismiss: root.clipboardVisible = false

    onKeyPressed: function(event) {
        const k = event.key;
        const n = clipItems.length;
        if (n === 0) return;
        if (k === Qt.Key_Up) {
            selIndex = (selIndex - 1 + n) % n;
            event.accepted = true;
        } else if (k === Qt.Key_Down) {
            selIndex = (selIndex + 1) % n;
            event.accepted = true;
        } else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
            const item = clipItems[selIndex];
            if (item && item.id) copyItem(item.id);
            event.accepted = true;
        }
    }

    property int selIndex: 0
    property var clipItems: []

    function copyItem(id) {
        root.run("cliphist decode " + id + " | wl-copy");
        root.clipboardVisible = false;
    }

    function refresh() {
        probe.running = false;
        probe.running = true;
    }

    onRevealedChanged: {
        if (revealed) refresh();
    }

    Process {
        id: probe
        running: false
        command: ["bash", "-lc",
            "cliphist list 2>/dev/null | head -10 | while IFS=$'\\t' read -r id content; do "
            + "content=$(printf '%s' \"$content\" | head -c 120 | tr '\\n' ' ' | tr '\\t' ' '); "
            + "printf '%s|%s\\n' \"$id\" \"$content\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0);
                const items = [];
                for (let i = 0; i < lines.length; i++) {
                    const sep = lines[i].indexOf("|");
                    if (sep < 0) continue;
                    const id = lines[i].slice(0, sep).trim();
                    const content = lines[i].slice(sep + 1);
                    if (id) items.push({ id: id, content: content });
                }
                clipPopup.clipItems = items;
                clipPopup.selIndex = 0;
            }
        }
    }

    Column {
        id: listCol
        width: parent.width
        spacing: 6

        Repeater {
            model: clipPopup.clipItems.length > 10 ? 10 : clipPopup.clipItems.length

            delegate: Item {
                required property int index

                width: listCol.width
                height: 34

                Rectangle {
                    anchors.fill: parent
                    radius: root.cornerRadius
                    color: clipPopup.selIndex === index
                           ? Qt.rgba(root.seal.r, root.seal.g, root.seal.b, 0.20)
                           : mouse.containsMouse
                              ? Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.10)
                              : "transparent"
                    border.color: clipPopup.selIndex === index ? root.seal : root.sep
                    border.width: clipPopup.selIndex === index ? 2 : 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\U000f014e"
                        color: clipPopup.selIndex === index ? root.seal : root.inkDeep
                        font.family: root.mono
                        font.pixelSize: 13
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 38
                        elide: Text.ElideRight
                        text: index < clipPopup.clipItems.length ? clipPopup.clipItems[index].content : ""
                        color: clipPopup.selIndex === index ? root.seal : root.ink
                        font.family: root.mono
                        font.pixelSize: 11
                        font.letterSpacing: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        clipPopup.selIndex = index;
                        const item = clipPopup.clipItems[index];
                        if (item && item.id) clipPopup.copyItem(item.id);
                    }
                }
            }
        }
    }
}
```

### 2.3 Add State to Navbar

**Anchor item:**
```qml
property Item clipboardAnchorItem: null
```

**Visibility flag:**
```qml
property bool   clipboardVisible: false
```

**Open function:**
```qml
function openClipboardPopup() {
    if (root.clipboardAnchorItem) root.anchorPopupTo(root.clipboardAnchorItem);
    root.clipboardVisible = true;
}
```

**Instantiate the popup:**
```qml
ClipboardPopup   { root: root }
```

### 2.4 Add Bar Module

In `Bar.qml`, add a `Module` to the right of the screen-record button (before the first `Separator`):

```qml
Module {
    id: clipBtn
    root: bar.root
    glyph: "\U000f014e"        // clipboard icon
    tooltip: "Clipboard"
    color: "#ffffff"
    fontSize: 15
    Component.onCompleted: bar.root.clipboardAnchorItem = clipBtn
    onActivated: bar.root.openClipboardPopup()
}
```

### 2.5 Verify

```bash
# Copy something
echo "hello world" | wl-copy

# Check cliphist stored it
cliphist list

# Expected output:
# 1  hello world
```

Click the clipboard icon in the bar → popup opens with up to 10 recent items. Click any item or press Enter to copy it back to the clipboard.

---

## 3. Bluetooth Auto-Connect at Boot (Before Login Screen)

The issue: Bluetooth defaults to `Powered: off` at boot, so trusted input devices (keyboard, mouse) don't connect in time for the login/lock screen.

### 3.1 Trust Your Devices

```bash
# List discovered devices
bluetoothctl devices

# Trust each device by MAC address
bluetoothctl trust <MAC_ADDRESS>
```

Repeat for every device you want to auto-connect (keyboard, mouse, earbuds, etc.).

### 3.2 Enable Auto Power-On in BlueZ

The key setting is `AutoEnable` in `/etc/bluetooth/main.conf`. By default it's `true`, but Omarchy (and some distros) set it to `false`.

Check the current value:

```bash
grep AutoEnable /etc/bluetooth/main.conf
```

If it says `AutoEnable=false`, change it:

```bash
sudo sed -i 's/AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf
sudo systemctl restart bluetooth
```

### 3.3 How It Works

1. At system boot, `bluetoothd` (the BlueZ daemon) starts.
2. Because `AutoEnable=true`, it immediately powers on the Bluetooth adapter.
3. BlueZ automatically attempts to connect all previously paired + trusted devices that are in range.
4. This happens **before** the display manager (login screen) launches, so your keyboard and mouse work at the login prompt.

No additional autostart entries, udev rules, or scripts are needed. The single `AutoEnable=true` line is sufficient.

### 3.4 Verify

```bash
bluetoothctl devices Trusted
bluetoothctl devices Connected
bluetoothctl show | grep Powered
```

### 3.5 Troubleshooting

| Symptom | Fix |
|---------|-----|
| Device paired but won't connect | `bluetoothctl trust <MAC>` then `bluetoothctl connect <MAC>` once manually |
| `AutoEnable` keeps resetting | Check if a distro service or Omarchy migration reverts it on update |
| Keyboard works in session but not in login screen | Verify `AutoEnable=true`; also check that `bluetooth.service` is enabled: `systemctl is-enabled bluetooth` |
| Mouse connects but keyboard doesn't | Some keyboards require explicit `connect` after `trust`. Also check battery/sleep mode |

---

## 4. Summary of Files Changed

| File | Change |
|------|--------|
| `~/.config/quickshell/desktop/PowerPopup.qml` | **New** — power action popup |
| `~/.config/quickshell/desktop/ClipboardPopup.qml` | **New** — clipboard history popup |
| `~/.config/quickshell/desktop/Navbar.qml` | Added `powerVisible`, `powerAnchorItem`, `openPowerPopup()`, `clipboardVisible`, `clipboardAnchorItem`, `openClipboardPopup()`, `PowerPopup { root: root }`, `ClipboardPopup { root: root }` |
| `~/.config/quickshell/desktop/Bar.qml` | Added power `Module` (far right) and clipboard `Module` (right of record button) |
| `/etc/bluetooth/main.conf` | `AutoEnable=false` → `AutoEnable=true` |

---

## 5. Restart Commands

After any QML change:

```bash
pkill -9 -f "qs" && sleep 2 && qs -n -d -c desktop &
```

---

*Generated for Omarchy / Quickshell on Hyprland — May 2026*
