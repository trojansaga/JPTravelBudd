//
//  JPMapViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMapViewController.h"
#import "JPAppDelegate.h"
#import "MapRecord.h"
#import "PinRecord.h"


@interface JPMapViewController ()

@end

@implementation JPMapViewController

#pragma mark - Basic

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

    //map view setting
    [_mapView setZoomEnabled:YES];

    clmgr = [[CLLocationManager alloc] init];
    clmgr.desiredAccuracy = kCLLocationAccuracyBest;
    clmgr.distanceFilter = kCLHeadingFilterNone;
    
    [clmgr setDelegate:self];
    [clmgr startUpdatingLocation];
    

    //
    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    
    
    //nav bar customization
    self.navigationItem.title = @"Map";

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Save"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(saveCurrentMap)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    
//    navBar = self.navigationController.navigationBar;
    
//    [self.view insertSubview:navBar atIndex:0];
    

    //TapGestureRecongnizer
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(changeTitle)];
    tg.numberOfTapsRequired = 1;
    tg.numberOfTouchesRequired = 1;
    [self.navigationItem.titleView addGestureRecognizer:tg];
    /////////////////////// 제목 변경하는거 왜안되는거지 시바ㅏㅏㅏㅏㅏㅏㅏㅏㅏ
    //titleview = nil임... 뭐가문젤까용
    
    
    
    
    

    UILongPressGestureRecognizer *longPressGestureRecongnizer = [[UILongPressGestureRecognizer alloc]
                                                                 initWithTarget:self
                                                                 action:@selector(longPressOnMapView:)];
    [_mapView addGestureRecognizer:longPressGestureRecongnizer];
    
    
    [pinSaveView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    [self.view addSubview:pinSaveView];
    [pinSaveView setAlpha:0];

    _pins = [[NSMutableArray alloc] init];

    //core data setting
//    _mapRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
//    NSFetchRequest *fetchReqest = [[NSFetchRequest alloc] initWithEntityName:@"MapRecord"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"m_MapTitle == %@",nil];
//    [fetchReqest setPredicate:predicate];
//    NSArray *arr = [_managedObjectContext executeFetchRequest:fetchReqest error:nil];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = @"noname";
    
    
    
    
    // 처음 만들었을때
    if (_mapRecord == nil) {
        UIAlertView *titleSetAV = [[UIAlertView alloc]
                           initWithTitle:@"insert Title"
                           message:nil
                           delegate:self
                           cancelButtonTitle:@"cancel"
                           otherButtonTitles:@"ok", nil];
        titleSetAV.alertViewStyle = UIAlertViewStylePlainTextInput;
        [titleSetAV show];
        
        _mapRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
        
    }
    

    
    // 존재하는 시키
    else {
        self.title = [_mapRecord m_MapTitle];
//        NSLog(@"how many pins? %lu", [_mapRecord.pins count]);



        for (PinRecord *pin in _mapRecord.pins) {
            double longitude = [pin.p_Longitude doubleValue];
            double latitude = [pin.p_Latitude doubleValue];
            MKPlacemark *anno = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
            
            [_mapView addAnnotation:anno];

            [_pins addObject:anno];
        

        }
        
        NSArray *arr = _pins;

        for (int i = 0; i < [arr count]; i++) {
            MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];

            
            //temp si
            if (i+1 == [arr count]) {
                break;
            }
            
            [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:i]]];
            [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:(i+1)]]];
            directionsRequest.transportType = MKDirectionsTransportTypeWalking;

            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    data = [[response routes] lastObject];
                    [_mapView addOverlay:data.polyline];
                    NSLog(@"wow");
                }
            }];


        }
    }


    
}

#pragma mark - Actions

- (void) changeTitle {
    UIAlertView *titleSetAV = [[UIAlertView alloc]
                               initWithTitle:@"insert Title"
                               message:nil
                               delegate:self
                               cancelButtonTitle:@"cancel"
                               otherButtonTitles:@"ok", nil];
    titleSetAV.alertViewStyle = UIAlertViewStylePlainTextInput;
    [titleSetAV show];
    
}

//- (IBAction)routeButtonPressed:(UIBarButtonItem *)sender {
//    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
//    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
//    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
//    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
//    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Error %@", error.description);
//        } else {
//            
//            routeDetails = response.routes.lastObject;
//            [self.mapView addOverlay:routeDetails.polyline];
//            self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
//            self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
//            self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
//            self.allSteps = @"";
//            for (int i = 0; i < routeDetails.steps.count; i++) {
//                MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
//                NSString *newStep = step.instructions;
//                self.allSteps = [self.allSteps stringByAppendingString:newStep];
//                self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
//                self.steps.text = self.allSteps;
//            }
//        }
//    }];
//}

- (void) saveCurrentMap {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Saved"
                              message:@"success"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"ok", nil];
    [alertView show];
    [_managedObjectContext save:nil];
    
    
}

- (IBAction)clickPinSaveButton:(id)sender {
    [pinSaveView setAlpha:0];
    
    
    PinRecord *pinRecord = [NSEntityDescription insertNewObjectForEntityForName:@"PinRecord" inManagedObjectContext:_managedObjectContext];
    [pinRecord setP_Title:pinTextFieldForTitle.text];
    [pinRecord setP_Longitude:[NSNumber numberWithDouble:pinLongitude]];
    [pinRecord setP_Latitude:[NSNumber numberWithDouble:pinLatitude]];
    


    [_mapRecord addPinsObject:pinRecord];
    
    MKPlacemark *pinMark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(pinLatitude, pinLongitude) addressDictionary:nil];
    
    [_mapView addAnnotation:pinMark];
    
    [_pins addObject:pinMark];

}

- (void) longPressOnMapView: (UIGestureRecognizer *)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];

    pinLatitude = touchMapCoordinate.latitude;
    pinLongitude = touchMapCoordinate.longitude;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
}

- (void) addLine:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
        [_mapView removeAnnotations:[_mapView annotations]];
        MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:touchMapCoordinate addressDictionary:nil];
        [_mapView addAnnotation:pm];
        
        
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];

        [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
        [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:pm]];
        directionsRequest.transportType = MKDirectionsTransportTypeWalking;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                data = [[response routes] lastObject];
                [_mapView addOverlay:data.polyline];
                NSLog(@"wow");
            }
        }];
    
}


- (void) tock:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"tock");
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    NSLog(@"%f, %f", touchPoint.x, touchPoint.y);
    
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];

    NSLog(@"%f, %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);

    
    MKAnnotationView *ano = [[MKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [ano setBackgroundColor:[UIColor redColor]];

    [ano.annotation setCoordinate:touchMapCoordinate];
    MKPlacemark *pinPoint = [[MKPlacemark alloc] initWithCoordinate:touchMapCoordinate addressDictionary:nil];

    [_mapView addAnnotation:pinPoint];
    
}


- (void) tick {
    
}

-(IBAction)curButClick:(id)sender {

    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
    [_mapView setCenterCoordinate:curPos animated:YES];
    [self setCenterCoordinate:curPos zoomLevel:10 animated:YES];


}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*_mapView.frame.size.width/256);
    [_mapView setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}


-(IBAction)move:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:btn.titleLabel.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [_mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
                
            }
            
            
        }
    }];

}




#pragma mark - Overlay

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithOverlay: overlay];
    polyLineView.strokeColor = [UIColor redColor];
    polyLineView.lineWidth   = 5.0;
    return polyLineView;
}





#pragma mark - Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *cordd = locations.lastObject;
    curPos = [cordd coordinate];
//    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
//    [mapView setCenterCoordinate:curPos];


}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:data.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [_mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
            }
        }
    }];
    
    [searchBar resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    if ([alertView.title isEqualToString:@"Saved"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([alertView.title isEqualToString:@"insert Title"]) {
        UITextField *textFieldForTitle = [alertView textFieldAtIndex:0];
        self.navigationItem.title = textFieldForTitle.text;
//        self.title = textFieldForTitle.text;
        [_mapRecord setM_MapTitle:textFieldForTitle.text];
    }

}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    
//    NSString *reuseName = @"anno";
//    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseName];
//    
//    if (pin == nil) {
//        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseName];
//        pin.animatesDrop = YES;
//        pin.pinColor = MKPinAnnotationColorGreen;
//    }
//    else {
//        pin.annotation = annotation;
//    }
//    
//    return pin;
//}

@end
