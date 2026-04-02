//
//  EnekoInit.m
//  Eneko - Constructor: calls register functions from each hook module
//

#import "EnekoGlobals.h"
#import "EnekoPreferences.h"
#import "Helpers/EnekoHelpers.h"

// Hook registration functions from each module
extern void registerScreenHooks(void);
extern void registerLifecycleHooks(void);
extern void registerSystemHooks(void);

__attribute((constructor)) static void initialize() {
    load_preferences();

    if (!pfEnabled) return;

    registerScreenHooks();
    registerLifecycleHooks();
    registerSystemHooks();

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    // Thermal state monitoring
    [[NSNotificationCenter defaultCenter] addObserverForName:NSProcessInfoThermalStateDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        handleThermalStateChange();
    }];
}
