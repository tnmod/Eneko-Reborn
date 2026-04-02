//
//  Eneko.h
//  Eneko - Interface declarations for hooked classes
//
//  Created by Alexandra (@Traurige)
//

@interface CSCoverSheetViewController : UIViewController
- (void)adjustFrame;
- (void)handleTapToWake;
@end

@interface SBIconController : UIViewController
- (void)adjustFrame;
- (void)handleTapToWake;
@end

@interface CCUIModularControlCenterOverlayViewController : UIViewController
@end

@interface SBBacklightController : NSObject
@end

@interface SBLockScreenManager : NSObject
@end

@interface SpringBoard : UIApplication
@end

@interface SBMediaController : NSObject
@end

@interface TUCall : NSObject
@end

@interface SiriUIBackgroundBlurView : UIView
@end

@interface SBDashBoardCameraPageViewController : UIViewController
@end

@interface CSModalButton : UIButton
@end

@interface SBLockScreenEmergencyCallViewController : UIViewController
@end
