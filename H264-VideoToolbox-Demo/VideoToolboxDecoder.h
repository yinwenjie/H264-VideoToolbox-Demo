//
//  VideoToolboxDecoder.h
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/15.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoToolboxDecoder : NSObject

- (instancetype)initWithExtradata;

- (int)decodeVideo;

@end
