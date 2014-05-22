//
//  JPMapViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMapViewController.h"
#import "JPMapCreationViewController.h"
#import "JPAno.h"

@interface JPMapViewController ()

@end

@implementation JPMapViewController

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

    //map view control
    [mapView setZoomEnabled:YES];
    
    clmgr = [[CLLocationManager alloc] init];
    clmgr.desiredAccuracy = kCLLocationAccuracyBest;
    clmgr.distanceFilter = kCLHeadingFilterNone;

    
    [clmgr setDelegate:self];
    [clmgr startUpdatingLocation];
    
    
    
    
    
    //nav bar customization
    self.navigationItem.title = @"Map";

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Add"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(tick)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    
    
    navBar = self.navigationController.navigationBar;
    
    [self.view insertSubview:navBar atIndex:0];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tock:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [mapView addGestureRecognizer:tapGestureRecognizer];
    
    
    
}

- (void) tock:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"tock");
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    NSLog(@"%f, %f", touchPoint.x, touchPoint.y);
    
    CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];

    NSLog(@"%f, %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);

    
    MKAnnotationView *ano = [[MKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [ano setBackgroundColor:[UIColor redColor]];

    [ano.annotation setCoordinate:touchMapCoordinate];
    MKPlacemark *pinPoint = [[MKPlacemark alloc] initWithCoordinate:touchMapCoordinate addressDictionary:nil];

    [mapView addAnnotation:pinPoint];

    
}


- (void) tick {
    JPMapCreationViewController *mapCreationviewController = [[JPMapCreationViewController alloc] initWithNibName:@"JPMapCreationViewController" bundle:nil];
    [self.navigationController pushViewController:mapCreationviewController animated:YES];
    
    
    
}

-(IBAction)curButClick:(id)sender {

    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
    [mapView setCenterCoordinate:curPos animated:YES];
    [self setCenterCoordinate:curPos zoomLevel:10 animated:YES];


}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*mapView.frame.size.width/256);
    [mapView setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}


-(IBAction)move:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:btn.titleLabel.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
                
            }
            
            
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *cordd = locations.lastObject;
    curPos = [cordd coordinate];
//    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
//    [mapView setCenterCoordinate:curPos];


}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
                
            }
            
            
        }
    }];
    
    [searchBar resignFirstResponder];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    NSString *reuseName = @"anno";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseName];
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseName];
        pin.animatesDrop = YES;
        pin.pinColor = MKPinAnnotationColorGreen;
    }
    else {
        pin.annotation = annotation;
    }
    
    return pin;
}

@end
