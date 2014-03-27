//
//  SFOnTheFly.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFOnTheFly.h"

@interface SFOnTheFly (Private)
-(void) setup : (void (^)(BOOL)) completion stream : (const void* (^)(uint8_t*, unsigned long)) stream toPath : (NSString*) toPath;
-(void) clear;
@end

@implementation SFOnTheFly {
    NSMutableData *dataPool;
    BOOL isInputFail;
    BOOL isOutputFail;
    BOOL isInputFinish;
    NSString *writePath;
}

#pragma mark - private

-(void) setup : (void (^)(BOOL)) completion stream : (const void* (^)(uint8_t*, unsigned long)) stream toPath : (NSString*) toPath {
    objc_setAssociatedObject(self, &COMPLETIONPOINTER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &STREAMPOINTER, stream, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    dataPool = [[NSMutableData alloc] init];
    writePath = [[NSString alloc] initWithString:toPath];
    isInputFail = NO;
    isOutputFail = NO;
    isInputFinish = NO;
}

-(void) clear {
    dataPool = nil;
    writePath = nil;
    objc_removeAssociatedObjects(self);
}

#pragma mark - NSStreamDelegate

-(void) stream : (NSStream*) stream handleEvent : (NSStreamEvent) eventCode {
    
    switch(eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            if ([stream isKindOfClass:[NSInputStream class]]) [self openOutputStreamWithPath:writePath];
            break;
        case NSStreamEventHasBytesAvailable:
        {
            if (!isInputFail && !isOutputFail) {
                uint8_t buf[SIZEPERTIME];
                NSUInteger len = 0;
                len = [(NSInputStream*)stream read:buf maxLength:SIZEPERTIME];
                if (len) {
                    uint8_t dataMirror[len];
                    (void)memcpy(dataMirror, buf, len);
                    
                    const void* (^displayStream)(uint8_t* buffer, unsigned long length) = objc_getAssociatedObject(self, &STREAMPOINTER);
                    [dataPool appendBytes:displayStream(dataMirror, len) length:len];
                }
            } else {
                [self terminateStream:stream];
                [self clear];
            }
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            if (!isInputFail && !isOutputFail) {
                
                uint8_t *readBytes = (uint8_t *)[dataPool mutableBytes];
                NSUInteger data_len = [dataPool length];
                NSUInteger len = (data_len >= SIZEPERTIME) ? SIZEPERTIME : (data_len);
                uint8_t buf[len];
                (void)memcpy(buf, readBytes, len);
                len = [(NSOutputStream*)stream write:buf maxLength:len];
                [dataPool replaceBytesInRange:NSMakeRange(0, len) withBytes:NULL length:0];
                
            } else {
                [self terminateStream:stream];
                [self clear];
            }
            
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            if ([stream isKindOfClass:[NSInputStream class]]) {
                isInputFail = YES;
            } else {
                isOutputFail = YES;
            }
            
            void (^completion)(BOOL isSuccess) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(NO);
            [self terminateStream:stream];
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            if ([stream isKindOfClass:[NSInputStream class]]) {
                isInputFinish = YES;
                [self terminateStream:stream];
                return;
            }
            
            if (isInputFinish) {
                void (^completion)(BOOL isSuccess) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
                completion(YES);
                [self terminateStream:stream];
                [self clear];
            }
            
            break;
        }
    }
}

#pragma mark - general function

-(void) readFromPath : (NSString*) fromPath
         writeToPath : (NSString*) toPath
          withStream : (const void* (^)(uint8_t* buffer, unsigned long length)) stream
          completion : (void (^)(BOOL isSuccess)) completion {
    
    [self setup:completion stream:stream toPath:toPath];
    [self openInputStreamWithPath:fromPath];
    
}

@end
