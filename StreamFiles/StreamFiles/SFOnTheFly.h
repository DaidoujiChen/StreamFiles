//
//  SFOnTheFly.h
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFBase.h"

@interface SFOnTheFly : SFBase

-(void) readFromPath : (NSString*) fromPath
         writeToPath : (NSString*) toPath
          withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream
          completion : (void (^)(BOOL isSuccess)) completion;

@end
