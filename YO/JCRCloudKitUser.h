//
//  JCRCloudKitUser.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;

@interface JCRCloudKitUser : NSObject

@property (nonatomic) CKRecordID *currentUserRecordId;

+ (instancetype)sharedInstance;

- (void)fetchUserWithSuccessBlock:(void(^)(CKRecordID *recordId))successBlock
                     failureBlock:(void(^)(NSError *error))failureBlock;

@end
