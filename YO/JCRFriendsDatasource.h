//
//  JCRFriendsDatasource.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCRFriendsDatasource : NSObject <UICollectionViewDataSource>

@property (nonatomic) NSMutableArray *friends;
@property (nonatomic,strong) void (^refreshBlock)();
@property (nonatomic,strong) void (^addedFriendBlock)();
@property (nonatomic,strong) void (^failedAddingFriendBlock)(NSError *error);

- (void)addFriendWithNick:(NSString*)username;

@end
