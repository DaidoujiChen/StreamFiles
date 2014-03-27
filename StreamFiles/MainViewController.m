//
//  MainViewController.m
//  StreamFiles
//
//  Created by 啟倫 陳 on 2014/3/26.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - life cycle

-(NSString*) documentFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

-(void) runLoop {
    
    //static int i = 0;
    
    [SFManager readDataFromPath:[[self documentFolderPath] stringByAppendingPathComponent:@"videoplayback.mp4"]
                     withStream:^const void *(uint8_t *buffer, unsigned int length) {
                         
                         uint8_t tmpData;
                         
                         tmpData = buffer[0];
                         buffer[0] = buffer[length - 1];
                         buffer[length - 1] = buffer[0];
                         
                         return buffer;
                     }
                     completion:^(BOOL isSuccess, NSData *data) {
                         NSLog(@"%d", data.length);
                         
                         [SFManager writeDataToPath:[[self documentFolderPath] stringByAppendingPathComponent:@"videoplaybackReverse.mp4"]
                                           withData:data
                                         withStream:^const uint8_t *(uint8_t* buffer, unsigned int length) {
                                             return buffer;
                                         }
                                         completion:^(BOOL isSuccess) {
                                             NSLog(@"%d", isSuccess);
                                             //[self runLoop];
                                         }];
                     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*input = [SFInput new];
    output = [SFOutput new];
    
    [input readDataFromPath:[[self documentFolderPath] stringByAppendingPathComponent:@"videoplayback.mp4"]
                 withStream:^const void *(uint8_t *buffer) {
                     return buffer;
                 }
                 completion:^(BOOL isSuccess, NSData *data) {
                     NSLog(@"%d", data.length);
                     
                     [output writeDataToPath:[[self documentFolderPath] stringByAppendingPathComponent:@"videoplayback2.mp4"]
                                    withData:data
                                  withStream:^const uint8_t *(uint8_t *buffer) {
                                      return buffer;
                                  }
                                  completion:^(BOOL isSuccess) {
                                      NSLog(@"%d", isSuccess);
                                  }];
                 }];*/
    
    [self runLoop];
}

@end
