//
//  JPSettingViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPSettingViewController.h"

@interface JPSettingViewController ()

@end

@implementation JPSettingViewController

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
    self.title = @"Settings";
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.2f];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    _textViewForIntroduction.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.6f];
    _textViewForIntroduction.textColor = [UIColor whiteColor];
    
    NSNumber *isAutoOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoLoginOn"];
    if ([isAutoOn isEqual:@(YES)]) {
        _switchForAutoLogin.on = YES;
        _idTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedID"];
        _pwTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPASSWORD"];
    }
    else{
        _switchForAutoLogin.on = NO;
        _idTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"];
        _pwTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAutoLogin:(id)sender {
    
    NSNumber *isAutoLoginOn;
    
    if (_switchForAutoLogin.on == NO) {
        NSLog(@"no");
        isAutoLoginOn = @(NO);
        [[NSUserDefaults standardUserDefaults] setObject:isAutoLoginOn forKey:@"isAutoLoginOn"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"savedID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"savedPASSWORD"];
        
    }
    else {
        NSLog(@"yes");
        isAutoLoginOn = @(YES);
        [[NSUserDefaults standardUserDefaults] setObject:isAutoLoginOn forKey:@"isAutoLoginOn"];
        [[NSUserDefaults standardUserDefaults] setObject:_idTextField.text forKey:@"savedID"];
        [[NSUserDefaults standardUserDefaults] setObject:_pwTextField.text forKey:@"savedPASSWORD"];
    }
}

@end
