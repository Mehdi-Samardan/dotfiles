1. FILES CREATED
Two entirely new files were created for the recording feature:
File	Absolute Path	Lines	Role
RecordingPopup.qml	/home/mehdi/.config/quickshell/desktop/RecordingPopup.qml	272	Live recording status popup (duration, file size, mic level, stop/cancel buttons, keyboard shortcuts)
ResolutionPopup.qml	/home/mehdi/.config/quickshell/desktop/ResolutionPopup.qml	86	Resolution picker dialog before starting a recording
2. FILES MODIFIED
Navbar.qml (/home/mehdi/.config/quickshell/desktop/Navbar.qml)
1905 lines total. The recording additions span several sections:
Icon codepoints (lines 59–60):
- icoRecording = 0xf111 (line 59) — the red circle "recording" dot (Font Awesome circle)
- icoVideoCam = 0xf003d (line 60) — the video camera icon
Anchor item property (line 116):
- property Item recordingAnchorItem: null — Item reference for anchoring the recording popup to the recording indicator in the bar
Anchor item property (line 117):
- property Item resolutionAnchorItem: null — Item reference for anchoring the resolution popup to the record button
Recording state properties (lines 314–324):
Property	Type	Default
recordingActive	bool	false
recordingDuration	int	0
recordingText	string	""
recordingOutput	string	""
recordingFps	int	60
recordingAudio	string	""
recordingResolution	string	""
recordingPopupVisible	bool	false
resolutionPopupVisible	bool	false
_recordingStoppedNormally	bool	false
Recording functions (lines 326–359):
- openRecordingPopup() (line 326–329) — anchors and shows the recording popup
- takeScreenshot(mode) (line 331–333) — calls omarchy capture screenshot <mode>
- startRecording(resolution) (line 335–341) — calls omarchy capture screenrecording with optional OMARCHY_SCREENRECORD_USE_PORTAL=true and --resolution= flag
- openResolutionPopup() (line 343–346) — anchors and shows the resolution popup
- stopRecording() (line 348–351) — sets _recordingStoppedNormally = true and sends SIGINT to gpu-screen-recorder via pkill
- cancelRecording() (line 353–358) — reads filename from /tmp/omarchy-screenrecord-filename, kills with SIGKILL, removes the output file and temp marker
Recording probe — Process (lines 1537–1584):
- id: recordingProbe — a Process that runs every 2 seconds
- Shell command: checks for gpu-screen-recorder via pgrep. If absent, prints idle. If present, extracts FPS (-f), audio source (-a), resolution (-s), output file path from /tmp/omarchy-screenrecord-filename, start time from that file's mtime, elapsed seconds, and file size via stat
- Parses the active|fps|audio|res|file|elapsed|size pipe-delimited output
- On transition from active→idle: sets recordingActive = false, and if _recordingStoppedNormally is true, triggers the openAfterRecording timer
- On first detection of active: captures initial metadata (FPS, audio, resolution, output path), formats initial duration as MM:SS
- Timer (line 1583): interval: 2000, running: true, repeat: true, triggeredOnStart: true
Recording duration counter — Timer (lines 1586–1598):
- id: recordingDurationTimer — runs at 1 Hz while recordingActive is true
- Increments recordingDuration and formats as MM:SS into recordingText
Post-recording actions — Timer (lines 1600–1612):
- id: openAfterRecording — fires 2 seconds after a normal stop
- Sends notify-send -t 2500 'Recording saved'
- Opens the parent directory of the recorded file via xdg-open
Surface registrations (lines 1831–1832 — bottom of Navbar.qml):
- RecordingPopup { root: root } (line 1831)
- ResolutionPopup { root: root } (line 1832)
Bar.qml (/home/mehdi/.config/quickshell/desktop/Bar.qml)
477 lines total. Recording additions are in the module layout:
Screenshot button (lines 272–279):
- Module with glyph icoCamera (0xf0100), tooltip "Screenshot"
- left-click: takeScreenshot("smart"); right-click: takeScreenshot("region")
- Color: root.ink, fontSize: 16
Record button (lines 282–293):
- Module id: recBtn, visible when !recordingActive
- Glyph: icoVideoCam (0xf003d), tooltip: "Record screen", fontSize: 17
- Component.onCompleted registers itself as root.resolutionAnchorItem
- left-click: startRecording(); right-click: openResolutionPopup()
Recording indicator (lines 296–334):
- Item id: recIndicator, visible when recordingActive
- Fixed width 84px, height barHeight
- Component.onCompleted registers itself as root.recordingAnchorItem
- Contains:
- A pulsing red circle (#ff4444, radius 4) with a sequential animation (1.0→0.25→1.0 over 800ms each leg, infinite loop)
- A Text element showing root.recordingText in mono font, color #ff4444, size 12, letter-spacing 1
- A MouseArea covering the indicator; click opens recording popup via openRecordingPopup()
3. EVERY QML SURFACE REGISTERED (shell.qml + Navbar.qml surfaces)
From shell.qml (/home/mehdi/.config/quickshell/desktop/shell.qml, 25 lines):
- ShellRoot (line 14)
- Theme (line 17)
- Navbar (line 19) — the root controller
- OmniMenu (line 24) — palette
From Navbar.qml lines 1822–1832 (all instantiated inside the Navbar Item):
Line	Surface
1822	Bar — the main bar window
1823	TooltipOverlay — hover tooltips
1824	CalendarPopup
1825	YearCalendarPopup
1826	ScreenshotsPopup
1827	VideosPopup
1828	AetherPopup
1829	DisplayPopup
1830	WeatherPopup
1831	RecordingPopup — NEW for recording feature
1832	ResolutionPopup — NEW for recording feature
All recording popups use CardWindow (/home/mehdi/.config/quickshell/desktop/CardWindow.qml) as their base, which remains unmodified (214 lines, no recording-specific changes needed).
4. EVERY ICON CODEPOINT USED
From Navbar.qml lines 44–60:
Property	Codepoint	Usage
icoOmarchy	0xe900	Omarchy logo (Menu button)
icoBtOn	0xf294	Bluetooth on
icoVol1	0xf026	Volume low
icoVol2	0xf027	Volume medium
icoVol3	0xf028	Volume high
icoMute	0xeee8	Muted
icoCamera	0xf0100	Screenshot button
icoRefresh	0xf0450	Refresh
icoDisplay	0xf0379	Display popup
icoPower	0xf0425	Power
icoAether	0xf03d8	Aether themes
icoFilm	0xf0231	Film/video
icoSearch	0xf0349	Search
icoUpdate	0xf021	Update available
icoPlug	0xf06a5	Plugged-in (battery)
icoRecording	0xf111	Recording dot (Font Awesome circle)
icoVideoCam	0xf003d	Video camera icon
The recording-specific codepoints are:
- icoRecording (0xf111) — used conceptually as an identifier; the actual pulsing red dot in Bar.qml is a hand-drawn Rectangle (not a text glyph)
- icoVideoCam (0xf003d) — displayed on the record button in Bar.qml (line 286) and as a decorative icon in ResolutionPopup.qml (line 61)
5. EXACT LAYOUT OF THE BAR (module order)
From Bar.qml lines 220–474 (GridLayout):
Position	Element	Type
1	Omarchy Menu	Module (glyph: icoOmarchy)
2	Separator	Separator
3	10 Workspaces	Repeater of Workspace (kanji numerals 一..十)
4	Spacer	Item { Layout.fillWidth: true }
5	Weather	Module (glyph: weather icon / temp)
6	Screenshot	Module (glyph: icoCamera)
7	Record / RecIndicator	Module / Item (conditional visibility)
8	Separator	Separator
9	CPU	Module (glyph: 󰍛)
10	Bluetooth	Module (glyph: btIcon)
11	Network/Wi-Fi	Module (glyph: netIcon) + burst arc
12	Audio	Module (glyph: audioIcon)
13	Omarchy Update	Module (visible when update available)
14	Battery	Module (glyph: batteryIcon())
15	Edge chevron	Module (glyph: edgeArrow())
The capture cluster (items 6–8) sits right of the spacer, between Weather and the system indicator Separator: Weather → Screenshot → Record/Recording indicator → Separator → System cluster.
6. RECORDING STATE MANAGEMENT
State machine / flags (all on root in Navbar.qml):
Flag	Type	Set by	Cleared by	Effect
recordingActive	bool	recordingProbe.onStreamFinished when gpu-screen-recorder is found	recordingProbe.onStreamFinished when process vanishes	Controls recIndicator visibility, duration timer, record button visibility
_recordingStoppedNormally	bool	stopRecording() before SIGINT	startRecording(), recordingProbe post-processing	Gates the openAfterRecording timer (notification + xdg-open)
recordingPopupVisible	bool	openRecordingPopup()	stop/cancel buttons, onDismiss, Esc key	Controls RecordingPopup visibility
resolutionPopupVisible	bool	openResolutionPopup()	resolution selection click, onDismiss, Esc	Controls ResolutionPopup visibility
Probes:
Probe	ID	Interval	Purpose
Recording probe	recordingProbe	2 seconds	Polls for gpu-screen-recorder process, extracts CLI args (FPS, audio, resolution), output file path, elapsed time, file size
Popup refresh (in RecordingPopup)	popupRefresh	1 second	While popup is open, polls file size via stat and mic volume via pamixer --default-source --get-volume
Timers:
Timer	ID	Interval	Purpose
Recording duration	recordingDurationTimer	1 second	Increments recordingDuration and formats recordingText as MM:SS while recordingActive
Open after recording	openAfterRecording	2 seconds (single-shot)	Fires after normal stop: sends notification, opens parent directory in file manager
Recording lifecycle:
1. Start: User clicks record button → startRecording("") (or with resolution string via ResolutionPopup) → spawns gpu-screen-recorder via omarchy capture screenrecording
2. Detection: recordingProbe (2 Hz) detects the process → sets recordingActive = true, captures initial metadata
3. Live tick: recordingDurationTimer (1 Hz) increments duration; recordingProbe (2 Hz) re-detects on every tick (the if (!root.recordingActive) guard prevents re-reading metadata mid-recording)
4. Stop: User clicks Stop button (or presses S in popup) → stopRecording() → sets _recordingStoppedNormally = true → sends SIGINT to gpu-screen-recorder
5. Post-stop: Probe detects process gone → clears recordingActive → sees _recordingStoppedNormally → fires openAfterRecording timer → shows notification + opens file manager directory
6. Cancel: User clicks Cancel (or presses C) → cancelRecording() → SIGKILL + deletes file on disk
7. POPUP BEHAVIOR
RecordingPopup (RecordingPopup.qml)
Aspect	Detail
Base	CardWindow (shared popup chrome)
Window type	PanelWindow (full-screen overlay)
Layer namespace	"omarchy-recording"
Reveal binding	root.recordingPopupVisible
Width	520px
Footer	"↵ STOP  ·  ⌫ CANCEL & DELETE  ·  ESC CLOSE"
Anchor	Follows popupAnchorX/Y at root.barEdge
Dismiss	Sets root.recordingPopupVisible = false
Body layout	Column with spacing 14
- Live duration	Large red mono text (#ff4444, 42px). Shows root.recordingText
- Info grid	5 rows via Repeater: Duration, Resolution (with FPS), Audio, File size (live), Save path (with ~ substitution)
- Microphone level	Horizontal bar + percentage. Visible only when recordingAudio contains "default_input". Color shifts to root.seal above 90%
- Action buttons	RowLayout: spacer, "■ Stop" (indigo bg), "✕ Cancel & Delete" (muted bg)
- Stop button	Sets recordingPopupVisible = false, calls stopRecording()
- Cancel button	Sets recordingPopupVisible = false, calls cancelRecording()
Keyboard	S → Stop, C → Cancel, Esc → dismiss (via CardWindow)
Live refresh	popupRefresh process runs every 1s while visible. Updates file size and mic level
Helper functions	fmtSize() — human-readable bytes; fmtAudio() — parses pipe-separated audio sources to labels; fmtResolution() — maps "0x0" to "Auto"
ResolutionPopup (ResolutionPopup.qml)
Aspect	Detail
Base	CardWindow
Layer namespace	"omarchy-resolution"
Reveal binding	root.resolutionPopupVisible
Width	320px
Height	280px (fixed)
Title	"RECORDING" (color: root.seal)
Subtitle	"SELECT RESOLUTION"
Footer	"↵ START  ·  ESC CLOSE"
Options (Repeater, 5 items):	 
1. "Auto (native)" → value "" (no --resolution flag)	 
2. "1920 × 1080" → value "1920x1080"	 
3. "2560 × 1440" → value "2560x1440"	 
4. "3840 × 2160 (4K)" → value "3840x2160"	 
5. "Select region…" → value null (calls startRecording() with no arg)	 
Click action	Closes popup, calls root.startRecording(value) or root.startRecording() for region mode
Decorative icon	Right-side icoVideoCam glyph per row
8. POST-RECORDING ACTIONS
When a recording ends normally (via stopRecording() → SIGINT):
1. The recording probe (2 Hz) detects the gpu-screen-recorder process is gone
2. Since _recordingStoppedNormally is true:
- _recordingStoppedNormally is reset to false
- openAfterRecording timer starts (2-second delay, giving the file time to finalize)
3. When openAfterRecording fires:
- Executes notify-send -t 2500 'Recording saved' — a desktop notification
- Extracts the parent directory from recordingOutput path
- Executes xdg-open <path> — opens the file manager to the recording's save location
When cancelled (via cancelRecording()):
- SIGKILL terminates the process immediately
- The output file (read from /tmp/omarchy-screenrecord-filename) is deleted
- The temp marker file itself is deleted
- No notification, no file-manager open
9. OMARCHY CAPTURE COMMAND INTERFACE
The recording relies on the external omarchy capture shell command:
- omarchy capture screenrecording — starts recording at native resolution
- omarchy capture screenrecording --resolution=<WxH> — starts recording at specified resolution
- Environment variable OMARCHY_SCREENRECORD_USE_PORTAL=true can be set to use the portal (XDG Desktop Portal) path
The actual recording engine is gpu-screen-recorder under the hood. Quickshell interacts with it solely via process detection (pgrep -f '^gpu-screen-recorder') and signal-based control (SIGINT for clean stop, SIGKILL for cancel).
A coordination file at /tmp/omarchy-screenrecord-filename stores the output file path, allowing cancellation to find and delete the in-progress file.
10. WAYBAR TOGGLE MECHANISM
No Waybar toggle mechanism was found in the Quickshell desktop files or in autostart.conf. The file /home/mehdi/.config/hypr/autostart.conf exists but contains only a comment placeholder (2 lines). The Data.js entry { title: "Toggle Top Bar", ...exec: "omarchy-toggle-waybar" } (line 223) references an external shell script, not a Quickshell IPC call. There is no IpcHandler for a "waybar" target in Navbar.qml. The recording feature does not interact with or depend on any Waybar toggle mechanism.
11. OTHER FILES TOUCHED BY RECORDING FEATURE
File	Recording relevance
/home/mehdi/.config/quickshell/desktop/Data.js	Line 82: "Capture" category includes screen recording keywords; Line 103: "Videos" Quick tile references recordings; Line 236: "Screen Record" item in Capture category
/home/mehdi/.config/quickshell/desktop/NavbarApps.qml	Line 21: "Videos" navbar app includes "recordings" and "screen record" keywords
/home/mehdi/.config/quickshell/desktop/OmniMenu.qml	Line 141: Videos tile includes "recordings" keywords
No other files in the desktop directory (CardWindow.qml, Separator.qml, Module.qml, Theme.qml, etc.) contain recording-specific code.
SUMMARY TABLE — RECORDING FEATURE SCOPE
Category	Count	Details
New files created	2	RecordingPopup.qml, ResolutionPopup.qml
Files modified	2	Navbar.qml (+60 lines), Bar.qml (+60 lines)
New properties added	11	9 state properties + 2 anchor items
New functions added	6	openRecordingPopup, takeScreenshot, startRecording, openResolutionPopup, stopRecording, cancelRecording
New Process probes	1	recordingProbe (2 Hz)
Timers added	2	recordingDurationTimer (1 Hz), openAfterRecording (2s single-shot)
New icon codepoints	2	0xf111 (icoRecording), 0xf003d (icoVideoCam)
New QML surfaces registered	2	RecordingPopup, ResolutionPopup
Shell commands used	4	omarchy capture screenrecording, pkill -SIGINT gpusr, pkill -9 gpu, notify-send, xdg-open
Temp file used	1	/tmp/omarchy-screenrecord-filename
External dependencies	1	gpu-screen-recorder (launched via omarchy capture)