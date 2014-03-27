//
//  SFBase.h
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/27.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

static const char COMPLETIONPOINTER;
static const char STREAMPOINTER;

#define SIZEPERTIME 1024

@interface SFBase : NSObject <NSStreamDelegate>

-(void) terminateStream : (NSStream*) stream;

-(void) openInputStreamWithPath : (NSString*) path;
-(void) openOutputStreamWithPath : (NSString*) path;

@end
