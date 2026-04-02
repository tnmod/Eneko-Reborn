//
//  EnekoPreferences.m
//  Eneko - Preferences loading
//

#import "EnekoPreferences.h"

void load_preferences() {
    if (!preferences) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];
    }
    [preferences synchronize];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue),
        kPreferenceKeyEnableLockScreenWallpaper: @(kPreferenceKeyEnableLockScreenWallpaperDefaultValue),
        kPreferenceKeyLockScreenVolume: @(kPreferenceKeyLockScreenVolumeDefaultValue),
        kPreferenceKeyEnableHomeScreenWallpaper: @(kPreferenceKeyEnableHomeScreenWallpaperDefaultValue),
        kPreferenceKeyHomeScreenVolume: @(kPreferenceKeyHomeScreenVolumeDefaultValue),
        kPreferenceKeyZoomWallpaper: @(kPreferenceKeyZoomWallpaperDefaultValue),
        kPreferenceKeyMuteWhenMusicPlays: @(kPreferenceKeyMuteWhenMusicPlaysDefaultValue),
        kPreferenceKeyDisableInLowPowerMode: @(kPreferenceKeyDisableInLowPowerModeDefaultValue),
        kPreferenceKeyIdleTimeout: @(kPreferenceKeyIdleTimeoutDefaultValue),
        kPreferenceKeyDimOpacity: @(kPreferenceKeyDimOpacityDefaultValue),
        kPreferenceKeyEnableFadeTransition: @(kPreferenceKeyEnableFadeTransitionDefaultValue),
        kPreferenceKeyFadeDuration: @(kPreferenceKeyFadeDurationDefaultValue),
        kPreferenceKeyEnableDayNight: @(kPreferenceKeyEnableDayNightDefaultValue),
        kPreferenceKeyEnableBlurOnAppOpen: @(kPreferenceKeyEnableBlurOnAppOpenDefaultValue),
        kPreferenceKeyEnablePlaylist: @(kPreferenceKeyEnablePlaylistDefaultValue),
        kPreferenceKeyEnableParallax: @(kPreferenceKeyEnableParallaxDefaultValue),
        kPreferenceKeyParallaxIntensity: @(kPreferenceKeyParallaxIntensityDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
    pfEnableLockScreenWallpaper = [[preferences objectForKey:kPreferenceKeyEnableLockScreenWallpaper] boolValue];
    pfLockScreenVolume = [[preferences objectForKey:kPreferenceKeyLockScreenVolume] floatValue];
    pfEnableHomeScreenWallpaper = [[preferences objectForKey:kPreferenceKeyEnableHomeScreenWallpaper] boolValue];
    pfHomeScreenVolume = [[preferences objectForKey:kPreferenceKeyHomeScreenVolume] floatValue];
    pfZoomWallpaper = [[preferences objectForKey:kPreferenceKeyZoomWallpaper] boolValue];
    pfMuteWhenMusicPlays = [[preferences objectForKey:kPreferenceKeyMuteWhenMusicPlays] boolValue];
    pfDisableInLowPowerMode = [[preferences objectForKey:kPreferenceKeyDisableInLowPowerMode] boolValue];
    pfIdleTimeout = [[preferences objectForKey:kPreferenceKeyIdleTimeout] floatValue];
    pfDimOpacity = [[preferences objectForKey:kPreferenceKeyDimOpacity] floatValue];
    pfEnableFadeTransition = [[preferences objectForKey:kPreferenceKeyEnableFadeTransition] boolValue];
    pfFadeDuration = [[preferences objectForKey:kPreferenceKeyFadeDuration] floatValue];
    pfEnableDayNight = [[preferences objectForKey:kPreferenceKeyEnableDayNight] boolValue];
    pfEnableBlurOnAppOpen = [[preferences objectForKey:kPreferenceKeyEnableBlurOnAppOpen] boolValue];
    pfEnablePlaylist = [[preferences objectForKey:kPreferenceKeyEnablePlaylist] boolValue];
    pfEnableParallax = [[preferences objectForKey:kPreferenceKeyEnableParallax] boolValue];
    pfParallaxIntensity = [[preferences objectForKey:kPreferenceKeyParallaxIntensity] floatValue];

    cachedIsPlayingValid = NO;
}
