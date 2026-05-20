Omarchy + Quickshell Kurulum Rehberi
1. Quickshell Kurulumu
# ek repo'dan yükle
sudo pacman -S quickshell
# configi clone'la
git clone https://github.com/bjarneo/quickshell ~/.config/quickshell
2. Walker'ı Devre Dışı Bırak
mv /etc/xdg/autostart/walker.desktop /etc/xdg/autostart/walker.desktop.disabled
systemctl --user mask app-walker@autostart.service
pkill -9 walker
3. Waybar'ı Kapat
omarchy toggle waybar
4. IdleMonitor Fix (Quickshell 0.2.1 bug)
Dosya: ~/.config/quickshell/desktop/Navbar.qml
- IdleMonitor bloğunu bul, yerine readonly property bool isIdle: false yaz
5. Navbar Yüksekliği
Dosya: ~/.config/quickshell/desktop/Navbar.qml
- barHeight: 26 → barHeight: 40
6. Bar Görünümü
Dosya: ~/.config/quickshell/desktop/Bar.qml
- inner-edge hairline'ı kaldır (sağdaki color: root.inkGlass Rectangle)
- Font boyutları: clock 17px, omarchy logo 20px, weather 17px, update/edge 15px
7. Module Fontları
Dosya: ~/.config/quickshell/desktop/Module.qml
- fontSize: 12 → fontSize: 17
- preferredWidth/Height: 24 → 34
8. Workspace Kanji
Dosya: ~/.config/quickshell/desktop/Workspace.qml
Değişiklikler:
- preferred: 20 → 30
- active font: 14 → 19, inactive: 12 → 16
- Renkler: active #FFB7C5 (sakura pink), inactive inkDeep @ 0.5 opacity
- Slide animasyonunu sil (onActiveChanged, slideHome, slideX, slideY)
- Tüm Behavior animasyonlarını sil (color, opacity, font.pixelSize)
9. Separator
Dosya: ~/.config/quickshell/desktop/Separator.qml
- margins ve length büyütüldü
10. OmniMenu
Dosya: ~/.config/quickshell/desktop/OmniMenu.qml
- Reveal animasyonunu kaldır (Behavior on opacity, SequentialAnimation)
- Card width: 1000 / 1300
- Panel rengi: rgba(0,0,0,0.35)
- Card arkaplan: #000000 (siyah)
- Fontlar: tile glyph 30px, label 14px, row 48px, search 18/15px, icon 22px
11. CardWindow
Dosya: ~/.config/quickshell/desktop/CardWindow.qml
- titleColor / subtitleColor property'leri eklendi
- Behavior on _reveal silindi
12. CalendarPopup
Dosya: ~/.config/quickshell/desktop/CalendarPopup.qml
- cardWidth: 322 → cardWidth: 400
- Tüm text renkleri: #ffffff (beyaz)
- Gün hücreleri: 42px
- Fontlar: 18px
- Chevron: 28px
13. CalendarChevron
Dosya: ~/.config/quickshell/desktop/CalendarChevron.qml
- font: 24 → font: 28
14. Hyprland Idle Timeout
Dosya: ~/.config/hypr/hypridle.conf
- screensaver: 300 (5 dk)
- lock: 600 (10 dk)
15. Hyprland Blur Layer Rules
Dosya: ~/.config/hypr/hyprland.conf (veya looknfeel.conf)
layerrule = blur, ^(omni-menu|omarchy-menu|omarchy-.*)$
16. Blur Ayarları
Dosya: ~/.config/hypr/looknfeel.conf
blur {
    size = 6
    passes = 3
}
17. Keybindings
Dosya: ~/.config/hypr/bindings.conf
bind = SUPER, SPACE, exec, qs palette toggle
bind = SUPER, A, exec, qs quickapps
18. Quick Apps
~/.config/omarchy-quickapps/apps.json oluştur:
[
  { "name": "Firefox",        "exec": "firefox",             "icon": "" },
  { "name": "File Manager",   "exec": "thunar",              "icon": "" },
  { "name": "GitHub Desktop", "exec": "github-desktop",      "icon": "" },
  { "name": "WhatsApp",       "exec": "whatsapp-nativefier", "icon": "" }
]
19. Quick Apps Shell
Dosya: ~/.config/quickshell/quickapps/shell.qml
- Diskler: 64px
- Center text: 42px
- Tüm fontlar büyütüldü
20. Autostart Hook
~/.config/omarchy/hooks/post-boot.d/quickshell-desktop oluştur:
#!/bin/bash
sleep 2
qs -n -d -c desktop &
Yetki ver: chmod +x ~/.config/omarchy/hooks/post-boot.d/quickshell-desktop
21. Workspace Anında Güncelleme Fix
Dosya: ~/.config/quickshell/desktop/Bar.qml
// line 226: onActivated'e activeWs anında set et
onActivated: {
    bar.root.activeWs = index + 1;
    bar.root.run("hyprctl dispatch workspace " + (index + 1));
}
Komutlar (sırasıyla):
1. omarchy toggle waybar (Waybar toggle)
2. qs palette toggle (OmniMenu aç/kapa)
3. qs quickapps (Quick apps radial)
4. SUPER+SPACE → OmniMenu
5. SUPER+A → Quick Apps
Önemli Not:
- qs -n -d -c desktop ile quickshell'i başlat/dene
- kill -9 $(pidof quickshell) ile restart
- Quickshell config değişikliklerinden sonra restart gerekir
- Hyprland config değişikliklerinden sonra hyprctl reload yeter