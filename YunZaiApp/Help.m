//
//  Help.m
//  YunZaiApp
//
//  Created by ice on 2021/11/9.
//

#import "Help.h"

@implementation Help

#if WFCU_SUPPORT_VOIP

+ (void)ringHelp {
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

void systemAudioCallback (SystemSoundID soundID, void* clientData) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if ([WFAVEngineKit sharedEngineKit].currentSession.state == kWFAVEngineStateIncomming) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    });
}
#endif

+ (BOOL)msgFlag:(WFCCMessage *)msg {
    int flag = (int)[msg.content.class performSelector:@selector(getContentFlags)];
    return (flag & 0x03);
}
@end
