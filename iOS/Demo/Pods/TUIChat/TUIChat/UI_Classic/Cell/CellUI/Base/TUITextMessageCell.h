
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUITextView.h>
#import "TUIChatDefine.h"
#import "TUITextMessageCellData.h"

@class TUITextView;

typedef void (^TUIChatSelectAllContentCallback)(BOOL);

@interface TUITextMessageCell : TUIBubbleMessageCell <UITextViewDelegate>

/**
 *  展示文本消息的内容容器
 *  TextView for display text message content
 */
@property(nonatomic, strong) TUITextView *textView;

/**
 *  选中文本内容
 *  Selected text content
 */
@property(nonatomic, strong) NSString *selectContent;

/**
 *  选中全部文本回调
 *  Callback for selected all text
 */
@property(nonatomic, strong) TUIChatSelectAllContentCallback selectAllContentContent;

/// Data for text message cell.
@property(nonatomic, strong) TUITextMessageCellData *textData;

@property(nonatomic, strong) UIImageView *voiceReadPoint;

- (void)fillWithData:(TUITextMessageCellData *)data;

@end
