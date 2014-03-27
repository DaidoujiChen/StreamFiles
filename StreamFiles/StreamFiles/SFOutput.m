//
//  SFOutput.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFOutput.h"

@interface SFOutput (Private)
-(void) setup : (void (^)(BOOL)) completion stream : (const uint8_t* (^)(uint8_t *, unsigned int)) stream data : (NSData*) data;
-(void) clear;
@end

@implementation SFOutput {
    NSMutableData *sendData;
    unsigned int byteIndex;
}

#pragma mark - private

-(void) setup : (void (^)(BOOL)) completion stream : (const uint8_t* (^)(uint8_t *, unsigned int)) stream data : (NSData*) data {
    objc_setAssociatedObject(self, &COMPLETIONPOINTER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &STREAMPOINTER, stream, OBJC_ASSOCIATION_COPY_NONATOMIC);
    byteIndex = 0;
    sendData = [NSMutableData dataWithData:data];
}

-(void) clear {
    sendData = nil;
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
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            uint8_t *readBytes = (uint8_t *)[sendData mutableBytes];
            readBytes += byteIndex;
            NSUInteger data_len = [sendData length];
            NSUInteger len = ((data_len - byteIndex >= SIZEPERTIME) ? SIZEPERTIME : (data_len-byteIndex));
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
            [self terminateStream:stream];
            [self clear];
            break;
        }
        case NSStreamEventEndEncountered:
        {
            void (^completion)(BOOL isSuccess) = objc_getAssociatedObject(self, &COMPLETIONPOINTER);
            completion(YES);
            [self terminateStream:stream];
            [self clear];
            break;
        }
    }
}

#pragma mark - general function

-(void) writeDataToPath : (NSString*) path withData : (NSData*) data withStream : (const uint8_t* (^)(uint8_t* buffer, unsigned int length)) stream completion : (void (^)(BOOL isSuccess)) completion {
    
    [self setup:completion stream:stream data:data];
    [self openOutputStreamWithPath:path];
    
}

@end
