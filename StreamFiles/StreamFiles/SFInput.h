//
//  SFInput.h
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFInput : NSObject <NSStreamDelegate> {
    NSMutableData *recvData;
}

-(void) readDataFromPath : (NSString*) path withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess, NSData *data)) completion;

@end
