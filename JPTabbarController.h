//
//  JPTabbarController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "JPMapViewController.h"
#import "JPMapListViewController.h"
#import "JPChatViewController.h"
#import "JPSettingViewController.h"

@interface JPTabbarController : UITabBarController {
//    JPMapViewController     *mapViewController;
    JPMapListViewController *mapListViewController;
    JPChatViewController    *chatViewController;
    JPSettingViewController *settingViewController;
}

@end
