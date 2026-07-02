# Sliderz

A Flutter MIDI controller for iPhone and iPad, inspired by the KORG nanoKONTROL2. Control faders, knobs, transport, and channel buttons from your iOS device — including over Wi‑Fi to a Mac running MainStage or another DAW.

## Features

- **8 color-coded channel strips** — fader, pan knob, and Solo / Mute / Record buttons per channel
- **Transport panel** — track navigation, markers, cycle, and playback controls
- **MIDI virtual port** — appears as **"Sliderz"** on the same device for local apps
- **Network MIDI (Wi‑Fi)** — send MIDI to a Mac over RTP-MIDI (no bridge app required)
- **nanoKONTROL2 CC mapping** — default control change assignments for DAW compatibility
- **Landscape-first UI** — dark neumorphic design optimized for performance use

## Requirements

- Flutter SDK `^3.11.5`
- iOS 13.1+ (primary target)
- Mac and iOS device on the **same Wi‑Fi network** for MainStage / DAW control

## Getting started

```bash
git clone <your-repo-url>
cd sliderz
flutter pub get
flutter run
```

For a clean install after icon or native changes:

```bash
flutter clean && flutter pub get && flutter run
```

## Connect to MainStage on Mac

1. On iPhone/iPad: open Sliderz → tap the **settings** icon → enable **MIDI por red (Wi‑Fi)**.
2. On Mac: open **Audio MIDI Setup** → **Window → Show MIDI Studio**.
3. Double-click **Network** → enable the session and check **Device is online**.
4. Connect your iOS device from the **Directory** list.
5. In **MainStage**: select the network MIDI input and use **Learn** to map controls.

Move a fader or knob in Sliderz and confirm MIDI arrives before mapping in MainStage.

## MIDI CC mapping

Default assignments follow the nanoKONTROL2 CC mode:

| Control | CC |
|---------|-----|
| Faders 1–8 | 0–7 |
| Knobs 1–8 | 16–23 |
| Solo 1–8 | 32–39 |
| Mute 1–8 | 48–55 |
| Record 1–8 | 64–71 |
| Track ← / → | 40 / 41 |
| Marker SET / ← / → | 43 / 44 / 45 |
| Cycle | 42 |
| Rewind / FF / Stop / Play / Record | 46 / 47 / 58 / 59 / 60 |

MIDI channel is selectable from the status bar (default: channel 1).

## Project structure

```
lib/
├── main.dart
├── core/injector.dart           # Dependency injection
├── common/components/           # Shared UI (knob, fader, button)
├── controller/
│   ├── blocs/                   # Business logic
│   ├── components/              # Feature UI
│   ├── models/
│   └── screens/
├── midi/
│   ├── models/                  # CC mappings
│   └── services/                # MIDI I/O
└── theme/
```

## App icon

Icons are generated from `assets/app_icon.png` using [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons):

```bash
dart run flutter_launcher_icons
```

## Bundle identifier

- **iOS / Android:** `com.sliderz.app`

## Tech stack

- [Flutter](https://flutter.dev)
- [flutter_midi_command](https://pub.dev/packages/flutter_midi_command) — CoreMIDI / virtual MIDI / network session on iOS

## License

Private project — not published to pub.dev.
