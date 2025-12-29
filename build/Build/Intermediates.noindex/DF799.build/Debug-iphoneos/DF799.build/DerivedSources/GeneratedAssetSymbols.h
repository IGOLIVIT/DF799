#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"IOI.DF799";

/// The "AccentOrange" asset catalog color resource.
static NSString * const ACColorNameAccentOrange AC_SWIFT_PRIVATE = @"AccentOrange";

/// The "DeepGreen" asset catalog color resource.
static NSString * const ACColorNameDeepGreen AC_SWIFT_PRIVATE = @"DeepGreen";

/// The "PrimaryYellow" asset catalog color resource.
static NSString * const ACColorNamePrimaryYellow AC_SWIFT_PRIVATE = @"PrimaryYellow";

#undef AC_SWIFT_PRIVATE
