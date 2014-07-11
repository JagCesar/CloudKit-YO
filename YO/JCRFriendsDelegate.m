//
//  JCRFriendsDelegate.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 30/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRFriendsDelegate.h"
#import "JCRFriendsDatasource.h"
#import "JCRChooseUsernameCollectionViewCell.h"
@import CloudKit;

@implementation JCRFriendsDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320.f, 100.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == [collectionView numberOfItemsInSection:0]-1) {
        if (self.addFriendBlock) {
            self.addFriendBlock();
        }
    } else {
        // Yo a Friend
        
        JCRChooseUsernameCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        CKRecord *record = [self.datasource.friends objectAtIndex:[indexPath row]];
        [cell.label setHidden:YES];
        [cell.activityIndicatorView startAnimating];
        
        [self.datasource setYoBlock:^(NSError *error) {
            if (error) {
                [cell.label setHidden:NO];
                [cell.activityIndicatorView stopAnimating];
                NSString *originalString = [cell.label text];
                [cell.label setText:@"FAILED :("];
                [cell.label performSelector:@selector(setText:)
                                 withObject:originalString
                                 afterDelay:2.f];
            } else {
                [cell.label setHidden:NO];
                [cell.activityIndicatorView stopAnimating];
                NSString *originalString = [cell.label text];
                [cell.label setText:@"SENT!"];
                [cell.label performSelector:@selector(setText:)
                                 withObject:originalString
                                 afterDelay:2.f];
            }
        }];
        
        __weak typeof(self) weakSelf = self;
        [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (error) {
                strongSelf.datasource.yoBlock(error);
            } else {
                [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"username"
                                                                                                             predicate:[NSPredicate predicateWithFormat:@"creatorUserRecordID = %@", recordID]]
                                                                      inZoneWithID:nil
                                                                 completionHandler:^(NSArray *results, NSError *error) {
                                                                     if (results.count == 1) {
                                                                         [self.datasource sendYoToFriend:record from:[results firstObject]];
                                                                     } else {
                                                                         strongSelf.datasource.yoBlock(error);
                                                                     }
                                                                 }];
            }
        }];
    }
}

@end
