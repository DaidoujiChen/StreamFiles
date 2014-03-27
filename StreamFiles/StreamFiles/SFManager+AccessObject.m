//
//  SFManager+AccessObject.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "SFManager+AccessObject.h"

@implementation SFManager (AccessObject)

static const char STREAMPOOLPOINTER;

+(NSMutableArray*) streamPool {
    if (!objc_getAssociatedObject(self, &STREAMPOOLPOINTER)) {
        objc_setAssociatedObject(self, &STREAMPOOLPOINTER, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &STREAMPOOLPOINTER);
}

@end
