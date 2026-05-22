# Omarchy Year Calendar — Setup Prompt
Use this prompt to add a **right-click → year calendar** feature to the clock in your Quickshell Omni desktop bar.
---
## Prompt (copy & paste)
> I use **Omarchy** with **Hyprland** and **Quickshell Omni desktop**. My top bar has a clock. Left-click opens a monthly calendar popup. I want right-click to open a **full year calendar** showing all 12 months.
>
> ### Files to modify
>
> | File | Change |
> |------|--------|
> | `~/.config/quickshell/desktop/Bar.qml` | Add right-click handler to clock |
> | `~/.config/quickshell/desktop/Navbar.qml` | Add year calendar state + data |
> | `~/.config/quickshell/desktop/YearCalendarPopup.qml` | **New** — year popup component |
> | `~/.config/quickshell/desktop/CardWindow.qml` | Add `cardBg` property |
> | `~/.config/hypr/hyprland.conf` | Add blur layer rule |
>
> ---
>
> ### 1. `CardWindow.qml`
>
> Add a `cardBg` property so subclasses can override the card's background colour:
>
> ```qml
> property color cardBg: theme.bg
> ```
>
> Then change the `surface` Rectangle's colour from `card.theme.bg` to `card.cardBg`.
>
> ---
>
> ### 2. `Navbar.qml`
>
> After `openCalendar()`, add year-calendar state and data:
>
> ```qml
> // ---------- Year Calendar state ----------
> property bool yearCalendarVisible: false
> property int yearCalendarYear: new Date().getFullYear()
>
> function openYearCalendar() {
>     if (root.calendarAnchorItem) root.anchorPopupTo(root.calendarAnchorItem);
>     root.yearCalendarYear = new Date().getFullYear();
>     root.yearCalendarVisible = true;
> }
>
> readonly property var yearCalendarMonths: {
>     const months = ["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE",
>                     "JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
>     const result = [];
>     const year = root.yearCalendarYear;
>     const today = new Date();
>     for (let m = 0; m < 12; m++) {
>         const first = new Date(year, m, 1);
>         const lastDay = new Date(year, m + 1, 0).getDate();
>         const startDay = (first.getDay() + 6) % 7;
>         const cells = [];
>         for (let i = 0; i < startDay; i++) cells.push(0);
>         for (let d = 1; d <= lastDay; d++) cells.push(d);
>         while (cells.length < 42) cells.push(0);
>         const isCurrentMonth = year === today.getFullYear() && m === today.getMonth();
>         result.push({
>             name: months[m],
>             cells: cells,
>             isCurrent: isCurrentMonth
>         });
>     }
>     return result;
> }
> ```
>
> Also add `YearCalendarPopup` in the **Surfaces** section alongside `CalendarPopup`:
>
> ```qml
> CalendarPopup      { root: root }
> YearCalendarPopup  { root: root }
> ```
>
> ---
>
> ### 3. `Bar.qml`
>
> Update the clock's `MouseArea` to accept both left and right clicks:
>
> ```qml
> MouseArea {
>     id: clockMouse
>     anchors.fill: parent
>     hoverEnabled: true
>     cursorShape: Qt.PointingHandCursor
>     acceptedButtons: Qt.LeftButton | Qt.RightButton
>     onEntered: { clockBloom.fire(mouseX, mouseY); clockTipDelay.restart(); }
>     onExited:  { clockTipDelay.stop(); bar.root.hideTooltip("Calendar"); }
>     onClicked: function(mouse) {
>         clockTipDelay.stop();
>         bar.root.hideTooltip("Calendar");
>         if (mouse.button === Qt.RightButton) {
>             if (bar.root.yearCalendarVisible) {
>                 bar.root.yearCalendarVisible = false;
>                 bar.root.calendarVisible = false;
>             } else {
>                 bar.root.calendarVisible = false;
>                 bar.root.openYearCalendar();
>             }
>         } else {
>             if (bar.root.calendarVisible) {
>                 bar.root.calendarVisible = false;
>                 bar.root.yearCalendarVisible = false;
>             } else {
>                 bar.root.yearCalendarVisible = false;
>                 bar.root.openCalendar();
>             }
>         }
>     }
> }
> ```
>
> ---
>
> ### 4. `YearCalendarPopup.qml` (new file)
>
> Create `~/.config/quickshell/desktop/YearCalendarPopup.qml`:
>
> ```qml
> import QtQuick
> import QtQuick.Layouts
>
> CardWindow {
>     id: yearPopup
>     required property var root
>
>     readonly property color sakuraPink: "#FF1A6B"
>
>     theme: root
>     cardBg: root.paper
>     revealed: root.yearCalendarVisible
>     cardWidth: 1300
>     cardHeight: -1
>     layerNamespace: "omarchy-year-calendar"
>     title: String(root.yearCalendarYear)
>     subtitle: "YEAR"
>
>     anchorEdge: root.barEdge
>     anchorBarX: root.popupAnchorX
>     anchorBarY: root.popupAnchorY
>
>     onDismiss: root.yearCalendarVisible = false
>     onKeyPressed: function(event) {
>         if (event.key === Qt.Key_Q) {
>             root.yearCalendarVisible = false;
>             event.accepted = true;
>         }
>     }
>
>     Column {
>         width: parent.width
>         spacing: 24
>
>         GridLayout {
>             columns: 4
>             columnSpacing: 32
>             rowSpacing: 28
>             width: parent.width
>
>             Repeater {
>                 model: root.yearCalendarMonths
>
>                 delegate: Item {
>                     required property var modelData
>                     required property int index
>
>                     readonly property int monthIndex: index
>
>                     implicitWidth: (parent.width - 96) / 4
>                     implicitHeight: monthCol.implicitHeight
>
>                     Column {
>                         id: monthCol
>                         width: parent.width
>                         spacing: 8
>
>                         Text {
>                             text: modelData.name
>                             color: modelData.isCurrent ? root.seal : "#ffffff"
>                             font.family: root.mono
>                             font.pixelSize: 17
>                             font.letterSpacing: 3
>                             font.weight: Font.Medium
>                         }
>
>                         Rectangle {
>                             width: parent.width
>                             height: 1
>                             color: "#333333"
>                         }
>
>                         Row {
>                             spacing: 0
>                             width: parent.width
>
>                             Repeater {
>                                 model: ["M","T","W","T","F","S","S"]
>                                 delegate: Text {
>                                     width: parent.width / 7
>                                     horizontalAlignment: Text.AlignHCenter
>                                     text: modelData
>                                     color: "#666666"
>                                     font.family: root.mono
>                                     font.pixelSize: 12
>                                 }
>                             }
>                         }
>
>                         Grid {
>                             columns: 7
>                             columnSpacing: 0
>                             rowSpacing: 3
>                             width: parent.width
>
>                             Repeater {
>                                 model: modelData.cells
>
>                                 delegate: Item {
>                                     required property var modelData
>                                     required property int index
>
>                                     width: parent.width / 7
>                                     height: 36
>
>                                     readonly property bool isToday: {
>                                         if (modelData === 0) return false;
>                                         const now = new Date();
>                                         return now.getFullYear() === root.yearCalendarYear
>                                             && now.getMonth() === monthIndex
>                                             && now.getDate() === modelData;
>                                     }
>
>                                     Rectangle {
>                                         anchors.centerIn: parent
>                                         width: parent.width - 4
>                                         height: 30
>                                         radius: 6
>                                         color: sakuraPink
>                                         visible: isToday
>                                     }
>
>                                     Text {
>                                         anchors.centerIn: parent
>                                         text: modelData > 0 ? modelData : ""
>                                         color: isToday ? "#ffffff"
>                                              : (modelData > 0 ? "#aaaaaa" : "transparent")
>                                         font.family: root.mono
>                                         font.pixelSize: 15
>                                         font.weight: isToday ? Font.Bold : Font.Light
>                                     }
>
>                                     MouseArea {
>                                         anchors.fill: parent
>                                         hoverEnabled: modelData > 0
>                                         enabled: modelData > 0
>                                         cursorShape: modelData > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
>                                         onClicked: {
>                                             root.yearCalendarVisible = false;
>                                             root.calendarMonthOffset = monthIndex - (new Date()).getMonth();
>                                             root.calendarTick++;
>                                             root.selectedDay = modelData;
>                                             root.calendarVisible = true;
>                                         }
>                                     }
>                                 }
>                             }
>                         }
>                     }
>                 }
>             }
>         }
>     }
> }
> ```
>
> **Important:** In the inner Repeater (cells), `index` is the cell position (0–41), **not** the month. Always use `monthIndex` (saved from the outer scope) for month comparisons.
>
> ---
>
> ### 5. `~/.config/hypr/hyprland.conf`
>
> Add a blur rule for the year calendar namespace:
>
> ```conf
> layerrule = blur on, match:namespace omarchy-year-calendar
> ```
>
> Reload Hyprland:
>
> ```bash
> hyprctl reload
> ```
>
> ---
>
> ### 6. Restart Quickshell
>
> ```bash
> pgrep -x qs | xargs kill; sleep 1; qs -d -c desktop
> ```
>
> Check for errors:
>
> ```bash
> ls -t /run/user/1000/quickshell/by-id/*/log.qslog | head -1 | xargs cat | grep -i error
> ```
---
## Behaviour summary
| Action | Result |
|--------|--------|
| **Left-click** clock | Opens/closes monthly calendar |
| **Right-click** clock | Opens/closes full-year calendar |
| **Click a day** in year view | Closes year, opens monthly at that month |
| **Press Q** / click outside | Closes popup |
| **Desktop behind** popup | Blurred by Hyprland |
| **Today's cell** | Sakura pink (`#FF1A6B`) full-width rounded rect |
---
## Key gotchas
- **`monthIndex`**: Inner Repeater's `index` shadows the outer month index. Save `monthIndex: index` in the outer delegate and use it inside cell delegates.
- **No `onRightClicked`**: QML doesn't have this signal. Use `onClicked: function(mouse)` and check `mouse.button === Qt.RightButton`.
- **`qs` binary**: Quickshell uses `qs`, not `quickshell`.
- **`cardBg` inheritance**: After adding `cardBg` to `CardWindow.qml`, all popups get the property. The standalone override in `YearCalendarPopup` keeps the year calendar opaque without affecting others.
