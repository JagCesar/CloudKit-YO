//
//  JCRCloudKitManager.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRCloudKitManager.h"
@import CloudKit;

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
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              successBlock();
                                                          });
                                                      }
                                                  }];
                            }
                        }];
}

#pragma mark - Private functions

+ (CKDatabase*)__publicDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}

@end
