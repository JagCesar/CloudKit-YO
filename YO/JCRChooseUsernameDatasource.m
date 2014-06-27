//
//  JCRChooseUsernameDatasource.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRChooseUsernameDatasource.h"

@implementation JCRChooseUsernameDatasource

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if ([indexPath row] == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"textfieldCell"
                                                         forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"labelCell"
                                                         forIndexPath:indexPath];
    }
    return cell;
}

@end
