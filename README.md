# MuxTune Player

A modern desktop music player built with Flutter.

## Getting Started

MuxTune Player is a desktop music application designed to provide a simple and enjoyable local music playback experience.

## Features

- Local music library management
- Audio playback powered by MPV
- Playback controls
- Windows desktop support

## Downloads

Download the latest version of MuxTune Player for Windows from the [GitHub Releases](https://github.com/ashford232/maxtune_player/releases) page.

Download the installer, run it, and follow the setup instructions to install MuxTune Player.

## Development

Make sure you have Flutter installed and configured.

Clone the repository:

```bash
git clone https://github.com/ashford232/maxtune_player.git
cd maxtune_player
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run -d windows
```

## Building for Windows

```bash
flutter build windows --release
```

The release build is generated in:

```text
build/windows/x64/runner/Release/
```

## Requirements

- Windows 10 or later
- Flutter SDK
- Dart SDK
- MPV audio dependencies

## License

See the LICENSE file for licensing information.