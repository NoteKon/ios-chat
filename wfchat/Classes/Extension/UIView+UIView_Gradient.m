//
//  WFCUAddFriendViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/7.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "UIView+UIView_Gradient.h"
#import <UIKit/UIKit.h>

@implementation UIView (gradient)

- (void)addGradient: (UIColor *)startColor
        middleColor: (UIColor *)middleColor
           endColor: (UIColor *)endColor
          locations: (NSArray<NSNumber *> *)locations
         isVertical: (BOOL) isVertical {
    CAGradientLayer *layer = [CAGradientLayer init];
    layer.bounds = self.bounds;
    layer.borderWidth = 0;
    layer.frame = self.bounds;
    layer.cornerRadius = self.layer.cornerRadius;
    
}

@end
