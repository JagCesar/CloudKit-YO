//
//  JCRFriendsViewController.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 27/06/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRFriendsViewController.h"
#import "JCRFriendsDatasource.h"

@interface JCRFriendsViewController ()

@property (nonatomic) JCRFriendsDatasource *datasource;
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
    
    [self.collectionView setDataSource:[self datasource]];
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

@end
