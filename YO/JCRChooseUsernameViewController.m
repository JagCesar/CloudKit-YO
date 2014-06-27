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
#import "JCRLabelCollectionViewCell.h"
#import "JCRTextFieldCollectionViewCell.h"
@import CloudKit;

@interface JCRChooseUsernameViewController ()

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
    
    [self setDatasource:[JCRChooseUsernameDatasource new]];
    [self setDelegate:[JCRChooseUsernameDelegate new]];
    __weak typeof(self) weakSelf = self;
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
    JCRLabelCollectionViewCell *labelCell = (JCRLabelCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1
                                                                                                                                    inSection:0]];
    [labelCell.activityIndicatorView startAnimating];
    [labelCell.label setHidden:YES];
    
    NSString *username = textFieldCell.textField.text;
    
    [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"username"
                                                                                                 predicate:[NSPredicate predicateWithFormat:@"username = %@", username]]
                                                          inZoneWithID:nil
                                                     completionHandler:^(NSArray *results, NSError *error) {
                                                         if (error) {
                                                             [labelCell.activityIndicatorView stopAnimating];
                                                             [labelCell.label setHidden:NO];
                                                         } else if (results.count > 0) {
                                                             [labelCell.activityIndicatorView stopAnimating];
                                                             [labelCell.label setHidden:NO];
                                                         } else {
                                                             // Create username
                                                             CKRecord *record = [[CKRecord alloc] initWithRecordType:@"username"];
                                                             [record setObject:textFieldCell.textField.text forKey:@"username"];
                                                             [[[CKContainer defaultContainer] publicCloudDatabase] saveRecord:record
                                                                                                            completionHandler:^(CKRecord *record, NSError *error) {
                                                                                                                if (error) {
                                                                                                                    [labelCell.activityIndicatorView stopAnimating];
                                                                                                                    [labelCell.label setHidden:NO];
                                                                                                                } else {
                                                                                                                    // Go to friends!
                                                                                                                }
                                                                                                            }];
                                                         }
                                                     }];
}

@end
