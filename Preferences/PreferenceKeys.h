//
//  PreferenceKeys.h
//  Eneko
//
//  Created by Alexandra (@Traurige)
//

static NSString* const kPreferencesIdentifier = @"dev.traurige.eneko.preferences";

// Core
static NSString* const kPreferenceKeyEnabled = @"Enabled";

// Lock Screen
static NSString* const kPreferenceKeyEnableLockScreenWallpaper = @"EnableLockScreenWallpaper";
static NSString* const kPreferenceKeyLockScreenWallpaper = @"LockScreenWallpaper";
static NSString* const kPreferenceKeyLockScreenVolume = @"LockScreenVolume";
static NSString* const kPreferenceKeyLockScreenWallpaperNight = @"LockScreenWallpaperNight";

// Home Screen
static NSString* const kPreferenceKeyEnableHomeScreenWallpaper = @"EnableHomeScreenWallpaper";
static NSString* const kPreferenceKeyHomeScreenWallpaper = @"HomeScreenWallpaper";
static NSString* const kPreferenceKeyHomeScreenVolume = @"HomeScreenVolume";
static NSString* const kPreferenceKeyHomeScreenWallpaperNight = @"HomeScreenWallpaperNight";
static NSString* const kPreferenceKeyZoomWallpaper = @"ZoomWallpaper";

// Behavior
static NSString* const kPreferenceKeyMuteWhenMusicPlays = @"MuteWhenMusicPlays";
static NSString* const kPreferenceKeyDisableInLowPowerMode = @"DisableInLowPowerMode";
static NSString* const kPreferenceKeyIdleTimeout = @"IdleTimeout";

// Dim Overlay
static NSString* const kPreferenceKeyDimOpacity = @"DimOpacity";

// Fade Transition
static NSString* const kPreferenceKeyEnableFadeTransition = @"EnableFadeTransition";
static NSString* const kPreferenceKeyFadeDuration = @"FadeDuration";

// Day/Night
static NSString* const kPreferenceKeyEnableDayNight = @"EnableDayNight";

// Blur on App Open
static NSString* const kPreferenceKeyEnableBlurOnAppOpen = @"EnableBlurOnAppOpen";

// Playlist Mode
static NSString* const kPreferenceKeyEnablePlaylist = @"EnablePlaylist";

// Parallax
static NSString* const kPreferenceKeyEnableParallax = @"EnableParallax";
static NSString* const kPreferenceKeyParallaxIntensity = @"ParallaxIntensity";


// Default values
static BOOL const kPreferenceKeyEnabledDefaultValue = YES;
static BOOL const kPreferenceKeyEnableLockScreenWallpaperDefaultValue = NO;
static CGFloat const kPreferenceKeyLockScreenVolumeDefaultValue = 0;
static BOOL const kPreferenceKeyEnableHomeScreenWallpaperDefaultValue = NO;
static CGFloat const kPreferenceKeyHomeScreenVolumeDefaultValue = 0;
static BOOL const kPreferenceKeyZoomWallpaperDefaultValue = YES;
static BOOL const kPreferenceKeyMuteWhenMusicPlaysDefaultValue = YES;
static BOOL const kPreferenceKeyDisableInLowPowerModeDefaultValue = YES;
static CGFloat const kPreferenceKeyIdleTimeoutDefaultValue = 30;
static CGFloat const kPreferenceKeyDimOpacityDefaultValue = 0;
static BOOL const kPreferenceKeyEnableFadeTransitionDefaultValue = YES;
static CGFloat const kPreferenceKeyFadeDurationDefaultValue = 0.3;
static BOOL const kPreferenceKeyEnableDayNightDefaultValue = NO;
static BOOL const kPreferenceKeyEnableBlurOnAppOpenDefaultValue = YES;
static BOOL const kPreferenceKeyEnablePlaylistDefaultValue = NO;
static BOOL const kPreferenceKeyEnableParallaxDefaultValue = NO;
static CGFloat const kPreferenceKeyParallaxIntensityDefaultValue = 10;
