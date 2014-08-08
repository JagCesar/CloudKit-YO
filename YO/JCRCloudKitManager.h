//
//  JCRCloudKitManager.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;

@interface JCRCloudKitManager : NSObject

+ (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock;

+ (void)checkIfUsernameIsRegisteredWithRecordId:(CKRecordID*)recordId
                                   successBlock:(void(^)())successBlock
                                   failureBlock:(void(^)(NSError* error))failureBlock;

+ (void)checkIfUsernameIsRegistered:(NSString*)username
                       successBlock:(void(^)(BOOL usernameExists))successBlock
                       failureBlock:(void(^)(NSError *error))failureBlock;

+ (void)addFriendWithUsername:(NSString*)username
                 successBlock:(void(^)(CKRecord *newFriend))successBlock
                 failureBlock:(void(^)(NSError *error))failureBlock;

+ (void)sendYoToFriend:(CKRecord*)friendRecord
          successBlock:(void(^)())successBlock
          failureBlock:(void(^)(NSError *error))failureBlock;

+ (void)loadFriendsToCurrentUserWithSuccessBlock:(void(^)(NSArray *friends))successBlock
                                    failureBlock:(void(^)(NSError *error))failureBlock;

@end
