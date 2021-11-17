//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCULocationCell.h"
#import <WFChatClient/WFCChatClient.h>

@interface WFCULocationCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@property (nonatomic, strong)UIImageView *thumbnailView;
@property (nonatomic, strong)UILabel *titleLabel;
@end

@implementation WFCULocationCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
//    WFCCLocationMessageContent *imgContent = (WFCCLocationMessageContent *)msgModel.message.content;
    
//    CGSize size = imgContent.thumbnail.size;
//
//    if (size.height > width || size.width > width) {
//        float scale = MIN(width/size.height, width/size.width);
//        size = CGSizeMake(size.width * scale, size.height * scale);
//    }
    return CGSizeMake(width, 135);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCLocationMessageContent *imgContent = (WFCCLocationMessageContent *)model.message.content;
    CGFloat offsetY = 42;
    CGRect frame = self.bubbleView.bounds;

    if (model.message.direction == MessageDirection_Send) {
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.frame = CGRectMake(5, 0, self.bubbleView.frame.size.width - 13 * 2, 42);
    } else {
        frame.origin.x += 2;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.frame = CGRectMake(13 + 17, 0, self.bubbleView.frame.size.width - 13 * 2 - 17, 42);
    }
    
    frame.origin.y += offsetY;
    frame.size.height -= offsetY;
    self.thumbnailView.frame = frame;
    self.thumbnailView.image = imgContent.thumbnail;
    self.titleLabel.text = imgContent.title;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bubbleView addSubview:_thumbnailView];
    }
    return _thumbnailView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bubbleView.frame.size.width, 42)];
        bgView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, self.bubbleView.frame.size.width - 13 * 2, 42)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        [bgView addSubview:_titleLabel];
        [self.bubbleView addSubview:bgView];
    }
    return _titleLabel;
}

- (void)setMaskImage:(UIImage *)maskImage{
    [super setMaskImage:maskImage];
//    if (_shadowMaskView) {
//        [_shadowMaskView removeFromSuperview];
//    }
//    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];
//
//    CGRect frame = CGRectMake(self.bubbleView.frame.origin.x - 1, self.bubbleView.frame.origin.y - 1, self.bubbleView.frame.size.width + 2, self.bubbleView.frame.size.height + 2);
//    _shadowMaskView.frame = frame;
//    [self.contentView addSubview:_shadowMaskView];
//    [self.contentView bringSubviewToFront:self.bubbleView];
}

@end
