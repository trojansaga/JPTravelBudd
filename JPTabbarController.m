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
//    mapViewController = [[JPMapViewController alloc] initWithNibName:@"JPMapViewController" bundle:nil];
    mapListViewController = [[JPMapListViewController alloc] initWithNibName:@"JPMapListViewController" bundle:nil];
    chatViewController = [[JPChatViewController alloc] initWithNibName:@"JPChatViewController" bundle:nil];
    settingViewController = [[JPSettingViewController alloc] initWithNibName:@"JPSettingViewController" bundle:nil];
    
//    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:mapListViewController];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    
//    self.viewControllers = @[mapViewController,chatViewController,settingViewController];
    self.viewControllers = @[nav1,nav2,nav3];
    self.navigationItem.title = @"fu";
    
    NSArray *tabbarItems = [[self tabBar] items];
    UITabBarItem *mapViewTabbarItem = [tabbarItems objectAtIndex:0];
    UITabBarItem *chatViewTabbarItem = [tabbarItems objectAtIndex:1];
    UITabBarItem *settingViewTabbarItem = [tabbarItems objectAtIndex:2];
    [mapViewTabbarItem setTitle:@"Maps"];
    mapViewTabbarItem.image = [UIImage imageNamed:@"map_marker-25"];
    [chatViewTabbarItem setTitle:@"Chatting"];
    chatViewTabbarItem.image = [UIImage imageNamed:@"collaboration-25"];
    [settingViewTabbarItem setTitle:@"Settings"];
    settingViewTabbarItem.image = [UIImage imageNamed:@"settings-25"];
    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];
//    self.tabBar.barTintColor = [UIColor colorWithRed:159.f/255.f green:208.f/255.f blue:219.f/255.f alpha:1.f];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
