//
//  SFBase.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFBase.h"

@implementation SFBase

-(void) terminateStream : (NSStream*) stream {
    [stream close];
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    stream = nil;
}

-(void) openInputStreamWithPath : (NSString*) path {
    NSInputStream *iStream = [NSInputStream inputStreamWithFileAtPath:path];
    [iStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [iStream open];
}

-(void) openOutputStreamWithPath : (NSString*) path {
    NSOutputStream *oStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [oStream setDelegate:self];
    [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [oStream open];
}

@end
