//
//  EnekoLifecycleHooks.m
//  Eneko - viewWillAppear/Disappear, Control Center, Backlight, Lock Manager, Rotation
//

#import "../EnekoGlobals.h"
#import "../Helpers/EnekoHelpers.h"

#pragma mark - Lock Screen Appear/Disappear

static void (* orig_CSCoverSheetViewController_viewWillAppear)(CSCoverSheetViewController* self, SEL _cmd, BOOL animated);
static void override_CSCoverSheetViewController_viewWillAppear(CSCoverSheetViewController* self, SEL _cmd, BOOL animated) {
    orig_CSCoverSheetViewController_viewWillAppear(self, _cmd, animated);
    isLockScreenVisible = YES;
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer) {
        [self adjustFrame];
        ensureLayerVisible(lockScreenPlayerLayer);
        [lockScreenPlayer play];
    }
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}

static void (* orig_CSCoverSheetViewController_viewDidDisappear)(CSCoverSheetViewController* self, SEL _cmd, BOOL animated);
static void override_CSCoverSheetViewController_viewDidDisappear(CSCoverSheetViewController* self, SEL _cmd, BOOL animated) {
    orig_CSCoverSheetViewController_viewDidDisappear(self, _cmd, animated);
    isLockScreenVisible = NO;
    if (shouldSuppressPlayback()) return;
    if (lockScreenPlayer) {
        fadeOutLayer(lockScreenPlayerLayer);
        [lockScreenPlayer pause];
    }
    if (homeScreenPlayer && isHomeScreenVisible) {
        ensureLayerVisible(homeScreenPlayerLayer);
        [homeScreenPlayer play];
        resetIdleTimer();
    }
}

#pragma mark - Home Screen Appear/Disappear

static void (* orig_SBIconController_viewWillAppear)(SBIconController* self, SEL _cmd, BOOL animated);
static void override_SBIconController_viewWillAppear(SBIconController* self, SEL _cmd, BOOL animated) {
    orig_SBIconController_viewWillAppear(self, _cmd, animated);
    isHomeScreenVisible = YES;
    if (shouldSuppressPlayback()) return;
    hideBlurOnHomeScreen();
    if (homeScreenPlayer) {
        [self adjustFrame];
        ensureLayerVisible(homeScreenPlayerLayer);
        [homeScreenPlayer play];
    }
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}

static void (* orig_SBIconController_viewWillDisappear)(SBIconController* self, SEL _cmd, BOOL animated);
static void override_SBIconController_viewWillDisappear(SBIconController* self, SEL _cmd, BOOL animated) {
    orig_SBIconController_viewWillDisappear(self, _cmd, animated);
    isHomeScreenVisible = NO;
    if (shouldSuppressPlayback()) return;
    if (homeScreenPlayer) {
        showBlurOnHomeScreen([self view]);
        fadeOutLayer(homeScreenPlayerLayer);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [homeScreenPlayer pause];
        });
    }
    if (lockScreenPlayer && isLockScreenVisible) {
        ensureLayerVisible(lockScreenPlayerLayer);
        [lockScreenPlayer play];
        resetIdleTimer();
    }
    stopParallaxUpdates();
}

#pragma mark - Control Center

static void (* orig_CC_viewWillAppear)(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated);
static void override_CC_viewWillAppear(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated) {
    orig_CC_viewWillAppear(self, _cmd, animated);
    if (shouldSuppressPlayback()) return;
    // Only pause home screen; lock screen keeps playing behind CC
    if (homeScreenPlayer && isHomeScreenVisible) [homeScreenPlayer pause];
}

static void (* orig_CC_viewWillDisappear)(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated);
static void override_CC_viewWillDisappear(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated) {
    orig_CC_viewWillDisappear(self, _cmd, animated);
    if (shouldSuppressPlayback()) return;
    if (homeScreenPlayer && isHomeScreenVisible) [homeScreenPlayer play];
    resetIdleTimer();
}

#pragma mark - Screen On/Off

static void (* orig_SBBacklightController_turnOnScreenFullyWithBacklightSource)(SBBacklightController* self, SEL _cmd, int source);
static void override_SBBacklightController_turnOnScreenFullyWithBacklightSource(SBBacklightController* self, SEL _cmd, int source) {
    orig_SBBacklightController_turnOnScreenFullyWithBacklightSource(self, _cmd, source);
    if (isScreenOn) return;
    isScreenOn = YES;
    isLockScreenVisible = YES;
    isIdlePaused = NO;
    if (shouldSuppressPlayback()) return;
    if (pfEnableDayNight) {
        BOOL currentlyDaytime = isDaytime();
        if (currentlyDaytime != wasDaytimeLastCheck) {
            wasDaytimeLastCheck = currentlyDaytime;
            swapLockScreenVideo();
            swapHomeScreenVideo();
        }
    }
    if (pfEnablePlaylist && !pfEnableDayNight) {
        swapLockScreenVideo();
        swapHomeScreenVideo();
    }
    if (lockScreenPlayer) {
        ensureLayerVisible(lockScreenPlayerLayer);
        [lockScreenPlayer play];
    }
    if (homeScreenPlayer) [homeScreenPlayer pause];
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}

static void (* orig_SBLockScreenManager_lockUIFromSource_withOptions)(SBLockScreenManager* self, SEL _cmd, int source, id options);
static void override_SBLockScreenManager_lockUIFromSource_withOptions(SBLockScreenManager* self, SEL _cmd, int source, id options) {
    orig_SBLockScreenManager_lockUIFromSource_withOptions(self, _cmd, source, options);
    isScreenOn = NO;
    if (lockScreenPlayer) {
        fadeOutLayer(lockScreenPlayerLayer);
        [lockScreenPlayer pause];
    }
    if (homeScreenPlayer) {
        fadeOutLayer(homeScreenPlayerLayer);
        [homeScreenPlayer pause];
    }
    cancelIdleTimer();
    stopParallaxUpdates();
}

#pragma mark - Screen Rotation

static void (* orig_SpringBoard_noteInterfaceOrientationChanged)(SpringBoard* self, SEL _cmd, long long orientation, double duration, NSString* logMessage);
static void override_SpringBoard_noteInterfaceOrientationChanged(SpringBoard* self, SEL _cmd, long long orientation, double duration, NSString* logMessage) {
    orig_SpringBoard_noteInterfaceOrientationChanged(self, _cmd, orientation, duration, logMessage);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enekoScreenRotated" object:nil];
    });
}

#pragma mark - Hook Registration

void registerLifecycleHooks() {
    MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewWillAppear:), (IMP)&override_CSCoverSheetViewController_viewWillAppear, (IMP *)&orig_CSCoverSheetViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewDidDisappear:), (IMP)&override_CSCoverSheetViewController_viewDidDisappear, (IMP *)&orig_CSCoverSheetViewController_viewDidDisappear);
    MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewWillAppear:), (IMP)&override_SBIconController_viewWillAppear, (IMP *)&orig_SBIconController_viewWillAppear);
    MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewWillDisappear:), (IMP)&override_SBIconController_viewWillDisappear, (IMP *)&orig_SBIconController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("CCUIModularControlCenterOverlayViewController"), @selector(viewWillAppear:), (IMP)&override_CC_viewWillAppear, (IMP *)&orig_CC_viewWillAppear);
    MSHookMessageEx(objc_getClass("CCUIModularControlCenterOverlayViewController"), @selector(viewWillDisappear:), (IMP)&override_CC_viewWillDisappear, (IMP *)&orig_CC_viewWillDisappear);
    MSHookMessageEx(objc_getClass("SBBacklightController"), @selector(turnOnScreenFullyWithBacklightSource:), (IMP)&override_SBBacklightController_turnOnScreenFullyWithBacklightSource, (IMP *)&orig_SBBacklightController_turnOnScreenFullyWithBacklightSource);
    MSHookMessageEx(objc_getClass("SBLockScreenManager"), @selector(lockUIFromSource:withOptions:), (IMP)&override_SBLockScreenManager_lockUIFromSource_withOptions, (IMP *)&orig_SBLockScreenManager_lockUIFromSource_withOptions);
    MSHookMessageEx(objc_getClass("SpringBoard"), @selector(noteInterfaceOrientationChanged:duration:logMessage:), (IMP)&override_SpringBoard_noteInterfaceOrientationChanged, (IMP *)&orig_SpringBoard_noteInterfaceOrientationChanged);
}
