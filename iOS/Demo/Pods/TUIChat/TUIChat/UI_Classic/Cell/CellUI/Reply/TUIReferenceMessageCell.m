//
//  TUIReferenceMessageCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReferenceMessageCell.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import "TUIFileMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUILinkCellData.h"
#import "TUIMergeMessageCellData.h"
#import "TUIReplyMessageCell.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"

#import "TUIFileReplyQuoteView.h"
#import "TUIImageReplyQuoteView.h"
#import "TUIMergeReplyQuoteView.h"
#import "TUIReplyQuoteView.h"
#import "TUITextMessageCell.h"
#import "TUITextReplyQuoteView.h"
#import "TUIVideoReplyQuoteView.h"
#import "TUIVoiceReplyQuoteView.h"

@interface TUIReferenceMessageCell () <UITextViewDelegate>

@property(nonatomic, strong) TUIReplyQuoteView *currentOriginView;
@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIReplyQuoteView *> *customOriginViewsCache;

@end

@implementation TUIReferenceMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self setupContentTextView];
    [self.quoteView addSubview:self.senderLabel];
    [self.contentView addSubview:self.quoteView];

    self.bottomContainer = [[UIView alloc] init];
    [self.contentView addSubview:self.bottomContainer];
}
- (void)setupContentTextView {
    self.textView = [[TUITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");

    [self.bubbleView addSubview:self.textView];
}

- (void)fillWithData:(TUIReferenceMessageCellData *)data {
    [super fillWithData:data];
    self.referenceData = data;

    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    self.selectContent = data.content;
    self.textView.attributedText = [data.content getFormatEmojiStringWithFont:self.textView.font emojiLocations:self.referenceData.emojiLocations];

    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);

    @weakify(self);
    [[RACObserve(data, originMessage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(V2TIMMessage *originMessage) {
      @strongify(self);
      [self updateUI:data];
      [self layoutIfNeeded];
    }];

    [self layoutIfNeeded];
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.referenceData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)updateUI:(TUIReferenceMessageCellData *)referenceData {
    self.currentOriginView = [self getCustomOriginView:referenceData.originCellData];
    [self hiddenAllCustomOriginViews:YES];
    self.currentOriginView.hidden = NO;

    [self.currentOriginView fillWithData:referenceData.quoteData];

    self.textView.frame = (CGRect){.origin = self.referenceData.textOrigin, .size = self.referenceData.textSize};

    if (referenceData.direction == MsgDirectionIncoming) {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.textView.textColor = TUIChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");
        self.senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    }
    if (referenceData.textColor) {
        self.textView.textColor = referenceData.textColor;
    }

    CGFloat marginX = 6;
    CGFloat marginY = 8;

    self.senderLabel.mm_x = marginX;
    self.senderLabel.mm_y = marginY;
    self.senderLabel.mm_w = self.referenceData.senderSize.width + 4;
    self.senderLabel.mm_h = self.referenceData.senderSize.height;

    self.quoteView.mm_w = self.referenceData.quoteSize.width;
    self.quoteView.mm_h = self.referenceData.quoteSize.height;
    self.quoteView.mm_bottom(self.container.mm_b - self.quoteView.mm_h - 6);
    if (self.referenceData.direction == MsgDirectionIncoming) {
        self.quoteView.mm_left(self.container.mm_x);
    } else {
        self.quoteView.mm_right(self.container.mm_r);
    }

    if (self.referenceData.showMessageModifyReplies) {
        self.messageModifyRepliesButton.mm_bottom(self.contentView.mm_b + self.messageModifyRepliesButton.mm_h - 18);

        if (self.referenceData.direction == MsgDirectionIncoming) {
            self.messageModifyRepliesButton.mm_left(self.quoteView.mm_x);
        } else {
            self.messageModifyRepliesButton.mm_right(self.quoteView.mm_r);
        }
    }
    self.currentOriginView.mm_y = marginY + 1;
    self.currentOriginView.mm_x = self.senderLabel.mm_w + self.senderLabel.mm_x + marginX;
    self.currentOriginView.mm_w = self.referenceData.quotePlaceholderSize.width;
    self.currentOriginView.mm_h = self.referenceData.quotePlaceholderSize.height;
}

- (TUIReplyQuoteView *)getCustomOriginView:(TUIMessageCellData *)originCellData {
    NSString *reuseId = originCellData ? NSStringFromClass(originCellData.class) : NSStringFromClass(TUITextMessageCellData.class);
    TUIReplyQuoteView *view = nil;
    BOOL reuse = NO;
    if ([self.customOriginViewsCache.allKeys containsObject:reuseId]) {
        view = [self.customOriginViewsCache objectForKey:reuseId];
        reuse = YES;
    }

    if (view == nil) {
        Class class = [originCellData getReplyQuoteViewClass];
        if (class) {
            view = [[class alloc] init];
        }
    }

    if (view == nil) {
        TUITextReplyQuoteView *quoteView = [[TUITextReplyQuoteView alloc] init];
        view = quoteView;
    }

    if ([view isKindOfClass:[TUITextReplyQuoteView class]]) {
        TUITextReplyQuoteView *quoteView = (TUITextReplyQuoteView *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.textLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    } else if ([view isKindOfClass:[TUIMergeReplyQuoteView class]]) {
        TUIMergeReplyQuoteView *quoteView = (TUIMergeReplyQuoteView *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor =
                TUIChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = quoteView.subTitleLabel.textColor =
                TUIChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    }

    if (!reuse) {
        [self.customOriginViewsCache setObject:view forKey:reuseId];
        [self.quoteView addSubview:view];
    }

    view.hidden = YES;
    return view;
}

- (void)hiddenAllCustomOriginViews:(BOOL)hidden {
    [self.customOriginViewsCache enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TUIReplyQuoteView *_Nonnull obj, BOOL *_Nonnull stop) {
      obj.hidden = hidden;
      [obj reset];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self updateUI:self.referenceData];

    [self layoutBottomContainer];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.referenceData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.referenceData.bottomContainerSize;
    CGFloat topMargin = self.bubbleView.mm_maxY + self.nameLabel.mm_h + 6;

    if (self.referenceData.direction == MsgDirectionOutgoing) {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_right(self.mm_w - self.container.mm_maxX);
    } else {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_left(self.container.mm_minX);
    }

    if (!self.quoteView.hidden) {
        CGRect oldRect = self.quoteView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        self.quoteView.frame = newRect;
    }
    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.quoteView.frame), oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
}

- (UILabel *)senderLabel {
    if (_senderLabel == nil) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.text = @"harvy:";
        _senderLabel.font = [UIFont systemFontOfSize:12.0];
        _senderLabel.textColor = TUIChatDynamicColor(@"chat_reference_message_sender_text_color", @"#888888");
    }
    return _senderLabel;
}

- (UIView *)quoteView {
    if (_quoteView == nil) {
        _quoteView = [[UIView alloc] init];
        _quoteView.backgroundColor = TUIChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
        _quoteView.layer.cornerRadius = 4.0;
        _quoteView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteViewOnTap)];
        [_quoteView addGestureRecognizer:tap];
    }
    return _quoteView;
}

- (void)quoteViewOnTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectMessage:)]) {
        [self.delegate onSelectMessage:self];
    }
}

- (NSMutableDictionary *)customOriginViewsCache {
    if (_customOriginViewsCache == nil) {
        _customOriginViewsCache = [[NSMutableDictionary alloc] init];
    }
    return _customOriginViewsCache;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSAttributedString *selectedString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
    if (self.selectAllContentContent && selectedString) {
        if (selectedString.length == textView.attributedText.length) {
            self.selectAllContentContent(YES);
        } else {
            self.selectAllContentContent(NO);
        }
    }
    if (selectedString.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:selectedString];
        NSUInteger offsetLocation = 0;
        for (NSDictionary *emojiLocation in self.referenceData.emojiLocations) {
            NSValue *key = emojiLocation.allKeys.firstObject;
            NSAttributedString *originStr = emojiLocation[key];
            NSRange currentRange = [key rangeValue];
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                currentRange.location -= textView.selectedRange.location;
                if (currentRange.location + currentRange.length <= attributedString.length) {
                    [attributedString replaceCharactersInRange:currentRange withAttributedString:originStr];
                    offsetLocation += originStr.length - currentRange.length;
                }
            }
        }
        self.selectContent = attributedString.string;
    } else {
        self.selectContent = nil;
    }
}

@end
