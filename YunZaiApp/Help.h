//
//  Help.h
//  YunZaiApp
//
//  Created by ice on 2021/11/9.
//

#import <Foundation/Foundation.h>
#import <WFChatClient/WFCChatClient.h>
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#import <WebRTC/WebRTC.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface Help : NSObject
#if WFCU_SUPPORT_VOIP
+ (void)ringHelp;
void systemAudioCallback (SystemSoundID soundID, void* clientData);
#endif

+ (BOOL)msgFlag:(WFCCMessage *)msg;

@end

NS_ASSUME_NONNULL_END
