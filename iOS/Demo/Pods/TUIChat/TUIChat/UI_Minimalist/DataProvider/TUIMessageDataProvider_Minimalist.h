
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TUIMessageBaseDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class TUITextMessageCellData_Minimalist;
@class TUIFaceMessageCellData_Minimalist;
@class TUIImageMessageCellData_Minimalist;
@class TUIVoiceMessageCellData_Minimalist;
@class TUIVideoMessageCellData_Minimalist;
@class TUIFileMessageCellData_Minimalist;
@class TUISystemMessageCellData;
@class TUIChatCallingDataProvider;

@interface TUIMessageDataProvider_Minimalist : TUIMessageBaseDataProvider
- (void)preProcessReplyMessageV2:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback;

+ (NSMutableArray *)getCustomMessageInfo;

+ (NSMutableArray *)getPluginCustomMessageInfo;

+ (TUIChatCallingDataProvider *)callingDataProvider;

+ (TUIMessageCellData *__nullable)getCellData:(V2TIMMessage *)message;

+ (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date;

+ (TUIMessageCellData *)getRevokeCellData:(V2TIMMessage *)message;

+ (NSString *)getDisplayString:(V2TIMMessage *)message;

+ (void)updateUIMsgStatus:(TUIMessageCellData *)cellData uiMsgs:(NSArray *)uiMsgs;

@end

NS_ASSUME_NONNULL_END
