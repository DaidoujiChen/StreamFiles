//
//  SFOutput.h
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFBase.h"

@interface SFOutput : SFBase

-(void) writeDataToPath : (NSString*) path withData : (NSData*) data withStream : (const uint8_t* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess)) completion;

@end
