//
//  UIView+UIView_Gradient.m
//  YunZaiApp
//
//  Created by ice on 2021/11/10.
//

#import "UIView+UIView_Gradient.h"

@implementation UIView (UIView_Gradient)
- (void)addGradentColor:(UIColor *)startColor
               endColor:(UIColor *)endColor {
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = self.frame;
    gradientLayer.borderWidth = 0;
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@(0.5),@(1.0)];//渐变点
    [gradientLayer setColors:@[(id)[startColor CGColor],(id)[endColor CGColor]]];//渐变数组
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)addShadow:(UIColor *)color
           offset:(CGSize)offset
          opacity:(CGFloat)opacity
           radius:(CGFloat)radius {
    self.layer.masksToBounds = false;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
}

- (UIImage *)viewToImage {
    CGSize size = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, false, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
