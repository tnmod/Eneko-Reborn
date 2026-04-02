//
//  EnekoHelpers.h
//  Eneko - Helper function declarations
//

#import "../EnekoGlobals.h"

// Day/Night
BOOL isDaytime(void);
NSURL* getVideoURLForScreen(NSString* dayKey, NSString* nightKey);

// Fade & Visibility
void fadeOutLayer(CALayer* layer);
void ensureLayerVisible(CALayer* layer);

// Dim Overlay
CALayer* createDimLayer(CGRect frame);

// Parallax
void startParallaxUpdates(void);
void stopParallaxUpdates(void);

// Blur
void showBlurOnHomeScreen(UIView* view);
void hideBlurOnHomeScreen(void);

// Playlist
void swapLockScreenVideo(void);
void swapHomeScreenVideo(void);

// Idle Timer
void cancelIdleTimer(void);
void idleTimerFired(void);
void resetIdleTimer(void);

// Thermal
void handleThermalStateChange(void);

// Playback
BOOL shouldSuppressPlayback(void);

// Tap to Wake
void handleTapToWakeForLockScreen(void);
void handleTapToWakeForHomeScreen(void);
