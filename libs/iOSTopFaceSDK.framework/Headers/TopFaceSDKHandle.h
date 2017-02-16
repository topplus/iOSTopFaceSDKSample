//
//  TopFaceSDKHandle.h
//  iOSTopFaceSDK
//
//  Created by Jeavil on 17/1/20.
//  Copyright © 2017年 L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface TopFaceSDKHandle : NSObject

/**设置用户id和secret*/
- (void)setLicense:(NSString *)Client_id andSecret:(NSString *)Clicent_secret;

/**
 @brief :初始化检测器
 
 @param focus_length
 等效焦距 默认值 31
 */
- (int)Engine_InitWithFocus:(float)focus_length;

/**
 @brief :人脸检测
 
 return :人脸数据
 */
- (NSArray *)DynamicDetect:(CMSampleBufferRef)buffer;
@end
