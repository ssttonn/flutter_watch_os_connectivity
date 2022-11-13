#import "FlutterWatchOsConnectivityPlugin.h"
#if __has_include(<flutter_watch_os_connectivity/flutter_watch_os_connectivity-Swift.h>)
#import <flutter_watch_os_connectivity/flutter_watch_os_connectivity-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_watch_os_connectivity-Swift.h"
#endif

@implementation FlutterWatchOsConnectivityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWatchOsConnectivityPlugin registerWithRegistrar:registrar];
}
@end
