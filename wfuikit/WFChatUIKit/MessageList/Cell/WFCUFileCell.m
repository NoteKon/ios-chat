//
//  FileCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUFileCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUUtilities.h"

@implementation WFCUFileCell
+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeMake(width, 76);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCFileMessageContent *fileContent = (WFCCFileMessageContent *)model.message.content;
    
    NSString *ext = [[fileContent.name pathExtension] lowercaseString];
    
    
    CGRect bounds = self.contentArea.bounds;
    if (model.message.direction == MessageDirection_Send) {
        self.fileImageView.frame = CGRectMake(bounds.size.width - 42, (bounds.size.height - 42) / 2, 33, 42);
        CGFloat offsetX = 5;
        self.fileNameLabel.frame = CGRectMake(offsetX, 19, bounds.size.width - 67, 15);
        CGFloat offsetY = self.fileNameLabel.frame.origin.y + self.fileNameLabel.frame.size.height + 10;
        self.sizeLabel.frame = CGRectMake(offsetX, offsetY, bounds.size.width - 67, 15);
        self.fileNameLabel.textAlignment = NSTextAlignmentLeft;
        self.sizeLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.fileImageView.frame = CGRectMake(9, (bounds.size.height - 42) / 2, 33, 42);
        CGFloat offsetX = self.fileImageView.frame.origin.x + self.fileImageView.frame.size.width + 10;
        self.fileNameLabel.frame = CGRectMake(offsetX, 19, bounds.size.width - offsetX - 10, 15);
        CGFloat offsetY = self.fileNameLabel.frame.origin.y + self.fileNameLabel.frame.size.height + 10;
        self.sizeLabel.frame = CGRectMake(offsetX, offsetY, bounds.size.width - offsetX - 10, 10);
        //self.fileNameLabel.textAlignment = NSTextAlignmentRight;
        self.sizeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    self.fileImageView.image = [WFCUUtilities imageForExt:ext];
    self.fileNameLabel.text = fileContent.name;
    self.sizeLabel.text = [WFCUUtilities formatSizeLable:fileContent.size];
}

- (UIView *)getProgressParentView {
    return self.fileImageView;
}

- (UIImageView *)fileImageView {
    if (!_fileImageView) {
        _fileImageView = [[UIImageView alloc] init];
        [self.contentArea addSubview:_fileImageView];
    }
    return _fileImageView;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.font = [UIFont systemFontOfSize:16];
        [_fileNameLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent:0.9]];
        [self.contentArea addSubview:_fileNameLabel];
    }
    return _fileNameLabel;
}
- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.font = [UIFont systemFontOfSize:13];
        [_sizeLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [self.contentArea addSubview:_sizeLabel];
    }
    return _sizeLabel;
}
@end
