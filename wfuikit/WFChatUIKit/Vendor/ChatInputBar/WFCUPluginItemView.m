//
//  PluginItemView.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUPluginItemView.h"

@implementation WFCUPluginItemView
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView:title image:image frame: frame];
    }
    return self;
}

- (void)setupView:(NSString *)title image:(UIImage *)image frame:(CGRect)frame {
    CGFloat width = 80;
    CGFloat height = 80;
    CGFloat offsetX = (frame.size.width - width) / 2;
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(offsetX, 0, width, height);
    [imageButton setImage:image forState:UIControlStateNormal];
    
    [imageButton addTarget:self action:@selector(itemPlugined:) forControlEvents:UIControlEventTouchUpInside];
    imageButton.userInteractionEnabled = YES;
    [self addSubview:imageButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, height, width, 12)];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:title];
    [label setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.9]];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:label];
}


- (void)itemPlugined:(id)sender {
    self.onItemClicked();
}

@end
