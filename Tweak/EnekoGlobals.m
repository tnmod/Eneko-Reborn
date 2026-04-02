//
//  EnekoGlobals.m
//  Eneko - Global variable definitions
//

#import "EnekoGlobals.h"

// State flags
BOOL isLockScreenVisible = YES;
BOOL isHomeScreenVisible = NO;
BOOL isScreenOn = YES;
BOOL isInCall = NO;
BOOL isInLowPowerMode = NO;
BOOL isIdlePaused = NO;
BOOL wasDaytimeLastCheck = YES;

// Lock Screen Player
AVQueuePlayer* lockScreenPlayer;
AVPlayerItem* lockScreenPlayerItem;
AVPlayerLooper* lockScreenPlayerLooper;
AVPlayerLayer* lockScreenPlayerLayer;
CALayer* lockScreenDimLayer;

// Home Screen Player
AVQueuePlayer* homeScreenPlayer;
AVPlayerItem* homeScreenPlayerItem;
AVPlayerLooper* homeScreenPlayerLooper;
AVPlayerLayer* homeScreenPlayerLayer;
CALayer* homeScreenDimLayer;

// Blur on App Open
UIVisualEffectView* homeScreenBlurView;

// Idle timer
NSTimer* idleTimer;

// isPlaying cache
BOOL cachedIsPlaying = NO;
BOOL cachedIsPlayingValid = NO;

// Parallax
CMMotionManager* motionManager;

// Playlist
NSInteger lockScreenPlaylistIndex = 0;
NSInteger homeScreenPlaylistIndex = 0;

// Preferences
NSUserDefaults* preferences;
BOOL pfEnabled;
BOOL pfEnableLockScreenWallpaper;
CGFloat pfLockScreenVolume;
BOOL pfEnableHomeScreenWallpaper;
CGFloat pfHomeScreenVolume;
BOOL pfZoomWallpaper;
BOOL pfMuteWhenMusicPlays;
BOOL pfDisableInLowPowerMode;
CGFloat pfIdleTimeout;
CGFloat pfDimOpacity;
BOOL pfEnableFadeTransition;
CGFloat pfFadeDuration;
BOOL pfEnableDayNight;
BOOL pfEnableBlurOnAppOpen;
BOOL pfEnablePlaylist;
BOOL pfEnableParallax;
CGFloat pfParallaxIntensity;
