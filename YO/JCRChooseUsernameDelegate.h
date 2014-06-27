//
//  JCRChooseUsernameDelegate.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCRChooseUsernameDelegate : NSObject <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) void (^chooseNickBlock)();

@end
