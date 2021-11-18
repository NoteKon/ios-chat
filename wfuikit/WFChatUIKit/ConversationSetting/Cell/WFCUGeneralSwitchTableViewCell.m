//
//  SwitchTableViewCell.m
//  WildFireChat
//
//  Created by heavyrain lee on 27/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "WFCUGeneralSwitchTableViewCell.h"
#import "MBProgressHUD.h"
#import "WFCUConfigManager.h"

@interface WFCUGeneralSwitchTableViewCell()
@end

@implementation WFCUGeneralSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.valueSwitch.frame = CGRectMake(self.frame.size.width - 56, 13, 40, 40);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.valueSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.valueSwitch.onTintColor = [WFCUConfigManager globalManager].switchColor;
        [self.contentView addSubview:self.valueSwitch];
        [self.valueSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)onSwitch:(id)sender {
    BOOL value = _valueSwitch.on;
    __weak typeof(self)ws = self;
    if (self.onSwitch) {
        self.onSwitch(value, self.type, ^(BOOL success) {
            if (success) {
                [ws.valueSwitch setOn:value];
            } else {
                [ws.valueSwitch setOn:!value];
            }
        });
    }
}

- (void)setOn:(BOOL)on {
    _on = on;
    [self.valueSwitch setOn:on];
}
@end
