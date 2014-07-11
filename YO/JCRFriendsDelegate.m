//
//  JCRFriendsDelegate.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 30/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRFriendsDelegate.h"
#import "JCRFriendsDatasource.h"
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
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIColor *defaultColor = [cell backgroundColor];
        [cell setBackgroundColor:[UIColor redColor]];
        CKRecord *record = [self.datasource.friends objectAtIndex:[indexPath row]];
        
        [self.datasource setYoBlock:^(NSError *error) {
            if (error) {
#warning Handle this warning nicely
            } else {
                [cell setBackgroundColor:defaultColor];
            }
        }];
        
        [self.datasource sendYoToFriend:record];
    }
}

@end
