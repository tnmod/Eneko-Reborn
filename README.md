# Eneko Reborn
Live video wallpapers for iOS — forked & enhanced from [Traurige/Eneko](https://github.com/Traurige/Eneko)

## Preview
<img src="Preview.png" alt="Preview" />

## What's New in This Fork

### 🏗️ Modular Architecture
The original monolithic `Eneko.m` (~670 lines) has been completely refactored into a clean, modular structure:

| Module | Purpose |
|---|---|
| `EnekoInit.m` | Entry point — registers all hooks |
| `EnekoGlobals.m` | Shared state variables |
| `EnekoPreferences.m` | Preference loading & notification handling |
| `Helpers/EnekoHelpers.m` | Reusable utility functions (fade, parallax, idle timer, player setup) |
| `Hooks/EnekoLifecycleHooks.m` | Lock/unlock, screen on/off, cover sheet hooks |
| `Hooks/EnekoScreenHooks.m` | Lock screen & home screen wallpaper layer management |
| `Hooks/EnekoSystemHooks.m` | Media, phone call, Siri, camera, low power mode hooks |

### ✨ New Features
- **Day/Night Mode** — Automatically switches between day and night wallpapers based on time (6 AM – 6 PM)
- **Playlist Mode** — Cycles through videos in a folder on each unlock
- **Parallax Effect** — Gyroscope-driven motion parallax with configurable intensity
- **Wallpaper Catalogue** — Browse and download wallpapers directly from settings
- **Night Wallpaper Slots** — Separate wallpaper selection for lock screen & home screen night modes

### 🐛 Bug Fixes & Improvements
- Fixed video playback glitches during notification swiping
- Fixed parallax edge-revealing artifacts with proper edge clamping
- Improved fade transitions with `ensureLayerVisible()` helper
- Added `isPlaying` cache to reduce redundant media state checks
- Proper cleanup of motion manager and idle timer resources
- Better state management during phone calls, Siri, emergency screen, and camera

### ⚙️ Enhanced Settings
Redesigned preference pane with organized sections:
- **Lock Screen** — Enable/disable, wallpaper picker, night wallpaper, volume slider
- **Home Screen** — Enable/disable, wallpaper picker, night wallpaper, volume, zoom toggle
- **Behavior** — Mute on music, low power mode, idle timeout, day/night, playlist mode
- **Effects** — Dim opacity, fade transition, blur on app open, parallax effect & intensity

## Installation
1. Download the latest `deb` from the [releases](https://github.com/tnmod/Eneko-Reborn/releases)
2. Install via your preferred package manager or Filza

## Compatibility
iPhone, iPad and iPod running iOS/iPadOS 14 or later

## Compiling
  - [Theos](https://theos.dev/) is required to compile the project
  - Depends on [libGCUniversal](https://github.com/MrGcGamer/LibGcUniversalDocumentation)
  - You may want to edit the root `Makefile` to use your Theos SDK and toolchain

## Credits
- Original tweak by [Traurige (Alexandra)](https://github.com/Traurige/Eneko)
- Fork maintained by [tnmod](https://github.com/tnmod)

## License
[GPLv3](https://github.com/tnmod/Eneko-Reborn/blob/main/COPYING)
