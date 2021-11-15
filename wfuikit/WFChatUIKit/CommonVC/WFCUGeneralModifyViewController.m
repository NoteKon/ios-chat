//
//  GeneralModifyViewController.m
//  WildFireChat
//
//  Created by heavyrain lee on 24/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "WFCUGeneralModifyViewController.h"
#import "MBProgressHUD.h"
#import "WFCUConfigManager.h"

@interface WFCUGeneralModifyViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation WFCUGeneralModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.titleText) {
        [self setTitle:_titleText];
    }
    
    self.tipLabel.text = @"备注名";
    self.textField.text = self.defaultValue;
    [self.view addSubview:self.lineView];
    
    UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [leftButton setTitle:WFCString(@"Cancel") forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    
   // [self.textField becomeFirstResponder];
}

- (void)onCancel:(id)sender {
  [self.textField resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDone:(id)sender {
  [self.textField resignFirstResponder];
    __weak typeof(self) ws = self;
    
    __block MBProgressHUD *hud;
    if (!self.noProgress) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = WFCString(@"Updating");
        [hud showAnimated:YES];
    }
    
    self.tryModify(self.textField.text, ^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.noProgress) {
                [hud hideAnimated:NO];
            }
            
            if(success) {
                [ws.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                if (!self.noProgress) {
                    hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = WFCString(@"UpdateFailure");
                    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                    [hud hideAnimated:YES afterDelay:1.f];
                }
            }
        });
    });
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, kStatusBarAndNavigationBarHeight + 13, self.view.frame.size.width - 18 * 2, 14)];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self.view addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (UITextField *)textField {
    if(!_textField) {
        CGFloat offsetX = 21;
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, kStatusBarAndNavigationBarHeight + 54, [UIScreen mainScreen].bounds.size.width - offsetX * 2, 32)];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.textColor = [UIColor blackColor];
        _textField.tintColor = [WFCUConfigManager globalManager].textFieldColor;
        _textField.delegate = self;
        
        [self.view addSubview:_textField];
    }
    return _textField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y + _textField.frame.size.height + 10, _textField.frame.size.width, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
    }
    return _lineView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onDone:textField];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    self.lineView.backgroundColor = [UIColor colorWithRed:100/255.0 green:238/255.0 blue:237/255.0 alpha:1.0];
    return YES;
}

@end
