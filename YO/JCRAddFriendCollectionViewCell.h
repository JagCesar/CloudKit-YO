//
//  JCRAddFriendCollectionViewCell.h
//  YO
//
//  Created by César Manuel Pinto Castillo on 30/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCRLabelCollectionViewCell.h"

@interface JCRAddFriendCollectionViewCell : JCRLabelCollectionViewCell

@property (nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
