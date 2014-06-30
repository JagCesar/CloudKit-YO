//
//  JCRFriendsDelegate.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 30/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

@import UIKit;

@interface JCRFriendsDelegate : NSObject <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) void (^addFriendBlock)();

@end
