//
//  JCRFriendsViewController.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRFriendsViewController.h"
#import "JCRFriendsDatasource.h"
#import "JCRAddFriendCollectionViewCell.h"
#import "JCRFriendsDelegate.h"
@import CloudKit;

@interface JCRFriendsViewController () <UITextFieldDelegate>

@property (nonatomic) JCRFriendsDatasource *datasource;
@property (nonatomic) JCRFriendsDelegate *delegate;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation JCRFriendsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setDatasource:[JCRFriendsDatasource new]];
    __weak typeof(self) weakSelf = self;
    [self.datasource setRefreshBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.collectionView reloadData];
    }];
    [self.datasource setAddedFriendBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        JCRAddFriendCollectionViewCell *cell = (JCRAddFriendCollectionViewCell*)[strongSelf.collectionView
                                                                                 cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[strongSelf.collectionView numberOfItemsInSection:0]-1
                                                                                                                           inSection:0]];
        [cell.activityIndicatorView stopAnimating];
        [cell.label setHidden:NO];
        [strongSelf.collectionView reloadData];
    }];
    [self.datasource setFailedAddingFriendBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        JCRAddFriendCollectionViewCell *cell = (JCRAddFriendCollectionViewCell*)[strongSelf.collectionView
                                                                                 cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[strongSelf.collectionView numberOfItemsInSection:0]-1
                                                                                                                           inSection:0]];
        [cell.activityIndicatorView stopAnimating];
        [cell.label setHidden:NO];
        [strongSelf.collectionView reloadData];
    }];
    [self.collectionView setDataSource:[self datasource]];
    
    [self setDelegate:[JCRFriendsDelegate new]];
    [self.delegate setAddFriendBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        JCRAddFriendCollectionViewCell *cell = (JCRAddFriendCollectionViewCell*)[strongSelf.collectionView
                                                                                 cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[strongSelf.collectionView numberOfItemsInSection:0]-1
                                                                                                                           inSection:0]];
        [cell.textField becomeFirstResponder];
    }];
    [self.collectionView setDelegate:[self delegate]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private

- (void)__addFriendWithUsername:(NSString*)username {
    [self.datasource addFriendWithNick:username];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    JCRAddFriendCollectionViewCell *cell = (JCRAddFriendCollectionViewCell*)[textField.superview superview];
    [cell.label setHidden:YES];
    [cell.textField setHidden:NO];
    [self.collectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 216.f, 0.f)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Add to data source
    
    NSString *username = [textField text];
    JCRAddFriendCollectionViewCell *cell = (JCRAddFriendCollectionViewCell*)[textField.superview superview];
    [cell.textField resignFirstResponder];
    [cell.textField setHidden:YES];
    [cell.activityIndicatorView startAnimating];
    
    [self.datasource addFriendWithNick:username];
    
    return YES;
}

@end
