#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+CoreExtension.h"
#import "NSObject+TUIRoomMessageExtensionObserver.h"

FOUNDATION_EXPORT double TUIRoomKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TUIRoomKitVersionString[];

