//
//  UIControl+Touch.h
//  YunZaiApp
//
//  Created by ice on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (Touch)
/// 点击事件触发间隔时间
@property (nonatomic, assign) NSTimeInterval zhw_acceptEventInterval;
/// 是否忽略点击事件,不响应点击事件
@property (nonatomic, assign) BOOL zhw_ignoreEvent;
@end

NS_ASSUME_NONNULL_END
