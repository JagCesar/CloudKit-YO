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
#import "JCRCloudKitManager.h"

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
        [cell.label setHidden:YES];
        [cell.activityIndicatorView startAnimating];
        
        CKRecord *friendRecord = [self.datasource.friends objectAtIndex:[indexPath row]];
        [JCRCloudKitManager sendYoToFriend:friendRecord
                              successBlock:^{
                                  [cell.label setHidden:NO];
                                  [cell.activityIndicatorView stopAnimating];
                                  NSString *originalString = [cell.label text];
                                  [cell.label setText:@"SENT!"];
                                  [cell.label performSelector:@selector(setText:)
                                                   withObject:originalString
                                                   afterDelay:2.f];
                              }
                              failureBlock:^(NSError *error) {
                                  [cell.label setHidden:NO];
                                  [cell.activityIndicatorView stopAnimating];
                                  NSString *originalString = [cell.label text];
                                  [cell.label setText:@"FAILED :("];
                                  [cell.label performSelector:@selector(setText:)
                                                   withObject:originalString
                                                   afterDelay:2.f];
                              }];
    }
}

@end
