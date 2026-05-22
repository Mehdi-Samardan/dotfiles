# Quickshell Power Popup + Bluetooth Auto-Connect Guide

This guide covers two Quickshell/Omarchy customizations:
1. Adding a **Power Popup** (Lock, Screensaver, Suspend, Hibernate, Logout, Reboot, BIOS Setup, Shutdown) to the far right of the top bar.
2. Enabling **Bluetooth auto-connect** so trusted devices (keyboard, mouse, etc.) connect before the login screen.

---

## 1. Power Popup

### 1.1 Create the Popup (`PowerPopup.qml`)

Place this file in your Quickshell desktop config directory (e.g. `~/.config/quickshell/desktop/`):

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

    anchorEdge: root.barEdge
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

> **Note:** The glyph codepoints shown here use the raw PUA notation (`\U000f00fe` etc.). In the actual source file you can paste the rendered Nerd Font glyph directly (e.g. `"\U000f00fe"` → `"\uf00fe"`). Use a Nerd Font cheat sheet to look up your preferred icons.

### 1.2 Add State to Navbar

In your `Navbar.qml` (or equivalent root component), add:

**Anchor item** — alongside the other anchor items (around line 116):
```qml
property Item powerAnchorItem: null
```

**Visibility flag** — near the other visibility properties:
```qml
property bool   powerVisible: false
```

**Open function** — near the other `open*Popup` functions:
```qml
function openPowerPopup() {
    if (root.powerAnchorItem) root.anchorPopupTo(root.powerAnchorItem);
    root.powerVisible = true;
}
```

**Instantiate the popup** — alongside the other popups:
```qml
PowerPopup       { root: root }
```

### 1.3 Add the Bar Module

In your `Bar.qml`, add a `Module` at the far-right position (before the edge chevron):

```qml
Module {
    id: powerBtn
    root: bar.root
    glyph: bar.root.icoPower    // or any icon string
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

## 2. Bluetooth Auto-Connect at Boot (Before Login Screen)

The issue: Bluetooth defaults to `Powered: off` at boot, so trusted input devices (keyboard, mouse) don't connect in time for the login/lock screen.

### 2.1 Trust Your Devices

First, list and trust every device you want to auto-connect:

```bash
# List discovered devices
bluetoothctl devices

# Trust each device by MAC address
bluetoothctl trust <MAC_ADDRESS>
```

Repeat for all devices (keyboard, mouse, earbuds, etc.).

### 2.2 Enable Auto Power-On in BlueZ

The key setting is `AutoEnable` in `/etc/bluetooth/main.conf`. By default it's `true`, but Omarchy (and some distros) set it to `false`.

Check the current value:

```bash
grep AutoEnable /etc/bluetooth/main.conf
```

If it says `AutoEnable=false`, change it:

```bash
sudo sed -i 's/AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf
```

Then restart the Bluetooth service:

```bash
sudo systemctl restart bluetooth
```

### 2.3 How It Works

1. At system boot, `bluetoothd` (the BlueZ daemon) starts.
2. Because `AutoEnable=true`, it immediately powers on the Bluetooth adapter.
3. BlueZ automatically attempts to connect all previously paired + trusted devices that are in range.
4. This happens **before** the display manager (login screen) launches, so your keyboard and mouse work at the login prompt.

No additional autostart entries, udev rules, or scripts are needed. The single `AutoEnable=true` line is sufficient.

### 2.4 Verify

```bash
# Check trusted devices
bluetoothctl devices Trusted

# Check connected devices
bluetoothctl devices Connected

# Check adapter power state
bluetoothctl show | grep Powered
```

### 2.5 Troubleshooting

| Symptom | Fix |
|---------|-----|
| Device paired but won't connect | `bluetoothctl trust <MAC>` then `bluetoothctl connect <MAC>` once manually |
| `AutoEnable` keeps resetting | Check if a distro service or Omarchy migration reverts it on update |
| Keyboard works in session but not in login screen | Verify `AutoEnable=true`; also check that `bluetooth.service` is enabled: `systemctl is-enabled bluetooth` |
| Mouse connects but keyboard doesn't | Some keyboards require explicit `connect` after `trust`. Also check battery/sleep mode |

---

## 3. Summary of Files Changed

| File | Change |
|------|--------|
| `~/.config/quickshell/desktop/PowerPopup.qml` | **New** — power action popup |
| `~/.config/quickshell/desktop/Navbar.qml` | Added `powerVisible`, `powerAnchorItem`, `openPowerPopup()`, `PowerPopup { root: root }` |
| `~/.config/quickshell/desktop/Bar.qml` | Added power `Module` before edge chevron |
| `/etc/bluetooth/main.conf` | `AutoEnable=false` → `AutoEnable=true` |

---

*Generated for Omarchy / Quickshell on Hyprland — May 2026*
