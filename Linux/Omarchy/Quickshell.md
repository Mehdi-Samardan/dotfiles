Fresh Omarchy ISO kurulumu yaptım. Aşağıdakileri sırasıyla yap:
1. **quickshell'i kur**: `omarchy pkg aur add quickshell` (sudo şifrem .....................)
2. **Repo'yu klonla**: `git clone https://github.com/bjarneo/quickshell ~/.config/quickshell`
3. **Walker'ı tamamen devre dışı bırak**: 
   - `mv ~/.config/autostart/walker.desktop ~/.config/autostart/walker.desktop.disabled`
   - `systemctl --user mask app-walker@autostart.service`
   - `pkill -9 walker`
4. **Waybar'ı kapat**: `omarchy toggle waybar`
5. **Navbar.qml düzenle** (`~/.config/quickshell/desktop/Navbar.qml`):
   - `barHeight: 26` → `barHeight: 40`
   - `IdleMonitor { ... }` bloğunu ve `readonly property bool isIdle: idleMonitor.isIdle` satırını sil, yerine `readonly property bool isIdle: false` yaz
6. **Bar.qml düzenle** (`~/.config/quickshell/desktop/Bar.qml`):
   - Inner-edge hairline Rectangle'ı (`// Inner-edge hairline ...`) sil, yerine `Rectangle { visible: false }` yaz
   - Clock font: `font.pixelSize: 12` → `15`, `font.pixelSize: 11` → `13` (iki tane var)
   - Omarchy module: `fontSize: 14` → `18`
   - Weather module: `fontSize: 13` → `16`
   - Update module: `fontSize: 10` → `13`
   - Edge arrow: `fontSize: 12` → `14`
7. **Module.qml düzenle** (`~/.config/quickshell/desktop/Module.qml`):
   - `fontSize: 12` → `15`
   - `Layout.preferredWidth: 24` → `32`
   - `Layout.preferredHeight: 24` → `32`
8. **Workspace.qml düzenle** (`~/.config/quickshell/desktop/Workspace.qml`):
   - `Layout.preferredWidth: 20` → `28`
   - `Layout.preferredHeight: 20` → `28`
   - `font.pixelSize: wsCell.active ? 14 : 12` → `? 18 : 15`
9. **Separator.qml düzenle** (`~/.config/quickshell/desktop/Separator.qml`):
   - `Layout.preferredHeight: root.isHorizontal ? 12 : 1` → `16 : 1`
   - `Layout.leftMargin: 4` → `6`, `Layout.rightMargin: 4` → `6`
   - `Layout.topMargin: 4` → `6`, `Layout.bottomMargin: 4` → `6`
10. **OmniMenu.qml düzenle** (`~/.config/quickshell/desktop/OmniMenu.qml`):
    - PanelWindow `color: "transparent"` satırını `color: Qt.rgba(0, 0, 0, 0.65)` ile değiştir
    - `Rectangle { anchors.fill: parent; color: "#000000" }` satırını sil (siyah backdrop)
    - `Behavior on reveal { ... }` bloğunu tamamen sil
    - Kart `color: root.bg` satırını `color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.4)` ile değiştir
    - Kart `width: root.previewActive ? 1000 : 640` → `1200 : 900`
    - `readonly property int tileH: colMode ? 42 : 86` → `48 : 100`
    - `readonly property int spacing: colMode ? 4 : 10` → `4 : 12`
    - Quick tile glyph: `font.pixelSize: quickGrid.colMode ? 14 : 20` → `18 : 26`
    - Quick tile label: `font.pixelSize: quickGrid.colMode ? 7 : 9` → `9 : 12`
    - Quick tile sub: `font.pixelSize: 8` → `11`
    - Row height: `height: 38` → `44`
    - Title text: `font.pixelSize: 13` → `14`
    - Category text: `font.pixelSize: 10` → `11`
    - Icon text: `font.pixelSize: 16` → `20`
    - Footer: `font.pixelSize: 10` → `12`
    - Preview text: `font.pixelSize: 10` → `12`
    - Search icon: `font.pixelSize: 16` → `18`
    - Search text: `font.pixelSize: 14` → `15`
11. **CardWindow.qml düzenle** (`~/.config/quickshell/desktop/CardWindow.qml`):
    - `property string layerNamespace:` satırından sonra `property color titleColor: theme.ink` ve `property color subtitleColor: theme.inkDeep` ekle
    - Title `color: card.theme.ink` → `card.titleColor`
    - Subtitle `color: card.theme.inkDeep` → `card.subtitleColor`
12. **CalendarPopup.qml düzenle** (`~/.config/quickshell/desktop/CalendarPopup.qml`):
    - `cardWidth: 322` → `400`
    - `titleColor: "#ffffff"` ve `subtitleColor: "#ffffff"` ekle (theme/revealed satırlarından sonra)
    - Hafta başlığı: `height: 22` → `26`, `font.pixelSize: 12` → `14`, tüm `color` değerlerini `"#ffffff"` yap
    - Gün hücresi: `height: 34` → `42`
    - `textColor` property'sini şununla değiştir: `if (isToday) return "#000000"; if (!isCurrentMonth) return "#666666"; return "#ffffff";`
    - Bugün dairesi: `width: 29; height: 29; radius: 14` → `34; 34; 17`, `color: calendarPopup.root.seal` → `"#ffffff"`
    - Hover dairesi: `width: 29; height: 29; radius: 14` → `34; 34; 17`
    - Seçili gün: `width: 29; height: 29; radius: 14` → `34; 34; 17`, `border.color: "#ffffff"`
    - Gün numarası: `font.pixelSize: 15` → `18`
    - Detay metni: `color: calendarPopup.root.ink` → `"#ffffff"`, `font.pixelSize: 11` → `13`
    - Tatil metni: `color: calendarPopup.root.seal` → `"#ffffff"`, `font.pixelSize: 11` → `13`
    - Tüm separator `color: calendarPopup.root.sep` → `"#333333"`
13. **CalendarChevron.qml düzenle** (`~/.config/quickshell/desktop/CalendarChevron.qml`):
    - `font.pixelSize: 24` → `28`
14. **Hyprland binding ekle** (`~/.config/hypr/bindings.conf`):
    - En altına ekle: 
      ```
      # Quickshell omni-menu palette
      unbind = SUPER, SPACE
      bind = SUPER, SPACE, exec, qs -c desktop ipc call palette toggle
      ```
15. **Hyprland layer rule ekle** (`~/.config/hypr/hyprland.conf`):
    - En altına ekle:
      ```
      # Glass blur for Quickshell omni-menu
      layerrule = blur on, match:namespace omni-menu
      layerrule = blur on, match:namespace omarchy-menu
      ```
16. **Autostart hook'u kur**:
    - `install -m 755 ~/.config/quickshell/desktop/contrib/post-boot.d/quickshell-desktop ~/.config/omarchy/hooks/post-boot.d/quickshell-desktop`
17. **Hyprland'ı yeniden yükle**: `hyprctl reload`
18. **Quickshell'i başlat**: `qs -n -d -c desktop`
Hepsini sırasıyla yap ve hata kontrolü yap.