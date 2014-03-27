//
//  SFInput.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFInput.h"

@interface SFInput (Private)
-(void) setup : (void (^)(BOOL, NSData*)) completion stream : (const void* (^)(uint8_t*, unsigned int)) stream;
-(void) clear;
@end

@implementation SFInput {
    NSMutableData *recvData;
}

#pragma mark - private

-(void) setup : (void (^)(BOOL, NSData*)) completion stream : (const void* (^)(uint8_t*, unsigned int)) stream {
    objc_setAssociatedObject(self, &COMPLETIONPOINTER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &STREAMPOINTER, stream, OBJC_ASSOCIATION_COPY_NONATOMIC);
    recvData = [[NSMutableData alloc] init];
}

-(void) clear {
    recvData = nil;
    objc_removeAssociatedObjects(self);
}

#pragma mark - NSStreamDelegate

-(void) stream : (NSStream*) stream handleEvent : (NSStreamEvent) eventCode {
    
    switch(eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[SIZEPERTIME];
            NSUInteger len = 0;
            len = [(NSInputStream*)stream read:buf maxLength:SIZEPERTIME];
            if (len) {
                uint8_t dataMirror[len];
                (void)memcpy(dataMirror, buf, len);
                const void* (^displayStream)(uint8_t* buffer, unsigned int length) = objc_getAssociatedObject(self, &STREAMPOINTER);
                [recvData appendBytes:displayStream(dataMirror, len) length:len];
            }
            break;
        }
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventErrorOccurred:
        {
            void (^completion)(BOOL isSuccess, NSData *data) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(NO, nil);
            [self terminateStream:stream];
            [self clear];
            break;
        }
        case NSStreamEventEndEncountered:
        {
            void (^completion)(BOOL isSuccess, NSData *data) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(YES, recvData);
            [self terminateStream:stream];
            [self clear];
            break;
        }
    }
}

#pragma mark - general function

-(void) readDataFromPath : (NSString*) path withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess, NSData *data)) completion {
    
    [self setup:completion stream:stream];
    [self openInputStreamWithPath:path];
    
}

@end
