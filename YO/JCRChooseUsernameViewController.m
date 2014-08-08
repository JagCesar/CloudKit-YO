//
//  JCRChooseUsernameViewController.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRChooseUsernameViewController.h"
#import "JCRChooseUsernameDatasource.h"
#import "JCRChooseUsernameDelegate.h"
#import "JCRChooseUsernameCollectionViewCell.h"
#import "JCRTextFieldCollectionViewCell.h"
#import "JCRCloudKitManager.h"
#import "JCRCloudKitUser.h"
@import CloudKit;

@interface JCRChooseUsernameViewController () <UITextFieldDelegate>

@property (nonatomic) JCRChooseUsernameDatasource *datasource;
@property (nonatomic) JCRChooseUsernameDelegate *delegate;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation JCRChooseUsernameViewController

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
    
    [self.collectionView setHidden:YES];
    __weak typeof(self) weakSelf = self;
    
    [[JCRCloudKitUser sharedInstance] fetchUserWithSuccessBlock:^(CKRecordID *recordId) {
        __strong typeof(self) strongSelf = weakSelf;
        [JCRCloudKitManager checkIfUsernameIsRegisteredWithRecordId:recordId
                                                       successBlock:^{
                                                           UIViewController *friendsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"friends"];
                                                           [strongSelf presentViewController:friendsViewController
                                                                                    animated:YES
                                                                                  completion:nil];
                                                       }
                                                       failureBlock:^(NSError *error) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [strongSelf.collectionView setHidden:NO];
                                                           });
                                                       }];
    } failureBlock:^(NSError *error) {
#warning What should we do if the user record id can't be fetched? 
    }];
    
    [self setDatasource:[JCRChooseUsernameDatasource new]];
    [self setDelegate:[JCRChooseUsernameDelegate new]];
    [self.delegate setChooseNickBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf __createUsername];
    }];
    
    [self.collectionView setDataSource:[self datasource]];
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

#pragma mark - UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self __createUsername];
    return YES;
}

#pragma - Private

- (void)__createUsername {
    JCRTextFieldCollectionViewCell *textFieldCell = (JCRTextFieldCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                                                                                                     inSection:0]];
    JCRChooseUsernameCollectionViewCell *labelCell = (JCRChooseUsernameCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1
                                                                                                                                    inSection:0]];
    [labelCell.activityIndicatorView startAnimating];
    [labelCell.label setHidden:YES];
    
    NSString *username = textFieldCell.textField.text;
    
    [JCRCloudKitManager registerUsername:username
                            successBlock:^{
                                // Go to friends!
                                UIViewController *friendsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"friends"];
                                [self presentViewController:friendsViewController
                                                   animated:YES
                                                 completion:nil];
                            } failureBlock:^(NSError *error) {
                                [labelCell.label setText:@"USERNAME TAKEN"];
                                [labelCell.activityIndicatorView stopAnimating];
                                [labelCell.label setHidden:NO];
                            }];
}

@end
