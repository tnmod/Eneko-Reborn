//
//  EnekoGlobals.h
//  Eneko - Shared global variable declarations
//

#import <substrate.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GcUniversal/GcImagePickerUtils.h"
#import "../Preferences/PreferenceKeys.h"
#import "../Preferences/NotificationKeys.h"
#import "Eneko.h"

// State flags
extern BOOL isLockScreenVisible;
extern BOOL isHomeScreenVisible;
extern BOOL isScreenOn;
extern BOOL isInCall;
extern BOOL isInLowPowerMode;
extern BOOL isIdlePaused;
extern BOOL wasDaytimeLastCheck;

// Lock Screen Player
extern AVQueuePlayer* lockScreenPlayer;
extern AVPlayerItem* lockScreenPlayerItem;
extern AVPlayerLooper* lockScreenPlayerLooper;
extern AVPlayerLayer* lockScreenPlayerLayer;
extern CALayer* lockScreenDimLayer;

// Home Screen Player
extern AVQueuePlayer* homeScreenPlayer;
extern AVPlayerItem* homeScreenPlayerItem;
extern AVPlayerLooper* homeScreenPlayerLooper;
extern AVPlayerLayer* homeScreenPlayerLayer;
extern CALayer* homeScreenDimLayer;

// Blur on App Open
extern UIVisualEffectView* homeScreenBlurView;

// Idle timer
extern NSTimer* idleTimer;

// isPlaying cache
extern BOOL cachedIsPlaying;
extern BOOL cachedIsPlayingValid;

// Parallax
extern CMMotionManager* motionManager;

// Playlist
extern NSInteger lockScreenPlaylistIndex;
extern NSInteger homeScreenPlaylistIndex;

// Preferences
extern NSUserDefaults* preferences;
extern BOOL pfEnabled;
extern BOOL pfEnableLockScreenWallpaper;
extern CGFloat pfLockScreenVolume;
extern BOOL pfEnableHomeScreenWallpaper;
extern CGFloat pfHomeScreenVolume;
extern BOOL pfZoomWallpaper;
extern BOOL pfMuteWhenMusicPlays;
extern BOOL pfDisableInLowPowerMode;
extern CGFloat pfIdleTimeout;
extern CGFloat pfDimOpacity;
extern BOOL pfEnableFadeTransition;
extern CGFloat pfFadeDuration;
extern BOOL pfEnableDayNight;
extern BOOL pfEnableBlurOnAppOpen;
extern BOOL pfEnablePlaylist;
extern BOOL pfEnableParallax;
extern CGFloat pfParallaxIntensity;
