//
//  SFManager.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFManager.h"

#import "SFManager+AccessObject.h"

#import "SFInput.h"
#import "SFOutput.h"

@implementation SFManager

+(void) readDataFromPath : (NSString*) path withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess, NSData *data)) completion {
    
    SFInput *input = [SFInput new];
    [[self streamPool] addObject:input];
    
    [input readDataFromPath:path
                 withStream:stream
                 completion:^(BOOL isSuccess, NSData *data) {
                     completion(isSuccess, data);
                     [[self streamPool] removeObject:input];
                 }];
    
}

+(void) writeDataToPath : (NSString*) path withData : (NSData*) data withStream : (const uint8_t* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess)) completion {
    
    SFOutput *output = [SFOutput new];
    [[self streamPool] addObject:output];
    
    [output writeDataToPath:path
                   withData:data
                 withStream:stream
                 completion:^(BOOL isSuccess) {
                     completion(isSuccess);
                     [[self streamPool] removeObject:output];
                 }];
}

@end
