//
//  JPChattingRoomMapViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 10. 1..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChattingRoomMapViewController.h"
#import "MapRecord.h"
#import "JPMapAnnotation.h"

@interface JPChattingRoomMapViewController ()

@end

@implementation JPChattingRoomMapViewController

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
    // Do any additional setup after loading the view.

                     
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSLog(@"gioajgpaoijfpoasdjfpo=============================");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)refreshMap {
    
    self.labelForTitle.text = self.mapData.m_MapTitle;
//    labelForTotalBudget.text = [_mapData.m_TotalBudget stringValue];
    NSLog(@"%@", _mapData.m_MapTitle);
    NSLog(@"%@", [_mapData.m_TotalBudget stringValue]);

//    JPMapAnnotation *pin = [[JPMapAnnotation alloc] init];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) animated:YES];

    
}

- (void) addPins {
    NSLog(@"adf");
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
