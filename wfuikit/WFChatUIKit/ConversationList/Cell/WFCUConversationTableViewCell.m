//
//  ConversationTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewCell.h"
#import "WFCUUtilities.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "WFCUConfigManager.h"
#import "UIColor+YH.h"
#import <UIFont+YH.h>
CGFloat imageHeight = 52;
@implementation WFCUConversationTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)layoutSubviews {
    [super layoutSubviews];
//    if (!self.isBig) {
//        _potraitView.frame = CGRectMake(16, 12, 40, 40);
//        _targetView.frame = CGRectMake(16 + 40 + 20, 11, [UIScreen mainScreen].bounds.size.width - (16 + 40 + 20 + 100), 16);
//        _targetView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
//        _digestView.frame = CGRectMake(16 + 40 + 20, 11 + 16 + 8, [UIScreen mainScreen].bounds.size.width - (16 + 40 + 20 + 20), 19);
//    }
    
    if (self.bubbleView.hidden) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *bgView = [self viewWithTag:10010];
        [bgView removeFromSuperview];
    } else {
        CGFloat offsetX = 10;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, self.contentView.frame.size.width - offsetX * 2, self.contentView.frame.size.height - 8)];
        bgView.tag = 10010;
        bgView.layer.cornerRadius = 5;
        bgView.clipsToBounds = YES;
        bgView.backgroundColor = [UIColor colorWithHexString:@"FFFBF4"];
        [self.contentView insertSubview:bgView atIndex:0];
    }
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
  [self.potraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [UIImage imageNamed:@"PersonalChat"]];
  
    if (userInfo.friendAlias.length) {
        self.targetView.text = userInfo.friendAlias;
    } else if(userInfo.displayName.length > 0) {
        self.targetView.text = userInfo.displayName;
    } else {
        //self.targetView.text = [NSString stringWithFormat:@"user<%@>", self.info.conversation.target];
        self.targetView.text = [NSString stringWithFormat:@"%@", self.info.conversation.target];
    }
}

- (void)updateChannelInfo:(WFCCChannelInfo *)channelInfo {
    [self.potraitView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"channel_default_portrait"]];
    
    if(channelInfo.name.length > 0) {
        self.targetView.text = channelInfo.name;
    } else {
        self.targetView.text = WFCString(@"Channel");
    }
}

- (void)updateGroupInfo:(WFCCGroupInfo *)groupInfo {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GroupPortraitChanged" object:nil];

    if (groupInfo.portrait.length) {
        [self.potraitView sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
    } else {
        __weak typeof(self)ws = self;
        NSString *groupId = groupInfo.target;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"GroupPortraitChanged" object:groupInfo.target queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSString *path = [note.userInfo objectForKey:@"path"];
            if ((ws.info.conversation.type == Group_Type && [ws.info.conversation.target isEqualToString:groupId]) ||
                (ws.searchInfo.conversation.type == Group_Type  && [ws.searchInfo.conversation.target isEqualToString:groupId])) {
                [ws.potraitView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
            }
        }];
        [self.potraitView setImage:[UIImage imageNamed:@"group_default_portrait"]];
        
        
        NSString *path = [WFCCUtilities getGroupGridPortrait:groupInfo.target width:80 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
            return [UIImage imageNamed:@"PersonalChat"];
        }];
        
        if (path) {
            [self.potraitView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
            [self.potraitView setImage:[UIImage imageWithContentsOfFile:path]];
        }
    }
  
  if(groupInfo.name.length > 0) {
    self.targetView.text = groupInfo.name;
  } else {
    self.targetView.text = WFCString(@"GroupChat");
  }
}

- (void)setSearchInfo:(WFCCConversationSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    self.bubbleView.hidden = YES;
    self.timeView.hidden = YES;
    [self update:searchInfo.conversation];
    if (searchInfo.marchedCount > 1) {
        self.digestView.text = [NSString stringWithFormat:WFCString(@"NumberOfRecords"), searchInfo.marchedCount];
    } else {
        NSString *strContent = searchInfo.marchedMessage.digest;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:strContent];
        NSRange range = [strContent rangeOfString:searchInfo.keyword options:NSCaseInsensitiveSearch];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
        self.digestView.attributedText = attrStr;
    }
}

- (void)setInfo:(WFCCConversationInfo *)info {
    _info = info;
    if (info.unreadCount.unread == 0) {
        self.bubbleView.hidden = YES;
    } else {
        self.bubbleView.hidden = NO;
        if (info.isSilent) {
            self.bubbleView.isShowNotificationNumber = NO;
        } else {
            self.bubbleView.isShowNotificationNumber = YES;
        }
        [self.bubbleView setBubbleTipNumber:info.unreadCount.unread];
    }
    
    if (info.isSilent) {
        self.silentView.hidden = NO;
    } else {
        _silentView.hidden = YES;
    }
  
    [self update:info.conversation];
    self.timeView.hidden = NO;
    self.timeView.text = [WFCUUtilities formatTimeLabel:info.timestamp];
    
    BOOL darkMode = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkMode = YES;
        }
    }
    if (darkMode) {
        if (info.isTop) {
            [self.contentView setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.f]];
        } else {
            self.contentView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
        }
    } else {
        if (info.isTop) {
            [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"0xf7f7f7"]];
        } else {
            self.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (info.lastMessage && info.lastMessage.direction == MessageDirection_Send) {
        if (info.lastMessage.status == Message_Status_Sending) {
            self.statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
            self.statusView.hidden = NO;
        } else if(info.lastMessage.status == Message_Status_Send_Failure) {
            self.statusView.image = [UIImage imageNamed:@"MessageSendError"];
            self.statusView.hidden = NO;
        } else {
            self.statusView.hidden = YES;
        }
    } else {
        self.statusView.hidden = YES;
    }
    [self updateDigestFrame:!self.statusView.hidden];
}

- (void)updateDigestFrame:(BOOL)isSending {
    if (isSending) {
        _digestView.frame = CGRectMake(20 + imageHeight + 14 + 18, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16 - 18, 14);
    } else {
        _digestView.frame = CGRectMake(20 + imageHeight + 14, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16, 14);
    }
}
- (void)update:(WFCCConversation *)conversation {
    self.targetView.textColor = [WFCUConfigManager globalManager].textColor;
    if(conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:conversation.target refresh:NO];
        if(userInfo.userId.length == 0) {
            userInfo = [[WFCCUserInfo alloc] init];
            userInfo.userId = conversation.target;
        }
        [self updateUserInfo:userInfo];
    } else if (conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:conversation.target refresh:NO];
        if(groupInfo.target.length == 0) {
            groupInfo = [[WFCCGroupInfo alloc] init];
            groupInfo.target = conversation.target;
        }
        [self updateGroupInfo:groupInfo];
        
    } else if(conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:conversation.target refresh:NO];
        if (channelInfo.channelId.length == 0) {
            channelInfo = [[WFCCChannelInfo alloc] init];
            channelInfo.channelId = conversation.target;
        }
        [self updateChannelInfo:channelInfo];
    } else {
        self.targetView.text = WFCString(@"Chatroom");
    }
    
    self.potraitView.layer.cornerRadius = imageHeight / 2;
    self.digestView.attributedText = nil;
    if (_info.draft.length) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:WFCString(@"[Draft]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
        
        NSError *__error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[_info.draft dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&__error];
        
        NSString *text = _info.draft;
        if (!__error) {
            //兼容android/web端
            if([dictionary[@"content"] isKindOfClass:[NSString class]]) {
                text = dictionary[@"content"];
            } else if([dictionary[@"text"] isKindOfClass:[NSString class]]) {
                text = dictionary[@"text"];
            }
        }
        
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:text]];

        if (_info.conversation.type == Group_Type && _info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:WFCString(@"[MentionYou]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            [tmp appendAttributedString:attString];
            attString = tmp;
        }
        self.digestView.attributedText = attString;
    } else if (_info.lastMessage.direction == MessageDirection_Receive && (_info.conversation.type == Group_Type || _info.conversation.type == Channel_Type)) {
        NSString *groupId = nil;
        if (_info.conversation.type == Group_Type) {
            groupId = _info.conversation.target;
        }
        WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:_info.lastMessage.fromUser inGroup:groupId refresh:NO];
        if (sender.friendAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.friendAlias, _info.lastMessage.digest];
        } else if (sender.groupAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.groupAlias, _info.lastMessage.digest];
        } else if (sender.displayName.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.displayName, _info.lastMessage.digest];
        } else {
            self.digestView.text = _info.lastMessage.digest;
        }
        
        if (_info.conversation.type == Group_Type && _info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:WFCString(@"[MentionYou]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            if (self.digestView.text.length) {
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:self.digestView.text]];
            }
            
            self.digestView.attributedText = attString;
        }
    } else {
        self.digestView.text = _info.lastMessage.digest;
    }
}
/// 头像
- (UIImageView *)potraitView {
    if (!_potraitView) {
        _potraitView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8.5, imageHeight, imageHeight)];
        _potraitView.clipsToBounds = YES;
        _potraitView.layer.cornerRadius = imageHeight / 2;
        [self.contentView addSubview:_potraitView];
    }
    return _potraitView;
}
///
- (UIImageView *)statusView {
    if (!_statusView) {
        _statusView = [[UIImageView alloc] initWithFrame:CGRectMake(20 + imageHeight + 14, 39, 16, 16)];
        _statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
        [self.contentView addSubview:_statusView];
    }
    return _statusView;
}
/// 名称
- (UILabel *)targetView {
    if (!_targetView) {
        _targetView = [[UILabel alloc] initWithFrame:CGRectMake(20 + imageHeight + 14, 16, [UIScreen mainScreen].bounds.size.width - 70  - 68, 16)];
        _targetView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:18];
        _targetView.textColor = [UIColor blackColor]; //[WFCUConfigManager globalManager].textColor;
        _targetView.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_targetView];
    }
    return _targetView;
}
///
- (UILabel *)digestView {
    if (!_digestView) {
        _digestView = [[UILabel alloc] initWithFrame:CGRectMake(20 + imageHeight + 14, 40, [UIScreen mainScreen].bounds.size.width - 70  - 16 - 14, 14)];
        _digestView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _digestView.textAlignment = NSTextAlignmentLeft;
        _digestView.lineBreakMode = NSLineBreakByTruncatingTail;
        _digestView.textColor = [UIColor colorWithHexString:@"0xB8B5AF"];
        [self.contentView addSubview:_digestView];
    }
    return _digestView;
}

- (UIImageView *)silentView {
    if (!_silentView) {
        _silentView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 12  - 20, 45, 12, 12)];
        _silentView.image = [UIImage imageNamed:@"conversation_mute"];
        [self.contentView addSubview:_silentView];
    }
    return _silentView;
}

- (UILabel *)timeView {
    if (!_timeView) {
        _timeView = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 52  - 20, 14, 52, 11)];
        _timeView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        _timeView.textAlignment = NSTextAlignmentRight;
        _timeView.textColor = [UIColor colorWithHexString:@"0xB8B5AF"];
        [self.contentView addSubview:_timeView];
    }

    return _timeView;
}

- (BubbleTipView *)bubbleView {
    if (!_bubbleView) {
        if(self.potraitView) {
            _bubbleView = [[BubbleTipView alloc] initWithSuperView:self.contentView];
            _bubbleView.bubbleTipTextFont = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
            _bubbleView.bubbleTipBackgroundColor = [UIColor colorWithHexString:@"0xFF5C64"];
            _bubbleView.hidden = YES;
        }
    }
    return _bubbleView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
