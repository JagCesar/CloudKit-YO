//
//  JCRCloudKitManager.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRCloudKitManager.h"

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
