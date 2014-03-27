//
//  SFManager.h
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFManager : NSObject

+(void) readDataFromPath : (NSString*) path withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess, NSData *data)) completion;

+(void) writeDataToPath : (NSString*) path withData : (NSData*) data withStream : (const uint8_t* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess)) completion;

+(void) readFromPath : (NSString*) fromPath
         writeToPath : (NSString*) toPath
          withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream
          completion : (void (^)(BOOL isSuccess)) completion;

@end
