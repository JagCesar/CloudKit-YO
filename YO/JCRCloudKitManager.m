//
//  JCRCloudKitManager.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRCloudKitManager.h"
#import "JCRCloudKitUser.h"

@implementation JCRCloudKitManager

+ (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock {
    [[self __publicDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"usernames"
                                                                    predicate:[NSPredicate predicateWithFormat:@"username = %@", username]]
                             inZoneWithID:nil
                        completionHandler:^(NSArray *results, NSError *error) {
                            if (error || results.count > 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{
#warning Create a proper error
                                    failureBlock(nil);
                                });
                            } else {
                                // Create username
                                CKRecord *record = [[CKRecord alloc] initWithRecordType:@"usernames"];
                                [record setObject:username
                                           forKey:@"username"];
                                [[self __publicDatabase] saveRecord:record
                                                  completionHandler:^(CKRecord *record, NSError *error) {
                                                      if (error) {
                                                          failureBlock(error);
                                                      } else {
                                                          [[JCRCloudKitUser sharedInstance] setCurrentUserRecord:record];
                                                          [self __setupPushNotificationsForUsername:username];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              successBlock();
                                                          });
                                                      }
                                                  }];
                            }
                        }];
}

+ (void)checkIfUsernameIsRegisteredWithRecordId:(CKRecordID*)recordId
                                   successBlock:(void(^)())successBlock
                                   failureBlock:(void(^)(NSError* error))failureBlock {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creatorUserRecordID = %@", recordId];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"usernames"
                                               predicate:predicate];
    [[self __publicDatabase] performQuery:query
                             inZoneWithID:nil
                        completionHandler:^(NSArray *results, NSError *error) {
                            if (error || results.count == 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{
#warning Set up an error if error is nil and results == 0
                                    failureBlock(error);
                                });
                            } else {
                                [self __setupPushNotificationsForUsername:[results.firstObject objectForKey:@"username"]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    successBlock();
                                });
                            }
                        }];
}

+ (void)checkIfUsernameIsRegistered:(NSString*)username
                       successBlock:(void(^)(BOOL usernameExists))successBlock
                       failureBlock:(void(^)(NSError *error))failureBlock {
    CKQuery *query = [[CKQuery alloc]
                      initWithRecordType:@"usernames"
                      predicate:[NSPredicate
                                 predicateWithFormat:@"username = %@", username]];
    [[self __publicDatabase] performQuery:query
                             inZoneWithID:nil
                        completionHandler:^(NSArray *results, NSError *error) {
                            if (error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failureBlock(error);
                                });
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    BOOL usernameExists = (results.count > 0) ? YES : NO;
                                    successBlock(usernameExists);
                                });
                            }
                        }];
}

+ (void)addFriendWithUsername:(NSString*)username
                 successBlock:(void(^)(CKRecord *newFriend))successBlock
                 failureBlock:(void(^)(NSError *error))failureBlock {
    [self checkIfUsernameIsRegistered:username
                         successBlock:^(BOOL usernameExists) {
                             if (usernameExists) {
                                 CKRecord *newFriend = [[CKRecord alloc] initWithRecordType:@"friend"];
                                 [newFriend setObject:username
                                               forKey:@"username"];
                                 CKRecord *record = [[JCRCloudKitUser sharedInstance] currentUserRecord];
                                 CKReference *newFriendReference = [[CKReference alloc] initWithRecord:record
                                                                                                action:CKReferenceActionDeleteSelf];
                                 newFriend[@"friend"] = newFriendReference;
                                 
                                 [[[CKContainer defaultContainer] publicCloudDatabase] saveRecord:newFriend
                                                                                completionHandler:^(CKRecord *record, NSError *error) {
                                                                                    if (error) {
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            failureBlock(error);
                                                                                        });
                                                                                    } else {
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            successBlock(newFriend);
                                                                                        });
                                                                                    }
                                                                                }];
                             } else {
                                 NSError *error = [NSError errorWithDomain:@"se.jagcesar"
                                                                      code:1
                                                                  userInfo:@{NSLocalizedDescriptionKey: @"User doesn't exist"
                                                                             }];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     failureBlock(error);
                                 });
                             }
                         } failureBlock:^(NSError *error) {
                             failureBlock(error);
                         }];
}

+ (void)sendYoToFriend:(CKRecord *)friendRecord
          successBlock:(void (^)())successBlock
          failureBlock:(void (^)(NSError *))failureBlock {
    CKRecord *yoRecord = [[CKRecord alloc] initWithRecordType:@"YO"];
    CKRecord *currentUserRecord = [[JCRCloudKitUser sharedInstance] currentUserRecord];
    [yoRecord setObject:[currentUserRecord objectForKey:@"username"]
                 forKey:@"from"];
    [yoRecord setObject:[friendRecord objectForKey:@"username"]
                 forKey:@"to"];
    [[[CKContainer defaultContainer] publicCloudDatabase] saveRecord:yoRecord
                                                   completionHandler:^(CKRecord *record, NSError *error) {
                                                       if (error) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               failureBlock(error);
                                                           });
                                                       } else {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               successBlock();
                                                           });
                                                       }
                                                   }];
}


+ (void)loadFriendsToCurrentUserWithSuccessBlock:(void(^)(NSArray *friends))successBlock
                                    failureBlock:(void(^)(NSError *error))failureBlock {
    CKRecord *currentUserRecord = [[JCRCloudKitUser sharedInstance] currentUserRecord];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"friend"
                                               predicate:[NSPredicate predicateWithFormat:@"friend = %@", [currentUserRecord recordID]]];
    [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:query
                                                          inZoneWithID:nil
                                                     completionHandler:^(NSArray *results, NSError *error) {
                                                         if (error) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 failureBlock(error);
                                                             });
                                                         } else {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 successBlock(results);
                                                             });
                                                         }
                                                     }];
}

#pragma mark - Private functions

+ (CKDatabase*)__publicDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}

+ (void)__setupPushNotificationsForUsername:(NSString*)username {
    //    [[[CKContainer defaultContainer] publicCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray *subscriptions, NSError *error) {
    //        for (CKSubscription *subscription in subscriptions) {
    //            [[[CKContainer defaultContainer] publicCloudDatabase] deleteSubscriptionWithID:[subscription subscriptionID]
    //                                                                         completionHandler:^(NSString *subscriptionID, NSError *error) {
    //                                                                             if (error) {
    //                                                                                 NSLog(@"Couldn't delete subsciption");
    //                                                                             } else {
    //                                                                                 NSLog(@"Deleted a subscription");
    //                                                                             }
    //                                                                         }];
    //        }
    //    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"to = %@", username];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"YO"
                                                                    predicate:predicate
                                                                      options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    [notificationInfo setDesiredKeys:@[@"to",@"from"]];
    [notificationInfo setAlertLocalizationArgs:@[@"from"]];
    [notificationInfo setAlertBody:@"%@ JUST YO:ED YOU!"];
    [notificationInfo setShouldBadge:YES];
    
    [subscription setNotificationInfo:notificationInfo];
    
    [[[CKContainer defaultContainer] publicCloudDatabase] saveSubscription:subscription
                                                         completionHandler:^(CKSubscription *subscription, NSError *error) {
                                                             if (error) {
#warning Handle error
                                                             } else {
#warning success
                                                             }
                                                         }];
}

@end
