//
//  SFInput.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFInput.h"

#import <objc/runtime.h>

@implementation SFInput

#define READSIZEPERTIME 1024

static const char COMPLETIONPOINTER;
static const char STREAMPOINTER;

#pragma mark - NSStreamDelegate

-(void) stream : (NSStream*) stream handleEvent : (NSStreamEvent) eventCode {
    
    switch(eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
        {
            if (!recvData) recvData = [[NSMutableData alloc] init];
            
            uint8_t buf[READSIZEPERTIME];
            NSUInteger len = 0;
            len = [(NSInputStream*)stream read:buf maxLength:READSIZEPERTIME];
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
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil;
            recvData = nil;
            break;
        }
        case NSStreamEventEndEncountered:
        {
            void (^completion)(BOOL isSuccess, NSData *data) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(YES, recvData);
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil;
            recvData = nil;
            break;
        }
    }
}

#pragma mark - general function

-(void) readDataFromPath : (NSString*) path withStream : (const void* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess, NSData *data)) completion {
    
    objc_setAssociatedObject(self, &COMPLETIONPOINTER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &STREAMPOINTER, stream, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSInputStream *iStream = [NSInputStream inputStreamWithFileAtPath:path];
    [iStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [iStream open];
}

@end
