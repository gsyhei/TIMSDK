//
//  TUIVideoMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import "TUICircleLodingView.h"
#import "TUIMessageProgressManager.h"

@interface TUIVideoMessageCell () <TUIMessageProgressManagerDelegate>

@property(nonatomic, strong) UIView *animateHighlightView;

@property(nonatomic, strong) TUICircleLodingView *animateCircleView;

@property(nonatomic, strong) UIImageView *downloadImage;

@end

@implementation TUIVideoMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor clearColor];
        [self.container addSubview:_thumb];
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        CGSize playSize = TVideoMessageCell_Play_Size;
        _play = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _play.contentMode = UIViewContentModeScaleAspectFit;
        _play.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"play_normal")];
        _play.hidden = YES;
        [_thumb addSubview:_play];

        _downloadImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _downloadImage.contentMode = UIViewContentModeScaleAspectFit;
        _downloadImage.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"download")];
        _downloadImage.hidden = YES;
        [_thumb addSubview:_downloadImage];

        _duration = [[UILabel alloc] init];
        _duration.textColor = [UIColor whiteColor];
        _duration.font = [UIFont systemFontOfSize:12];
        [_thumb addSubview:_duration];

        _animateCircleView = [[TUICircleLodingView alloc] initWithFrame:CGRectMake(0, 0, kScale390(40), kScale390(40))];
        _animateCircleView.progress = 0;
        [_thumb addSubview:_animateCircleView];

        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TVideoMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
        _progress.mm_fill();
        _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)fillWithData:(TUIVideoMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.videoData = data;
    _thumb.image = nil;
    if (data.thumbImage == nil) {
        [data downloadThumb];
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.thumb.image = thumbImage;
          [self.duration setFrame:CGRectMake(self.play.frame.origin.x + self.play.frame.size.width - 15, self.thumb.frame.size.height - 20, 20, 20)];
          self.duration.mm_sizeToFitThan(20, 20);
      }
    }];

    _duration.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)data.videoItem.duration / 60, (long)data.videoItem.duration % 60];
    ;

    self.play.hidden = YES;
    self.downloadImage.hidden = YES;
    self.indicator.hidden = YES;
    if (data.direction == MsgDirectionIncoming) {
        [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
          @strongify(self);
          // 封面下载的进度回调
          int progress = [x intValue];
          self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
          self.progress.hidden = (progress >= 100 || progress == 0);
          self.animateCircleView.progress = progress;
          if (progress >= 100 || progress == 0) {
              // 封面进度100时展示下载视频图标
              if ([data isVideoExist]) {
                  self.play.hidden = NO;
              } else {
                  self.downloadImage.hidden = NO;
              }
          } else {
              self.play.hidden = YES;
              self.downloadImage.hidden = YES;
          }
        }];

        // 视频资源下载的进度回调
        [[[RACObserve(data, videoProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
          @strongify(self);
          int progress = [x intValue];
          self.animateCircleView.progress = progress;
          if (progress >= 100 || progress == 0) {
              self.play.hidden = NO;
              self.animateCircleView.hidden = YES;
          } else {
              self.play.hidden = YES;
              self.downloadImage.hidden = YES;
              self.animateCircleView.hidden = NO;
          }
        }];

    } else {
        if ([data isVideoExist]) {
            [[[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              int progress = [x intValue];
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  [self.indicator stopAnimating];
                  self.play.hidden = NO;
                  self.animateCircleView.hidden = YES;
              } else {
                  [self.indicator startAnimating];
                  self.play.hidden = YES;
                  self.animateCircleView.hidden = NO;
              }
            }];

        } else {
            [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              // 封面下载的进度回调
              int progress = [x intValue];
              self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
              self.progress.hidden = (progress >= 100 || progress == 0);
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  // 封面进度100时展示下载视频图标
                  if ([data isVideoExist]) {
                      self.play.hidden = NO;
                  } else {
                      self.downloadImage.hidden = NO;
                  }
              } else {
                  self.play.hidden = YES;
                  self.downloadImage.hidden = YES;
              }
            }];

            // 视频资源下载的进度回调
            [[[RACObserve(data, videoProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              int progress = [x intValue];
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  self.play.hidden = NO;
                  self.animateCircleView.hidden = YES;
              } else {
                  self.play.hidden = YES;
                  self.downloadImage.hidden = YES;
                  self.animateCircleView.hidden = NO;
              }
            }];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.messageData.messageModifyReactsSize.height > 0) {
        if (self.tagView) {
            CGFloat topMargin = 10;
            CGFloat tagViewTopMargin = 6;
            CGFloat thumbHeight = self.container.mm_h - topMargin - self.messageData.messageModifyReactsSize.height - tagViewTopMargin;
            _thumb.mm_height(thumbHeight).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);
            self.tagView.frame = CGRectMake(0, self.container.mm_h - self.messageData.messageModifyReactsSize.height - tagViewTopMargin,
                                            self.container.frame.size.width, self.messageData.messageModifyReactsSize.height);
        }
        self.bubbleView.hidden = NO;
    } else {
        CGFloat topMargin = 0;
        CGFloat height = self.container.mm_h;
        _thumb.mm_height(height).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);
        self.bubbleView.hidden = YES;
    }
    _play.mm_width(TVideoMessageCell_Play_Size.width).mm_height(TVideoMessageCell_Play_Size.height).tui_mm_center();
    _downloadImage.mm_width(TVideoMessageCell_Play_Size.width).mm_height(TVideoMessageCell_Play_Size.height).tui_mm_center();
    self.animateCircleView.tui_mm_center();
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword {
    if (keyword) {
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

- (void)animate:(int)times {
    times--;
    if (times < 0) {
        [self.animateHighlightView removeFromSuperview];
        self.highlightAnimating = NO;
        return;
    }
    self.highlightAnimating = YES;
    self.animateHighlightView.frame = self.container.bounds;
    self.animateHighlightView.alpha = 0.1;
    [self.container addSubview:self.animateHighlightView];
    [UIView animateWithDuration:0.25
        animations:^{
          self.animateHighlightView.alpha = 0.5;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.25
              animations:^{
                self.animateHighlightView.alpha = 0.1;
              }
              completion:^(BOOL finished) {
                if (!self.videoData.highlightKeyword) {
                    [self animate:0];
                    return;
                }
                [self animate:times];
              }];
        }];
}

- (UIView *)animateHighlightView {
    if (_animateHighlightView == nil) {
        _animateHighlightView = [[UIView alloc] init];
        _animateHighlightView.backgroundColor = [UIColor orangeColor];
    }
    return _animateHighlightView;
}

#pragma mark - TUIMessageProgressManagerDelegate
- (void)onUploadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.videoData.msgID]) {
        return;
    }
    if (self.videoData.direction == MsgDirectionOutgoing) {
        self.videoData.uploadProgress = progress;
    }
}

@end
