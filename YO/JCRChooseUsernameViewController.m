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
@import CloudKit;

@interface JCRChooseUsernameViewController () <UITextFieldDelegate>

@property (nonatomic) JCRChooseUsernameDatasource *datasource;
@property (nonatomic) JCRChooseUsernameDelegate *delegate;
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CKRecordID *userRecord;

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
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            
        } else {
            [strongSelf setUserRecord:recordID];
            
            [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"username"
                                                                                                         predicate:[NSPredicate predicateWithFormat:@"creatorUserRecordID = %@", recordID]]
                                                                  inZoneWithID:nil
                                                             completionHandler:^(NSArray *results, NSError *error) {
                                                                 if (error || results.count > 0) {
                                                                     // Welcome back!
                                                                     [self __setupPushNotificationsForUsername:[results.firstObject objectForKey:@"username"]];
                                                                     
                                                                     // Go to friends list
                                                                     UIViewController *friendsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"friends"];
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         [strongSelf presentViewController:friendsViewController
                                                                                            animated:YES
                                                                                          completion:nil];
                                                                     });
                                                                 } else {
                                                                     // Show collection view
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         [strongSelf.collectionView setHidden:NO];
                                                                     });
                                                                 }
                                                             }];
        }
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
    
    [[[CKContainer defaultContainer] publicCloudDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"username"
                                                                                                 predicate:[NSPredicate predicateWithFormat:@"username = %@", username]]
                                                          inZoneWithID:nil
                                                     completionHandler:^(NSArray *results, NSError *error) {
                                                         if (error || results.count > 0) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [labelCell.label setText:@"USERNAME TAKEN"];
                                                                 [labelCell.activityIndicatorView stopAnimating];
                                                                 [labelCell.label setHidden:NO];
                                                             });
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
                                                                                                                    [self __setupPushNotificationsForUsername:[record.recordID recordName]];
                                                                                                                    // Go to friends!
                                                                                                                    UIViewController *friendsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"friends"];
                                                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                        [self presentViewController:friendsViewController
                                                                                                                                           animated:YES
                                                                                                                                         completion:nil];
                                                                                                                    });
                                                                                                                }
                                                                                                            }];
                                                         }
                                                     }];
}

- (void)__setupPushNotificationsForUsername:(NSString*)username {
//    [[[CKContainer defaultContainer] publicCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray *subscriptions, NSError *error) {
//        for (CKSubscription *subscription in subscriptions) {
//            [[[CKContainer defaultContainer] publicCloudDatabase] deleteSubscriptionWithID:[subscription subscriptionID]
//                                                                         completionHandler:^(NSString *subscriptionID, NSError *error) {
//                                                                             if (error) {
//                                                                                 NSLog(@"Couldn't delete subsciption");
//                                                                             } else {
//                                                                                 NSLog(@"Deleted a subscription");
//                                                                             }
//                                                                         }];
//        }
//    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"to = %@", username];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"YO"
                                                                    predicate:predicate
                                                                      options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    [notificationInfo setDesiredKeys:@[@"to",@"from"]];
    [notificationInfo setAlertLocalizationArgs:@[@"from"]];
    [notificationInfo setAlertBody:@"%@ JUST YO:ED YOU!"];
    [notificationInfo setShouldBadge:YES];
    
    [subscription setNotificationInfo:notificationInfo];
    
    [[[CKContainer defaultContainer] publicCloudDatabase] saveSubscription:subscription
                                                         completionHandler:^(CKSubscription *subscription, NSError *error) {
                                                             if (error) {
#warning Handle error
                                                             } else {
                                                                 NSLog(@"Push notification registered!");
                                                             }
                                                         }];
}

@end
