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

@end
