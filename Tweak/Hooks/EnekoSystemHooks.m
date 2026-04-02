//
//  EnekoSystemHooks.m
//  Eneko - Media, Call, Siri, Camera, Modal, Emergency, Low Power hooks
//

#import "../EnekoGlobals.h"
#import "../Helpers/EnekoHelpers.h"

#pragma mark - Media Controller

static BOOL (* orig_SBMediaController_isPlaying)(SBMediaController* self, SEL _cmd);
static BOOL override_SBMediaController_isPlaying(SBMediaController* self, SEL _cmd) {
    if (pfLockScreenVolume == 0 && pfHomeScreenVolume == 0) return orig_SBMediaController_isPlaying(self, _cmd);
    BOOL orig = orig_SBMediaController_isPlaying(self, _cmd);
    if (cachedIsPlayingValid && orig == cachedIsPlaying) return orig;
    cachedIsPlaying = orig;
    cachedIsPlayingValid = YES;
    if (orig) {
        if (lockScreenPlayer && ![lockScreenPlayer isMuted] && pfMuteWhenMusicPlays) [lockScreenPlayer setVolume:0];
        if (homeScreenPlayer && ![homeScreenPlayer isMuted] && pfMuteWhenMusicPlays) [homeScreenPlayer setVolume:0];
    } else {
        if (lockScreenPlayer && ![lockScreenPlayer isMuted] && pfMuteWhenMusicPlays) [lockScreenPlayer setVolume:pfLockScreenVolume];
        if (homeScreenPlayer && ![homeScreenPlayer isMuted] && pfMuteWhenMusicPlays) [homeScreenPlayer setVolume:pfHomeScreenVolume];
    }
    return orig;
}

#pragma mark - Phone Call

static int (* orig_TUCall_status)(TUCall* self, SEL _cmd);
static int override_TUCall_status(TUCall* self, SEL _cmd) {
    if (pfDisableInLowPowerMode && isInLowPowerMode) return orig_TUCall_status(self, _cmd);
    int orig = orig_TUCall_status(self, _cmd);
    if (orig != 6) {
        isInCall = YES;
        if (lockScreenPlayer) [lockScreenPlayer pause];
        if (homeScreenPlayer) [homeScreenPlayer pause];
        cancelIdleTimer();
        stopParallaxUpdates();
    } else if (orig == 6) {
        isInCall = NO;
        if (isLockScreenVisible && !isHomeScreenVisible) {
            if (lockScreenPlayer) [lockScreenPlayer play];
            if (homeScreenPlayer) [homeScreenPlayer pause];
        } else if (!isLockScreenVisible && isHomeScreenVisible) {
            if (homeScreenPlayer) [homeScreenPlayer play];
            if (lockScreenPlayer) [lockScreenPlayer pause];
        }
        resetIdleTimer();
        if (pfEnableParallax) startParallaxUpdates();
    }
    return orig;
}

#pragma mark - Siri

static void (* orig_SiriUIBackgroundBlurView_removeFromSuperview)(SiriUIBackgroundBlurView* self, SEL _cmd);
static void override_SiriUIBackgroundBlurView_removeFromSuperview(SiriUIBackgroundBlurView* self, SEL _cmd) {
    orig_SiriUIBackgroundBlurView_removeFromSuperview(self, _cmd);
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer && isLockScreenVisible && !isHomeScreenVisible) [lockScreenPlayer play];
    else if (homeScreenPlayer && isHomeScreenVisible && !isLockScreenVisible) [homeScreenPlayer play];
    resetIdleTimer();
}

#pragma mark - Camera Page

static void (* orig_SBDashBoardCameraPageViewController_viewDidAppear)(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated);
static void override_SBDashBoardCameraPageViewController_viewDidAppear(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated) {
    orig_SBDashBoardCameraPageViewController_viewDidAppear(self, _cmd, animated);
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer && isLockScreenVisible) {
        fadeOutLayer(lockScreenPlayerLayer);
        [lockScreenPlayer pause];
    }
    isLockScreenVisible = NO;
    cancelIdleTimer();
    stopParallaxUpdates();
}

static void (* orig_SBDashBoardCameraPageViewController_viewDidDisappear)(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated);
static void override_SBDashBoardCameraPageViewController_viewDidDisappear(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated) {
    orig_SBDashBoardCameraPageViewController_viewDidDisappear(self, _cmd, animated);
    isLockScreenVisible = YES;
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer && isLockScreenVisible) {
        ensureLayerVisible(lockScreenPlayerLayer);
        [lockScreenPlayer play];
    }
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}

#pragma mark - Modal Button

static void (* orig_CSModalButton_didMoveToWindow)(CSModalButton* self, SEL _cmd);
static void override_CSModalButton_didMoveToWindow(CSModalButton* self, SEL _cmd) {
    orig_CSModalButton_didMoveToWindow(self, _cmd);
    if (shouldSuppressPlayback()) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (lockScreenPlayer) [lockScreenPlayer pause];
        if (homeScreenPlayer) [homeScreenPlayer pause];
        cancelIdleTimer();
    });
}

static void (* orig_CSModalButton_removeFromSuperview)(CSModalButton* self, SEL _cmd);
static void override_CSModalButton_removeFromSuperview(CSModalButton* self, SEL _cmd) {
    orig_CSModalButton_removeFromSuperview(self, _cmd);
    if (shouldSuppressPlayback()) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (lockScreenPlayer) [lockScreenPlayer play];
        if (homeScreenPlayer) [homeScreenPlayer pause];
        resetIdleTimer();
    });
}

#pragma mark - Emergency Call

static void (* orig_SBLockScreenEmergencyCallViewController_viewWillAppear)(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated);
static void override_SBLockScreenEmergencyCallViewController_viewWillAppear(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated) {
    orig_SBLockScreenEmergencyCallViewController_viewWillAppear(self, _cmd, animated);
    isLockScreenVisible = NO;
    if (lockScreenPlayer) [lockScreenPlayer pause];
}

static void (* orig_SBLockScreenEmergencyCallViewController_viewWillDisappear)(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated);
static void override_SBLockScreenEmergencyCallViewController_viewWillDisappear(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated) {
    orig_SBLockScreenEmergencyCallViewController_viewWillDisappear(self, _cmd, animated);
    isLockScreenVisible = YES;
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer) [lockScreenPlayer play];
    resetIdleTimer();
}

#pragma mark - Low Power Mode

static BOOL (* orig_NSProcessInfo_isLowPowerModeEnabled)(NSProcessInfo* self, SEL _cmd);
static BOOL override_NSProcessInfo_isLowPowerModeEnabled(NSProcessInfo* self, SEL _cmd) {
    if (!pfDisableInLowPowerMode) return orig_NSProcessInfo_isLowPowerModeEnabled(self, _cmd);
    isInLowPowerMode = orig_NSProcessInfo_isLowPowerModeEnabled(self, _cmd);
    if (isInLowPowerMode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (lockScreenPlayer) { [lockScreenPlayerLayer setHidden:YES]; [lockScreenPlayer pause]; }
            if (homeScreenPlayer) { [homeScreenPlayerLayer setHidden:YES]; [homeScreenPlayer pause]; }
            cancelIdleTimer();
            stopParallaxUpdates();
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (lockScreenPlayer && isLockScreenVisible) { [lockScreenPlayer play]; [lockScreenPlayerLayer setHidden:NO]; }
            else if (homeScreenPlayer && isHomeScreenVisible) { [homeScreenPlayer play]; [homeScreenPlayerLayer setHidden:NO]; }
            resetIdleTimer();
            if (pfEnableParallax) startParallaxUpdates();
        });
    }
    return isInLowPowerMode;
}

#pragma mark - Hook Registration

void registerSystemHooks() {
    MSHookMessageEx(objc_getClass("SBMediaController"), @selector(isPlaying), (IMP)&override_SBMediaController_isPlaying, (IMP *)&orig_SBMediaController_isPlaying);
    MSHookMessageEx(objc_getClass("TUCall"), @selector(status), (IMP)&override_TUCall_status, (IMP *)&orig_TUCall_status);
    MSHookMessageEx(objc_getClass("SiriUIBackgroundBlurView"), @selector(removeFromSuperview), (IMP)&override_SiriUIBackgroundBlurView_removeFromSuperview, (IMP *)&orig_SiriUIBackgroundBlurView_removeFromSuperview);
    MSHookMessageEx(objc_getClass("SBDashBoardCameraPageViewController"), @selector(viewDidAppear:), (IMP)&override_SBDashBoardCameraPageViewController_viewDidAppear, (IMP *)&orig_SBDashBoardCameraPageViewController_viewDidAppear);
    MSHookMessageEx(objc_getClass("SBDashBoardCameraPageViewController"), @selector(viewDidDisappear:), (IMP)&override_SBDashBoardCameraPageViewController_viewDidDisappear, (IMP *)&orig_SBDashBoardCameraPageViewController_viewDidDisappear);
    MSHookMessageEx(objc_getClass("CSModalButton"), @selector(didMoveToWindow), (IMP)&override_CSModalButton_didMoveToWindow, (IMP *)&orig_CSModalButton_didMoveToWindow);
    MSHookMessageEx(objc_getClass("CSModalButton"), @selector(removeFromSuperview), (IMP)&override_CSModalButton_removeFromSuperview, (IMP *)&orig_CSModalButton_removeFromSuperview);
    MSHookMessageEx(objc_getClass("SBLockScreenEmergencyCallViewController"), @selector(viewWillAppear:), (IMP)&override_SBLockScreenEmergencyCallViewController_viewWillAppear, (IMP *)&orig_SBLockScreenEmergencyCallViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("SBLockScreenEmergencyCallViewController"), @selector(viewWillDisappear:), (IMP)&override_SBLockScreenEmergencyCallViewController_viewWillDisappear, (IMP *)&orig_SBLockScreenEmergencyCallViewController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("NSProcessInfo"), @selector(isLowPowerModeEnabled), (IMP)&override_NSProcessInfo_isLowPowerModeEnabled, (IMP *)&orig_NSProcessInfo_isLowPowerModeEnabled);
}

