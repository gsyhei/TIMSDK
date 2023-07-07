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

#import "TUITranslationConfig.h"
#import "TUITranslationDataProvider.h"
#import "TUITranslationExtensionObserver.h"
#import "TUITranslationLanguageController.h"
#import "TUITranslationView.h"

FOUNDATION_EXPORT double TUITranslationPluginVersionNumber;
FOUNDATION_EXPORT const unsigned char TUITranslationPluginVersionString[];

