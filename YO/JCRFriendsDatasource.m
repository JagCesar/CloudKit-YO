//
//  JCRFriendsDatasource.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRFriendsDatasource.h"
@import CloudKit;
#import "JCRLabelCollectionViewCell.h"
#import "JCRChooseUsernameCollectionViewCell.h"
#import "JCRCloudKitManager.h"
#import "JCRCloudKitUser.h"

typedef NS_ENUM(NSInteger, JCRCellType) {
    JCRCellTypeFriend,
    JCRCellTypeAddFriend
};

@interface JCRFriendsDatasource ()

@end

@implementation JCRFriendsDatasource

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setFriends:[NSMutableArray new]];
        
        __weak typeof(self) weakSelf = self;
        CKRecordID *recordId = [[JCRCloudKitUser sharedInstance] currentUserRecordId];
        
        // Load friends
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"friend"
                                                   predicate:[NSPredicate predicateWithFormat:@"friend = %@", recordId]];
        [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:query
                                                              inZoneWithID:nil
                                                         completionHandler:^(NSArray *results, NSError *error) {
                                                             __strong typeof(self) strongSelf = weakSelf;
                                                             [self setFriends:[results mutableCopy]];
                                                             if ([strongSelf refreshBlock]) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     strongSelf.refreshBlock();
                                                                 });
                                                             }
                                                         }];
    }
    return self;
}

- (void)addFriendWithNick:(NSString*)username {
    // The cell is loading when we reach this selector
    __weak typeof(self) weakSelf = self;
    [JCRCloudKitManager checkIfUsernameIsRegistered:username
                                       successBlock:^(BOOL usernameExists) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           if (usernameExists) {
                                               [JCRCloudKitManager addFriendWithUsername:username
                                                                            successBlock:^(CKRecord *newFriend){
                                                                                [strongSelf.friends addObject:newFriend];
                                                                                if ([strongSelf addedFriendBlock]) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        strongSelf.addedFriendBlock();
                                                                                    });
                                                                                }
                                                                            }
                                                                            failureBlock:^(NSError *error) {
                                                                                if (strongSelf.failedAddingFriendBlock) {
                                                                                    strongSelf.failedAddingFriendBlock(error);
                                                                                }
                                                                            }];
                                           } else {
                                               NSError *error = [NSError errorWithDomain:@"se.jagcesar"
                                                                                    code:1
                                                                                userInfo:@{NSLocalizedDescriptionKey: @"User doesn't exist"
                                                                                           }];
                                               if ([strongSelf failedAddingFriendBlock]) {
                                                   strongSelf.failedAddingFriendBlock(error);
                                               }
                                           }
                                       }
                                       failureBlock:^(NSError *error) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           if ([strongSelf failedAddingFriendBlock]) {
                                               strongSelf.failedAddingFriendBlock(error);
                                           }
                                       }];
}

- (void)sendYoToFriend:(CKRecord*)friend from:(CKRecord*)me {
    CKRecord *yoRecord = [[CKRecord alloc] initWithRecordType:@"YO"];
    [yoRecord setObject:[me objectForKey:@"username"]
                 forKey:@"from"];
    [yoRecord setObject:[friend objectForKey:@"username"]
                 forKey:@"to"];
    [[[CKContainer defaultContainer] publicCloudDatabase] saveRecord:yoRecord
                                                   completionHandler:^(CKRecord *record, NSError *error) {
                                                       if ([self yoBlock]) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               self.yoBlock(error);
                                                           });
                                                       }
                                                   }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    // We add 1 for the Add friend cell
    return [self.friends count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.friends count] == [indexPath row]) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addFriendCell"
                                                                               forIndexPath:indexPath];
        return cell;
    } else {
        JCRChooseUsernameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendCell"
                                                                                              forIndexPath:indexPath];
        CKRecord *friend = [self.friends objectAtIndex:[indexPath row]];
        [cell.label setText:[friend objectForKey:@"username"]];
        return cell;
    }
}

@end
