//
//  EnekoScreenHooks.m
//  Eneko - viewDidLoad hooks for Lock Screen & Home Screen player setup
//

#import "../EnekoGlobals.h"
#import "../Helpers/EnekoHelpers.h"

#pragma mark - Lock Screen viewDidLoad

static void (* orig_CSCoverSheetViewController_viewDidLoad)(CSCoverSheetViewController* self, SEL _cmd);
static void override_CSCoverSheetViewController_viewDidLoad(CSCoverSheetViewController* self, SEL _cmd) {
    orig_CSCoverSheetViewController_viewDidLoad(self, _cmd);

    NSURL* url = getVideoURLForScreen(kPreferenceKeyLockScreenWallpaper, kPreferenceKeyLockScreenWallpaperNight);
    if (!url) return;

    wasDaytimeLastCheck = isDaytime();

    lockScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];
    lockScreenPlayer = [AVQueuePlayer playerWithPlayerItem:lockScreenPlayerItem];
    [lockScreenPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

    if (pfLockScreenVolume == 0) {
        [lockScreenPlayer setMuted:YES];
    } else {
        [lockScreenPlayer setVolume:pfLockScreenVolume];
    }

    lockScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:lockScreenPlayer templateItem:lockScreenPlayerItem];

    lockScreenPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:lockScreenPlayer];
    [lockScreenPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [lockScreenPlayerLayer setFrame:[[[self view] layer] bounds]];
    [[[self view] layer] insertSublayer:lockScreenPlayerLayer atIndex:0];

    lockScreenDimLayer = createDimLayer([[[self view] layer] bounds]);
    if (lockScreenDimLayer) {
        [[[self view] layer] insertSublayer:lockScreenDimLayer above:lockScreenPlayerLayer];
    }

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoScreenRotated" object:nil];

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToWake)];
    [tap setCancelsTouchesInView:NO];
    [[self view] addGestureRecognizer:tap];
}

static void CSCoverSheetViewController_adjustFrame(CSCoverSheetViewController* self, SEL _cmd) {
    CGRect bounds = [[[self view] layer] bounds];
    [lockScreenPlayerLayer setFrame:bounds];
    if (lockScreenDimLayer) [lockScreenDimLayer setFrame:bounds];
}

static void CSCoverSheetViewController_handleTapToWake(CSCoverSheetViewController* self, SEL _cmd) {
    handleTapToWakeForLockScreen();
}

#pragma mark - Home Screen viewDidLoad

static void (* orig_SBIconController_viewDidLoad)(SBIconController* self, SEL _cmd);
static void override_SBIconController_viewDidLoad(SBIconController* self, SEL _cmd) {
    orig_SBIconController_viewDidLoad(self, _cmd);

    NSURL* url = getVideoURLForScreen(kPreferenceKeyHomeScreenWallpaper, kPreferenceKeyHomeScreenWallpaperNight);
    if (!url) return;

    homeScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];
    homeScreenPlayer = [AVQueuePlayer playerWithPlayerItem:homeScreenPlayerItem];
    [homeScreenPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

    if (pfHomeScreenVolume == 0) {
        [homeScreenPlayer setMuted:YES];
    } else {
        [homeScreenPlayer setVolume:pfHomeScreenVolume];
    }

    homeScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:homeScreenPlayer templateItem:homeScreenPlayerItem];

    homeScreenPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:homeScreenPlayer];
    [homeScreenPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [homeScreenPlayerLayer setFrame:[[[self view] layer] bounds]];

    if (pfZoomWallpaper) {
        [homeScreenPlayerLayer setTransform:CATransform3DMakeScale(1.15, 1.15, 2)];
    }

    [[[self view] layer] insertSublayer:homeScreenPlayerLayer atIndex:0];

    homeScreenDimLayer = createDimLayer([[[self view] layer] bounds]);
    if (homeScreenDimLayer) {
        [[[self view] layer] insertSublayer:homeScreenDimLayer above:homeScreenPlayerLayer];
    }

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoScreenRotated" object:nil];

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToWake)];
    [tap setCancelsTouchesInView:NO];
    [[self view] addGestureRecognizer:tap];
}

static void SBIconController_adjustFrame(SBIconController* self, SEL _cmd) {
    CGRect bounds = [[[self view] layer] bounds];
    [homeScreenPlayerLayer setFrame:bounds];
    if (homeScreenDimLayer) [homeScreenDimLayer setFrame:bounds];
}

static void SBIconController_handleTapToWake(SBIconController* self, SEL _cmd) {
    handleTapToWakeForHomeScreen();
}

#pragma mark - Hook Registration

void registerScreenHooks() {
    if (pfEnableLockScreenWallpaper) {
        class_addMethod(objc_getClass("CSCoverSheetViewController"), @selector(adjustFrame), (IMP)&CSCoverSheetViewController_adjustFrame, "v@:");
        class_addMethod(objc_getClass("CSCoverSheetViewController"), @selector(handleTapToWake), (IMP)&CSCoverSheetViewController_handleTapToWake, "v@:");
        MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewDidLoad), (IMP)&override_CSCoverSheetViewController_viewDidLoad, (IMP *)&orig_CSCoverSheetViewController_viewDidLoad);
    }

    if (pfEnableHomeScreenWallpaper) {
        class_addMethod(objc_getClass("SBIconController"), @selector(adjustFrame), (IMP)&SBIconController_adjustFrame, "v@:");
        class_addMethod(objc_getClass("SBIconController"), @selector(handleTapToWake), (IMP)&SBIconController_handleTapToWake, "v@:");
        MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewDidLoad), (IMP)&override_SBIconController_viewDidLoad, (IMP *)&orig_SBIconController_viewDidLoad);
    }
}
