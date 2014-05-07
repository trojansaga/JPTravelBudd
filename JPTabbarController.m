//
//  JPTabbarController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPTabbarController.h"

@interface JPTabbarController ()

@end

@implementation JPTabbarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view from its nib.
    mapViewController = [[JPMapViewController alloc] initWithNibName:@"JPMapViewController" bundle:nil];
    chatViewController = [[JPChatViewController alloc] initWithNibName:@"JPChatViewController" bundle:nil];
    settingViewController = [[JPSettingViewController alloc] initWithNibName:@"JPSettingViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    
    self.viewControllers = @[mapViewController,navigationController,settingViewController];
    
    NSArray *tabbarItems = [[self tabBar] items];
    UITabBarItem *mapViewTabbarItem = [tabbarItems objectAtIndex:0];
    UITabBarItem *chatViewTabbarItem = [tabbarItems objectAtIndex:1];
    UITabBarItem *settingViewTabbarItem = [tabbarItems objectAtIndex:2];
    [mapViewTabbarItem setTitle:@"mapView"];
    [chatViewTabbarItem setTitle:@"chatView"];
    [settingViewTabbarItem setTitle:@"settings"];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
