//
//  UIView+UIView_Gradient.h
//  YunZaiApp
//
//  Created by ice on 2021/11/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UIView_Gradient)
- (void)addGradentColor:(UIColor *)startColor
               endColor:(UIColor *)endColor;
- (void)addShadow:(UIColor *)color
           offset:(CGSize)offset
          opacity:(CGFloat)opacity
           radius:(CGFloat)radius;
- (UIImage *)viewToImage;
@end

NS_ASSUME_NONNULL_END
