# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Sliderz is a Flutter MIDI controller app for iPhone/iPad (inspired by the KORG nanoKONTROL2). It sends MIDI Control Change messages over **USB** (CoreMIDI/IDAM) to a Mac, DAW, or MIDI app. iOS is the primary target; landscape-only UI.

Bundle identifier (iOS/Android): `com.sliderz.app`.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run on connected device/simulator
flutter test                    # run all tests
flutter test test/components/midi_fader_test.dart   # run a single test file
flutter test --plain-name "some test name"           # run a single test by name
flutter analyze                 # static analysis / lints
dart format .                   # format code
dart run flutter_launcher_icons # regenerate app icons from assets/app_icon.png
flutter clean && flutter pub get && flutter run       # clean rebuild (after icon/native changes)
```

There is no CI config in this repo; `flutter analyze` and `flutter test` are the checks to run before considering a change done.

## Architecture

Strict layering: **UI → Bloc → Service**. UI widgets never talk to `MidiService` directly for state changes; they go through `ControllerBloc`. `MidiService` is the only layer that touches the `flutter_midi_command` plugin.

- **`lib/core/injector.dart`** — Manual DI singleton (`Injector.instance`). Call `Injector.instance.init()` once in `main()` before `runApp`. Holds nullable `MidiService`/`ControllerBloc` fields and throws `StateError` if accessed before `init()`. Tests call `init(midiService: MidiService.testing())` to inject a fake, non-platform service instead of the real plugin.
- **`lib/midi/services/midi_service.dart`** — `MidiService extends ChangeNotifier`. Wraps `MidiCommand` from `flutter_midi_command`. Handles device discovery/auto-reconnect, USB-only transport policy (BLE/network transports explicitly excluded), output device selection, and raw CC sending (`sendCc`/`sendCcPress`/`sendCcRelease`). Has a `usePlatform: false` constructor path (`MidiService.testing()`) that skips all native plugin calls so it's safe to instantiate in widget tests. Guards all native calls with `_disposed`/`_ready` checks since setup is async.
- **`lib/midi/models/nanokontrol2_mapping.dart`** — `NanoKontrol2Mapping`: static CC number tables (per-channel fader/knob/solo/mute/record arrays, plus transport CCs). This is the single source of truth for CC assignments — see the README table for the human-readable mapping.
- **`lib/controller/blocs/controller_bloc.dart`** — `ControllerBloc extends ChangeNotifier`. Holds the 8 `ChannelState`s, is the only class allowed to call `MidiService.sendCc*`, and translates UI actions (fader/knob move, solo/mute/record toggle, transport button) into CC sends via `NanoKontrol2Mapping`. Transport buttons are momentary: `sendTransportMomentary` sends press then release after an 80ms delay.
- **`lib/controller/models/channel_state.dart`** — Immutable `ChannelState` (fader/knob values, solo/mute/record flags) with `copyWith`.
- **`lib/controller/screens/controller_screen.dart`** — Top-level screen. Rebuilds via `ListenableBuilder(listenable: Listenable.merge([controllerBloc, midiService]))`. Contains the responsive layout logic that switches between an `Expanded` channel row and a horizontally-scrollable "compact" row based on available width vs. `AppTouch.channelStripMinWidth`.
- **`lib/controller/components/`** — Feature UI (channel strip, status bar, transport panel, MIDI connection sheet). Feature-level shared UI belongs under `components/`, not `widgets/`.
- **`lib/common/components/`** — Cross-feature reusable primitives (`MidiButton`, `MidiFader`, `MidiKnob`) with shared decoration helpers for consistent styling/animation.
- **`lib/theme/app_theme.dart`** — App color palette, gradients, and layout constants (e.g. `AppTouch.transportPanelWidth`, `AppTouch.channelStripMinWidth`) used to drive the responsive layout.

## Testing conventions

- `test/helpers/test_app.dart` provides `pumpControlWidget`/`pumpSliderzApp`, which pump widgets inside a themed `MaterialApp` at a fixed landscape surface size (`kLandscapePhoneSize = Size(844, 390)`) — use these instead of raw `pumpWidget` for anything that depends on layout/theme.
- Widget tests that exercise `MidiService` should construct it via `MidiService.testing()` (no native plugin calls) rather than the default constructor.

## Code style (from `.cursor/rules/`)

- Separate concerns strictly: UI / Blocs / Services. Keep business logic out of widgets; keep widgets stateless where possible.
- One main public widget per file for anything non-trivial; extract UI building blocks into `lib/<feature>/components/<name>.dart` instead of private `_Widget` helpers at the bottom of a screen file. Use `components/`, never `widgets/`, for feature-level UI folders.
- For mutable UI state models, prefer `class X with ChangeNotifier` (mutate fields + `notifyListeners()`) over `ValueNotifier<X>`; reserve `ValueNotifier` for single simple values. Listen with `ListenableBuilder`/`AnimatedBuilder`/`Listenable.merge`.
- Functions: small (~20 lines), one thing per function, max 3 params, no boolean flag args, command-query separation, extract try/catch into their own functions.
- Comments explain WHY, not WHAT; no redundant or commented-out code.
- Intention-revealing, searchable, pronounceable names; verbs for functions/methods, nouns for classes.
