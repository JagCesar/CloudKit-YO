//
//  JCRCloudKitUser.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRCloudKitUser.h"

@implementation JCRCloudKitUser

+ (instancetype)sharedInstance {
    static JCRCloudKitUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [JCRCloudKitUser new];
    });
    return sharedInstance;
}

- (void)fetchUserWithSuccessBlock:(void(^)(CKRecordID *recordId))successBlock
                     failureBlock:(void(^)(NSError *error))failureBlock {
    __weak typeof(self) weakSelf = self;
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        } else {
            [strongSelf setCurrentUserRecordId:recordID];
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(recordID);
            });
        }
    }];
}

@end
