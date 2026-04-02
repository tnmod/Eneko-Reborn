//
//  EnekoHelpers.m
//  Eneko - All helper/utility functions
//

#import "EnekoHelpers.h"

#pragma mark - Day/Night

BOOL isDaytime() {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    return (hour >= 6 && hour < 18);
}

NSURL* getVideoURLForScreen(NSString* dayKey, NSString* nightKey) {
    if (pfEnableDayNight && !isDaytime()) {
        NSURL* nightURL = [GcImagePickerUtils videoURLFromDefaults:kPreferencesIdentifier withKey:nightKey];
        if (nightURL) return nightURL;
    }
    return [GcImagePickerUtils videoURLFromDefaults:kPreferencesIdentifier withKey:dayKey];
}

#pragma mark - Fade & Visibility

void fadeOutLayer(CALayer* layer) {
    if (!layer) return;
    [layer removeAllAnimations];
    if (!pfEnableFadeTransition) {
        [layer setOpacity:0.0];
        return;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:pfFadeDuration];
    [layer setOpacity:0.0];
    [CATransaction commit];
}

void ensureLayerVisible(CALayer* layer) {
    if (!layer) return;
    [layer removeAllAnimations];
    [layer setOpacity:1.0];
}

#pragma mark - Dim Overlay

CALayer* createDimLayer(CGRect frame) {
    if (pfDimOpacity <= 0) return nil;
    CALayer* dim = [CALayer layer];
    [dim setFrame:frame];
    [dim setBackgroundColor:[UIColor blackColor].CGColor];
    [dim setOpacity:pfDimOpacity];
    return dim;
}

#pragma mark - Parallax

void startParallaxUpdates() {
    if (!pfEnableParallax) return;
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
        [motionManager setDeviceMotionUpdateInterval:1.0/30.0];
    }
    if (![motionManager isDeviceMotionActive]) {
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
            withHandler:^(CMDeviceMotion* motion, NSError* error) {
                if (error) return;

                // Dynamic scale: higher intensity = larger scale to prevent edge reveal
                CGFloat scale = 1.0 + pfParallaxIntensity * 0.02;

                // Calculate raw translation from device tilt
                CGFloat rawX = motion.attitude.roll * pfParallaxIntensity;
                CGFloat rawY = motion.attitude.pitch * pfParallaxIntensity;

                // Clamp translation so video never reveals edges
                // Available buffer = (scale - 1.0) * dimension / 2 / scale
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                CGFloat maxX = (scale - 1.0) * screenSize.width * 0.5 / scale;
                CGFloat maxY = (scale - 1.0) * screenSize.height * 0.5 / scale;

                CGFloat x = fmax(-maxX, fmin(rawX, maxX));
                CGFloat y = fmax(-maxY, fmin(rawY, maxY));

                if (lockScreenPlayer && isLockScreenVisible && lockScreenPlayerLayer) {
                    CATransform3D transform = CATransform3DMakeScale(scale, scale, 1.0);
                    transform = CATransform3DTranslate(transform, x, y, 0);
                    [lockScreenPlayerLayer setTransform:transform];
                }
                if (homeScreenPlayer && isHomeScreenVisible && homeScreenPlayerLayer) {
                    CGFloat homeScale = pfZoomWallpaper ? fmax(scale, 1.15) : scale;
                    CATransform3D homeTransform = CATransform3DMakeScale(homeScale, homeScale, 1.0);
                    homeTransform = CATransform3DTranslate(homeTransform, x, y, 0);
                    [homeScreenPlayerLayer setTransform:homeTransform];
                }
        }];
    }
}

void stopParallaxUpdates() {
    if (motionManager && [motionManager isDeviceMotionActive]) {
        [motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark - Blur on App Open

void showBlurOnHomeScreen(UIView* view) {
    if (!pfEnableBlurOnAppOpen || !view) return;
    if (!homeScreenBlurView) {
        homeScreenBlurView = [[UIVisualEffectView alloc] initWithEffect:nil];
        [homeScreenBlurView setFrame:[view bounds]];
        [homeScreenBlurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    [homeScreenBlurView setFrame:[view bounds]];
    [view addSubview:homeScreenBlurView];

    [UIView animateWithDuration:0.3 animations:^{
        [homeScreenBlurView setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }];
}

void hideBlurOnHomeScreen() {
    if (!homeScreenBlurView) return;
    [UIView animateWithDuration:0.2 animations:^{
        [homeScreenBlurView setEffect:nil];
    } completion:^(BOOL finished) {
        [homeScreenBlurView removeFromSuperview];
    }];
}

#pragma mark - Playlist

void swapLockScreenVideo() {
    if (!pfEnablePlaylist || !lockScreenPlayer) return;

    NSURL* url = getVideoURLForScreen(kPreferenceKeyLockScreenWallpaper, kPreferenceKeyLockScreenWallpaperNight);
    if (!url) return;

    lockScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];
    [lockScreenPlayerLooper disableLooping];
    [lockScreenPlayer removeAllItems];
    [lockScreenPlayer insertItem:lockScreenPlayerItem afterItem:nil];
    lockScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:lockScreenPlayer templateItem:lockScreenPlayerItem];
    lockScreenPlaylistIndex++;
}

void swapHomeScreenVideo() {
    if (!pfEnablePlaylist || !homeScreenPlayer) return;

    NSURL* url = getVideoURLForScreen(kPreferenceKeyHomeScreenWallpaper, kPreferenceKeyHomeScreenWallpaperNight);
    if (!url) return;

    homeScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];
    [homeScreenPlayerLooper disableLooping];
    [homeScreenPlayer removeAllItems];
    [homeScreenPlayer insertItem:homeScreenPlayerItem afterItem:nil];
    homeScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:homeScreenPlayer templateItem:homeScreenPlayerItem];
    homeScreenPlaylistIndex++;
}

#pragma mark - Idle Timer

void cancelIdleTimer() {
    if (idleTimer) {
        [idleTimer invalidate];
        idleTimer = nil;
    }
}

void idleTimerFired() {
    isIdlePaused = YES;
    if (lockScreenPlayer && [lockScreenPlayer rate] > 0) {
        if (pfEnableFadeTransition) fadeOutLayer(lockScreenPlayerLayer);
        [lockScreenPlayer pause];
    }
    if (homeScreenPlayer && [homeScreenPlayer rate] > 0) {
        if (pfEnableFadeTransition) fadeOutLayer(homeScreenPlayerLayer);
        [homeScreenPlayer pause];
    }
    stopParallaxUpdates();
}

void resetIdleTimer() {
    cancelIdleTimer();
    if (pfIdleTimeout <= 0) return;

    idleTimer = [NSTimer scheduledTimerWithTimeInterval:pfIdleTimeout
        target:[NSBlockOperation blockOperationWithBlock:^{
            idleTimerFired();
        }]
        selector:@selector(main)
        userInfo:nil
        repeats:NO];
}

#pragma mark - Thermal State

void handleThermalStateChange() {
    if (@available(iOS 11.0, *)) {
        NSProcessInfoThermalState state = [[NSProcessInfo processInfo] thermalState];
        if (state >= NSProcessInfoThermalStateCritical) {
            if (lockScreenPlayer) {
                [lockScreenPlayer pause];
                [lockScreenPlayerLayer setHidden:YES];
            }
            if (homeScreenPlayer) {
                [homeScreenPlayer pause];
                [homeScreenPlayerLayer setHidden:YES];
            }
            stopParallaxUpdates();
        } else if (state >= NSProcessInfoThermalStateSerious) {
            if (lockScreenPlayer && [lockScreenPlayer rate] > 0) {
                [lockScreenPlayer setRate:0.5];
            }
            if (homeScreenPlayer && [homeScreenPlayer rate] > 0) {
                [homeScreenPlayer setRate:0.5];
            }
            stopParallaxUpdates();
        } else {
            if (lockScreenPlayer && isLockScreenVisible && isScreenOn) {
                [lockScreenPlayerLayer setHidden:NO];
                if ([lockScreenPlayer rate] != 1.0 && [lockScreenPlayer rate] > 0) {
                    [lockScreenPlayer setRate:1.0];
                }
            }
            if (homeScreenPlayer && isHomeScreenVisible && isScreenOn) {
                [homeScreenPlayerLayer setHidden:NO];
                if ([homeScreenPlayer rate] != 1.0 && [homeScreenPlayer rate] > 0) {
                    [homeScreenPlayer setRate:1.0];
                }
            }
            if (pfEnableParallax && isScreenOn) startParallaxUpdates();
        }
    }
}

#pragma mark - Playback Suppression

BOOL shouldSuppressPlayback() {
    return (pfDisableInLowPowerMode && isInLowPowerMode) || isInCall;
}

#pragma mark - Tap to Wake

void handleTapToWakeForLockScreen() {
    if (!isIdlePaused) return;
    isIdlePaused = NO;
    if (lockScreenPlayer && isLockScreenVisible) {
        ensureLayerVisible(lockScreenPlayerLayer);
        [lockScreenPlayer play];
    }
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}

void handleTapToWakeForHomeScreen() {
    if (!isIdlePaused) return;
    isIdlePaused = NO;
    if (homeScreenPlayer && isHomeScreenVisible) {
        ensureLayerVisible(homeScreenPlayerLayer);
        [homeScreenPlayer play];
    }
    if (pfEnableParallax) startParallaxUpdates();
    resetIdleTimer();
}
