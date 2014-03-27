//
//  SFOutput.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFOutput.h"

#import <objc/runtime.h>

@implementation SFOutput

#define WRITESIZEPERTIME 1024

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
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            uint8_t *readBytes = (uint8_t *)[sendData mutableBytes];
            readBytes += byteIndex;
            NSUInteger data_len = [sendData length];
            NSUInteger len = ((data_len - byteIndex >= WRITESIZEPERTIME) ? WRITESIZEPERTIME : (data_len-byteIndex));
            uint8_t buf[len];
            (void)memcpy(buf, readBytes, len);
            
            uint8_t dataMirror[len];
            (void)memcpy(dataMirror, readBytes, len);
            
            const uint8_t* (^displayStream)(uint8_t* buffer, unsigned int length) = objc_getAssociatedObject(self, &STREAMPOINTER);
            len = [(NSOutputStream*)stream write:displayStream(dataMirror, len) maxLength:len];
            byteIndex += len;
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            void (^completion)(BOOL isSuccess) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(NO);
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil;
            sendData = nil;
            break;
        }
        case NSStreamEventEndEncountered:
        {
            void (^completion)(BOOL isSuccess) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(YES);
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil;
            sendData = nil;
            break;
        }
    }
}

#pragma mark - general function

-(void) writeDataToPath : (NSString*) path withData : (NSData*) data withStream : (const uint8_t* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess)) completion {
    
    objc_setAssociatedObject(self, &COMPLETIONPOINTER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &STREAMPOINTER, stream, OBJC_ASSOCIATION_COPY_NONATOMIC);
    byteIndex = 0;
    sendData = [NSMutableData dataWithData:data];
    
    NSOutputStream *oStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [oStream setDelegate:self];
    [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [oStream open];
}

@end
