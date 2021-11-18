//
//  WFCUCardCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUCardCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUUtilities.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import <SDWebImage/SDWebImage.h>


#define TEXT_TOP_PADDING 6
#define TEXT_BUTTOM_PADDING 6
#define TEXT_LEFT_PADDING 8
#define TEXT_RIGHT_PADDING 8


#define TEXT_LABEL_TOP_PADDING TEXT_TOP_PADDING + 4
#define TEXT_LABEL_BUTTOM_PADDING TEXT_BUTTOM_PADDING + 4
#define TEXT_LABEL_LEFT_PADDING 30
#define TEXT_LABEL_RIGHT_PADDING 30

@interface WFCUCardCell ()
@property (nonatomic, strong)UIImageView *cardPortrait;
@property (nonatomic, strong)UILabel *cardDisplayName;
@property (nonatomic, strong)UIView *cardSeparateLine;
@property (nonatomic, strong)UILabel *cardHint;
@end

@implementation WFCUCardCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeMake(width, 81);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCCardMessageContent *content = (WFCCCardMessageContent *)model.message.content;
    
    self.cardDisplayName.text = content.displayName;
    [self.cardPortrait sd_setImageWithURL:[NSURL URLWithString:content.portrait] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    
    [self cardSeparateLine];
    [self cardHint];
}

- (UIImageView *)cardPortrait {
    if (!_cardPortrait) {
        _cardPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(13, 9, 40, 40)];
        _cardPortrait.layer.cornerRadius = 20;
        _cardPortrait.clipsToBounds = YES;
        [self.contentArea addSubview:_cardPortrait];
    }
    return _cardPortrait;
}

- (UILabel *)cardDisplayName {
    if (!_cardDisplayName) {
        CGRect bounds = self.contentArea.bounds;
        _cardDisplayName = [[UILabel alloc] initWithFrame:CGRectMake(65, 22, bounds.size.width - 65 - 8, 15)];
        [self.contentArea addSubview:_cardDisplayName];
    }
    return _cardDisplayName;
}

- (UIView *)cardSeparateLine {
    if (!_cardSeparateLine) {
        CGRect bounds = self.contentArea.bounds;
        _cardSeparateLine = [[UIView alloc] initWithFrame:CGRectMake(13, 59, bounds.size.width - 13 - 8, 1)];
        _cardSeparateLine.backgroundColor = HEXCOLOR(0xebebeb);
        [self.contentArea addSubview:_cardSeparateLine];
    }
    return _cardSeparateLine;
}

- (UILabel *)cardHint {
    if (!_cardHint) {
        _cardHint = [[UILabel alloc] initWithFrame:CGRectMake(13, 64, 180, 12)];
        _cardHint.font = [UIFont systemFontOfSize:12];
        _cardHint.text = @"个人名片";
        _cardHint.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha: 0.6];
        [self.contentArea addSubview:_cardHint];
    }
    return _cardHint;
}
@end
